const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/user');
const Client = require('../models/Client');
const Restaurant = require('../models/restaurant');

class AuthController {
    constructor(db) {
        this.userModel = new User(db);
        this.clientModel = new Client(db);
        this.restaurantModel = new Restaurant(db);
    }

    async registerClient(req, res) {
        try {
            const { email, senha, nome, telefone, cpf, data_nascimento, endereco } = req.body;

            // 1. Criar endereço primeiro
            const [enderecoResult] = await req.db.execute(
                `INSERT INTO endereco 
         (cep, estado, cidade, bairro, rua, numero, complemento, tipo) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    endereco.cep, endereco.estado, endereco.cidade, endereco.bairro,
                    endereco.rua, endereco.numero, endereco.complemento, 'residencial'
                ]
            );
            const idEndereco = enderecoResult.insertId;

            // 2. Criar usuário
            const hashedPassword = bcrypt.hashSync(senha, 8);
            const idUsuario = await this.userModel.create(email, hashedPassword, 'cliente');

            // 3. Criar cliente
            const idCliente = await this.clientModel.create(
                idUsuario, idEndereco, nome, telefone, cpf, data_nascimento
            );

            // 4. Retornar dados do cliente criado
            const cliente = await this.clientModel.getById(idCliente);

            res.status(201).json({
                success: true,
                message: 'Cliente registrado com sucesso',
                data: cliente
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ success: false, message: 'Erro ao registrar cliente' });
        }
    }

    async registerRestaurant(req, res) {
        try {
            const { email, senha, ...restaurantData } = req.body;

            // 1. Criar endereço
            const [enderecoResult] = await req.db.execute(
                `INSERT INTO endereco 
         (cep, estado, cidade, bairro, rua, numero, complemento, tipo) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    restaurantData.endereco.cep, restaurantData.endereco.estado,
                    restaurantData.endereco.cidade, restaurantData.endereco.bairro,
                    restaurantData.endereco.rua, restaurantData.endereco.numero,
                    restaurantData.endereco.complemento, 'comercial'
                ]
            );
            const idEndereco = enderecoResult.insertId;

            // 2. Criar usuário
            const hashedPassword = bcrypt.hashSync(senha, 8);
            const idUsuario = await this.userModel.create(email, hashedPassword, 'restaurante');

            // 3. Criar restaurante
            const idRestaurante = await this.restaurantModel.create(
                idUsuario, idEndereco, restaurantData
            );

            // 4. Retornar dados do restaurante criado
            const restaurante = await this.restaurantModel.getById(idRestaurante);

            res.status(201).json({
                success: true,
                message: 'Restaurante registrado com sucesso',
                data: restaurante
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ success: false, message: 'Erro ao registrar restaurante' });
        }
    }

    async login(req, res) {
        try {
            const { email, senha } = req.body;

            // 1. Verificar se usuário existe
            const user = await this.userModel.findByEmail(email);
            if (!user) {
                return res.status(404).json({ success: false, message: 'Usuário não encontrado' });
            }

            // 2. Verificar senha
            const passwordIsValid = bcrypt.compareSync(senha, user.senha);
            if (!passwordIsValid) {
                return res.status(401).json({ success: false, message: 'Senha inválida' });
            }

            // 3. Criar token JWT
            const token = jwt.sign(
                { id: user.id_usuario, email: user.email, tipo: user.tipo },
                process.env.JWT_SECRET || 'your-secret-key',
                { expiresIn: '24h' }
            );

            // 4. Retornar dados do usuário conforme o tipo
            let userData;
            if (user.tipo === 'cliente') {
                const [cliente] = await req.db.execute(
                    'SELECT * FROM cliente WHERE id_usuario = ?',
                    [user.id_usuario]
                );
                userData = cliente[0];
            } else if (user.tipo === 'restaurante') {
                const [restaurante] = await req.db.execute(
                    'SELECT * FROM restaurante WHERE id_usuario = ?',
                    [user.id_usuario]
                );
                userData = restaurante[0];
            }

            res.status(200).json({
                success: true,
                message: 'Login realizado com sucesso',
                token,
                user: {
                    id: user.id_usuario,
                    email: user.email,
                    tipo: user.tipo,
                    ...userData
                }
            });
        } catch (error) {
            console.error(error);
            res.status(500).json({ success: false, message: 'Erro ao fazer login' });
        }
    }
}

module.exports = AuthController;