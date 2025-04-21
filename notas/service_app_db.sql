create database service_app_db;
use service_app_db;
#drop database service_app_db;

-- Tabela de Endereço (melhorada)
CREATE TABLE endereco (
    id_endereco INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(10) NOT NULL,
    pais VARCHAR(50) NOT NULL DEFAULT 'Brasil',
    estado VARCHAR(50) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    bairro VARCHAR(50) NOT NULL,
    rua VARCHAR(50) NOT NULL,
    numero INT NOT NULL,
    complemento VARCHAR(100),
    ponto_referencia VARCHAR(100),
    tipo ENUM('residencial', 'comercial') NOT NULL
);

-- Tabela de Usuários (base para cliente/restaurante/entregador)
CREATE TABLE usuario (
    id_usuario INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL, -- Senhas devem ser armazenadas como hash
    tipo ENUM('cliente', 'restaurante', 'entregador') NOT NULL,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

-- Tabela Cliente (agora vinculada a usuario)
CREATE TABLE cliente (
    id_cliente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_endereco INT,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_endereco) REFERENCES endereco(id_endereco)
);

-- Tabela Restaurante (melhorada)
CREATE TABLE restaurante (
    id_restaurante INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_endereco INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    telefone VARCHAR(15) NOT NULL,
    descricao TEXT,
    tempo_medio_entrega INT, -- em minutos
    taxa_entrega DECIMAL(10,2),
    horario_abertura TIME,
    horario_fechamento TIME,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_endereco) REFERENCES endereco(id_endereco)
);

-- Tabela Entregador (completa)
CREATE TABLE entregador (
    id_entregador INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_endereco INT,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    cnh VARCHAR(20),
    veiculo VARCHAR(50),
    placa VARCHAR(20),
    avaliacao_media DECIMAL(3,2) DEFAULT 0.0,
    total_entregas INT DEFAULT 0,
    disponivel BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_endereco) REFERENCES endereco(id_endereco)
);

-- Tabela Categoria (para classificação de restaurantes)
CREATE TABLE categoria (
    id_categoria INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    icone VARCHAR(50)
);

-- Tabela de relação Restaurante-Categoria
CREATE TABLE restaurante_categoria (
    id_restaurante INT NOT NULL,
    id_categoria INT NOT NULL,
    PRIMARY KEY (id_restaurante, id_categoria),
    FOREIGN KEY (id_restaurante) REFERENCES restaurante(id_restaurante),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- Tabela Pratos (completa)
CREATE TABLE prato (
    id_prato INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_restaurante INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    ingredientes TEXT,
    tempo_preparo INT, -- em minutos
    disponivel BOOLEAN NOT NULL DEFAULT TRUE,
    destaque BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_restaurante) REFERENCES restaurante(id_restaurante)
);

-- Tabela Pedidos (completa)
CREATE TABLE pedido (
    id_pedido INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_restaurante INT NOT NULL,
    id_endereco_entrega INT NOT NULL,
    data_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2) NOT NULL,
    taxa_entrega DECIMAL(10,2) NOT NULL,
    status ENUM('recebido', 'preparando', 'pronto', 'em_entrega', 'entregue', 'cancelado') NOT NULL DEFAULT 'recebido',
    metodo_pagamento ENUM('credito', 'debito', 'dinheiro', 'pix') NOT NULL,
    status_pagamento ENUM('pendente', 'pago', 'recusado', 'reembolsado') NOT NULL DEFAULT 'pendente',
    observacoes TEXT,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_restaurante) REFERENCES restaurante(id_restaurante),
    FOREIGN KEY (id_endereco_entrega) REFERENCES endereco(id_endereco)
);

-- Tabela Itens do Pedido
CREATE TABLE item_pedido (
    id_item_pedido INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_prato INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    observacoes TEXT,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_prato) REFERENCES prato(id_prato)
);

-- Tabela Entrega (detalhes)
CREATE TABLE entrega (
    id_entrega INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    data_saida DATETIME,
    data_entrega DATETIME,
    distancia DECIMAL(10,2), -- em km
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
);

-- Tabela Avaliações (completa)
CREATE TABLE avaliacao (
    id_avaliacao INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_cliente INT NOT NULL,
    nota_restaurante TINYINT CHECK (nota_restaurante BETWEEN 1 AND 5),
    nota_entregador TINYINT CHECK (nota_entregador BETWEEN 1 AND 5),
    comentario_restaurante TEXT,
    comentario_entregador TEXT,
    data_avaliacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);


SELECT * FROM usuario;
SELECT * FROM cliente;
SELECT * FROM entregador;
SELECT * FROM restaurante;
