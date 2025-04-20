require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./config/database');
const apiRoutes = require('./routes/api');
const app = express();

// Middlewares
// app.use(cors({
//     origin: 'http://localhost:5173', // URL exata do seu frontend
//     credentials: true,
//     methods: ['GET', 'POST', 'PUT', 'DELETE'],
//     allowedHeaders: ['Content-Type', 'Authorization']
//   }));

app.use(cors({
    origin: 'http://localhost:5173',
    credentials: true
  }));
  
app.use(express.json());

// Adiciona a conexão do banco de dados ao objeto de requisição
app.use((req, res, next) => {
    req.db = db;
    next();
});

app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Rotas
app.use('/api', apiRoutes(db));

// Middleware de erro
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ success: false, message: 'Erro interno do servidor' });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Serviço de Clientes e Restaurantes rodando na porta ${PORT}`);
});