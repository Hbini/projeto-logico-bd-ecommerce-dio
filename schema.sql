-- ==============================================
-- PROJETO LOGICO DE BANCO DE DADOS - E-COMMERCE
-- Disciplina: Construindo Seu Primeiro Projeto Logico de BD
-- Instrutora: Juliana Mascarenhas - Digital Innovation One
-- ==============================================
-- Autor: Desenvolvedor
-- Data: Fevereiro 2026
-- Descricao: Projeto logico de banco de dados para cenario de e-commerce
--            com suporte a clientes PJ e PF, multiplas formas de pagamento,
--            e detalhes de entrega com rastreamento.
-- ==============================================

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- ==============================================
-- TABELA: Tipo de Cliente
-- Armazena os tipos de clientes (Pessoa Fisica, Pessoa Juridica)
-- ==============================================
CREATE TABLE IF NOT EXISTS TipoCliente (
    idTipoCliente INT PRIMARY KEY AUTO_INCREMENT,
    nomeTipo VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(255)
);

-- ==============================================
-- TABELA: Pessoa Fisica
-- Dados especificos de clientes pessoa fisica
-- ==============================================
CREATE TABLE IF NOT EXISTS PessoaFisica (
    idPessoaFisica INT PRIMARY KEY AUTO_INCREMENT,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    nome VARCHAR(150) NOT NULL,
    dataNascimento DATE,
    genero CHAR(1),
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================
-- TABELA: Pessoa Juridica
-- Dados especificos de clientes pessoa juridica
-- ==============================================
CREATE TABLE IF NOT EXISTS PessoaJuridica (
    idPessoaJuridica INT PRIMARY KEY AUTO_INCREMENT,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    razaoSocial VARCHAR(200) NOT NULL,
    nomeFantasia VARCHAR(150),
    dataCriacao DATE,
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================
-- TABELA: Cliente
-- Tabela principal de clientes (estrutura unificada)
-- ==============================================
CREATE TABLE IF NOT EXISTS Cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    endereco VARCHAR(255) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    idPessoaFisica INT UNIQUE,
    idPessoaJuridica INT UNIQUE,
    FOREIGN KEY (idPessoaFisica) REFERENCES PessoaFisica(idPessoaFisica) ON DELETE CASCADE,
    FOREIGN KEY (idPessoaJuridica) REFERENCES PessoaJuridica(idPessoaJuridica) ON DELETE CASCADE,
    CHECK ((idPessoaFisica IS NOT NULL AND idPessoaJuridica IS NULL) OR (idPessoaFisica IS NULL AND idPessoaJuridica IS NOT NULL))
);

-- ==============================================
-- TABELA: Produto
-- Armazena informacoes de produtos
-- ==============================================
CREATE TABLE IF NOT EXISTS Produto (
    idProduto INT PRIMARY KEY AUTO_INCREMENT,
    nomeProduto VARCHAR(200) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL CHECK(preco > 0),
    categoria VARCHAR(100),
    estoque INT DEFAULT 0 CHECK(estoque >= 0),
    sku VARCHAR(100) UNIQUE,
    dataIncluso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- ==============================================
-- TABELA: Pedido
-- Armazena informacoes dos pedidos realizados
-- ==============================================
CREATE TABLE IF NOT EXISTS Pedido (
    idPedido INT PRIMARY KEY AUTO_INCREMENT,
    idCliente INT NOT NULL,
    dataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dataEntrega DATE,
    status ENUM('Pendente', 'Processando', 'Enviado', 'Entregue', 'Cancelado') DEFAULT 'Pendente',
    valorTotal DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    INDEX idx_cliente (idCliente),
    INDEX idx_status (status),
    INDEX idx_data (dataPedido)
);

-- ==============================================
-- TABELA: Produto_Pedido
-- Relacionamento entre Produtos e Pedidos (tabela de junçao)
-- ==============================================
CREATE TABLE IF NOT EXISTS Produto_Pedido (
    idProdutoPedido INT PRIMARY KEY AUTO_INCREMENT,
    idPedido INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL CHECK(quantidade > 0),
    precoUnitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2) GENERATED ALWAYS AS (quantidade * precoUnitario) STORED,
    dataAdicao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido) ON DELETE CASCADE,
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    UNIQUE KEY uk_pedido_produto (idPedido, idProduto)
);

-- ==============================================
-- TABELA: Forma de Pagamento
-- Tipos de formas de pagamento disponiveis
-- ==============================================
CREATE TABLE IF NOT EXISTS FormaPagamento (
    idFormaPagamento INT PRIMARY KEY AUTO_INCREMENT,
    tipoForma VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(200)
);

-- ==============================================
-- TABELA: Pagamento
-- Registros de pagamentos dos pedidos
-- ==============================================
CREATE TABLE IF NOT EXISTS Pagamento (
    idPagamento INT PRIMARY KEY AUTO_INCREMENT,
    idPedido INT NOT NULL,
    idFormaPagamento INT NOT NULL,
    valorPago DECIMAL(12, 2) NOT NULL CHECK(valorPago > 0),
    dataPagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statusPagamento ENUM('Pendente', 'Confirmado', 'Recusado', 'Reembolsado') DEFAULT 'Pendente',
    numeroTransacao VARCHAR(100),
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido) ON DELETE CASCADE,
    FOREIGN KEY (idFormaPagamento) REFERENCES FormaPagamento(idFormaPagamento),
    INDEX idx_pedido (idPedido),
    INDEX idx_status_pagamento (statusPagamento)
);

-- ==============================================
-- TABELA: Entrega
-- Detalhes de entrega dos pedidos
-- ==============================================
CREATE TABLE IF NOT EXISTS Entrega (
    idEntrega INT PRIMARY KEY AUTO_INCREMENT,
    idPedido INT NOT NULL UNIQUE,
    codigoRastreio VARCHAR(50) NOT NULL UNIQUE,
    statusEntrega ENUM('Aguardando', 'Coletado', 'Em transito', 'Entregue', 'Falha na entrega') DEFAULT 'Aguardando',
    dataColeta DATETIME,
    dataEntrega DATETIME,
    transportadora VARCHAR(100),
    endereco VARCHAR(255),
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido) ON DELETE CASCADE,
    INDEX idx_rastreio (codigoRastreio),
    INDEX idx_status_entrega (statusEntrega)
);

-- ==============================================
-- TABELA: Fornecedor
-- Dados dos fornecedores de produtos
-- ==============================================
CREATE TABLE IF NOT EXISTS Fornecedor (
    idFornecedor INT PRIMARY KEY AUTO_INCREMENT,
    nomeFornecedor VARCHAR(200) NOT NULL,
    endereco VARCHAR(255),
    telefone VARCHAR(15),
    email VARCHAR(150),
    cnpj VARCHAR(18) UNIQUE,
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- ==============================================
-- TABELA: Fornecimento
-- Relacionamento entre Fornecedores e Produtos
-- ==============================================
CREATE TABLE IF NOT EXISTS Fornecimento (
    idFornecimento INT PRIMARY KEY AUTO_INCREMENT,
    idFornecedor INT NOT NULL,
    idProduto INT NOT NULL,
    precoFornecimento DECIMAL(10, 2) NOT NULL CHECK(precoFornecimento > 0),
    quantidadeMinima INT DEFAULT 1,
    dataFornecimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idFornecedor) REFERENCES Fornecedor(idFornecedor),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    UNIQUE KEY uk_fornecedor_produto (idFornecedor, idProduto)
);

-- ==============================================
-- TABELA: Vendedor Terceirizado
-- Vendedores terceirizados na plataforma
-- ==============================================
CREATE TABLE IF NOT EXISTS VendedorTerceirizado (
    idVendedor INT PRIMARY KEY AUTO_INCREMENT,
    nomeVendedor VARCHAR(200) NOT NULL,
    endereço VARCHAR(255),
    telefone VARCHAR(15),
    email VARCHAR(150),
    percentualComissao DECIMAL(5, 2) DEFAULT 10.00,
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
);

-- ==============================================
-- TABELA: Vendedor_Produto
-- Relacionamento entre Vendedores Terceirizados e Produtos
-- ==============================================
CREATE TABLE IF NOT EXISTS Vendedor_Produto (
    idVendedorProduto INT PRIMARY KEY AUTO_INCREMENT,
    idVendedor INT NOT NULL,
    idProduto INT NOT NULL,
    precoProduto DECIMAL(10, 2) NOT NULL CHECK(precoProduto > 0),
    estoque INT DEFAULT 0 CHECK(estoque >= 0),
    dataRegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (idVendedor) REFERENCES VendedorTerceirizado(idVendedor),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto),
    UNIQUE KEY uk_vendedor_produto (idVendedor, idProduto)
);

-- ==============================================
-- INDICES PARA OTIMIZACAO DE QUERIES
-- ==============================================
CREATE INDEX idx_cliente_email ON Cliente(email);
CREATE INDEX idx_cliente_cidade ON Cliente(cidade);
CREATE INDEX idx_produto_categoria ON Produto(categoria);
CREATE INDEX idx_pedido_cliente_data ON Pedido(idCliente, dataPedido);
CREATE INDEX idx_pagamento_status ON Pagamento(statusPagamento);
CREATE INDEX idx_entrega_pedido ON Entrega(idPedido);

COMMIT;
