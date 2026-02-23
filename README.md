# Projeto Lógico de Banco de Dados para E-Commerce

## 📋 Descrição do Projeto

Desafio DIO - Construindo seu Primeiro Projeto Lógico de Banco de Dados  
Instrutor: Juliana Mascarenhas

Este projeto apresenta um modelo lógico completo de banco de dados para uma plataforma de e-commerce, contemplando cenários complexos de negócio como clientes PJ e PF, múltiplas formas de pagamento, rastreamento de entregas e gestão de vendedores terceirizados.

## 🎯 Objetivos

- Modelar um banco de dados relacional para e-commerce
- Implementar relacionamentos complexos entre entidades
- Garantir integridade referencial e constraints de negócio
- Aplicar boas práticas de normalização e indexação
- Criar queries complexas para análise de dados

## 🏗️ Estrutura do Banco de Dados

### Entidades Principais

1. **Cliente** - Informações básicas de clientes
2. **ClientePessoaFisica** - Dados específicos de pessoas físicas (CPF)
3. **ClientePessoaJuridica** - Dados específicos de pessoas jurídicas (CNPJ)
4. **Produto** - Catálogo de produtos
5. **Categoria** - Categorização hierárquica de produtos
6. **Estoque** - Controle de estoque por localização
7. **VendedorTerceirizado** - Gestão de vendedores terceiros
8. **Pedido** - Registro de pedidos de compra
9. **ItemPedido** - Produtos incluídos em cada pedido
10. **Pagamento** - Formas de pagamento utilizadas
11. **Entrega** - Rastreamento de entregas

### Relacionamentos Principais

- Cliente 1:1 ClientePessoaFisica ou ClientePessoaJuridica (especialização)
- Produto N:M Categoria (muitos-para-muitos)
- Produto N:M Estoque (controle de quantidade por localização)
- Produto N:M VendedorTerceirizado (marketplace)
- Pedido 1:N ItemPedido (composição)
- Pedido 1:N Pagamento (múltiplas formas de pagamento)
- Pedido 1:1 Entrega (rastreamento)

## 📊 Diagrama Entidade-Relacionamento

```
Cliente (1) ----< (N) Pedido (1) ----< (N) ItemPedido >---- (N) Produto
   |                       |                                      |
   |                       |                                      |
   |-- ClientePF          |-- Pagamento                          |-- Categoria
   |-- ClientePJ          |-- Entrega                            |-- Estoque
                                                                  |-- VendedorTerceirizado
```

## 🚀 Tecnologias Utilizadas

- SQL (MySQL/PostgreSQL compatível)
- Constraints de integridade referencial
- Índices para otimização de queries
- Triggers e procedures (opcional)

## 📁 Arquivos do Projeto

- `schema.sql` - Script completo de criação do banco de dados
- `queries.sql` - Queries de exemplo e análise de dados
- `inserts.sql` - Dados de teste para popular o banco
- `README.md` - Documentação do projeto

## 🔧 Como Utilizar

### 1. Criação do Banco de Dados

```sql
-- Executar o script schema.sql
source schema.sql;
```

### 2. Inserção de Dados de Teste

```sql
-- Executar o script inserts.sql
source inserts.sql;
```

### 3. Executar Queries de Análise

```sql
-- Executar o script queries.sql
source queries.sql;
```

## 📈 Queries de Exemplo

### Listar todos os pedidos com seus respectivos clientes
```sql
SELECT p.idPedido, c.nomeCliente, p.statusPedido, p.valorTotal
FROM Pedido p
INNER JOIN Cliente c ON p.idCliente = c.idCliente
ORDER BY p.dataPedido DESC;
```

### Produtos mais vendidos
```sql
SELECT pr.nomeProduto, SUM(ip.quantidade) as totalVendido
FROM ItemPedido ip
INNER JOIN Produto pr ON ip.idProduto = pr.idProduto
GROUP BY pr.idProduto
ORDER BY totalVendido DESC
LIMIT 10;
```

### Receita total por categoria
```sql
SELECT cat.nomeCategoria, SUM(ip.valorUnitario * ip.quantidade) as receita
FROM ItemPedido ip
INNER JOIN Produto pr ON ip.idProduto = pr.idProduto
INNER JOIN Produto_Categoria pc ON pr.idProduto = pc.idProduto
INNER JOIN Categoria cat ON pc.idCategoria = cat.idCategoria
GROUP BY cat.idCategoria;
```

## 🎓 Melhorias Implementadas

- ✅ Separação de clientes PF e PJ com especialização
- ✅ Sistema de múltiplos pagamentos por pedido
- ✅ Controle de estoque multi-localização
- ✅ Integração com vendedores terceirizados
- ✅ Rastreamento completo de entregas
- ✅ Categorização hierárquica de produtos
- ✅ Índices para otimização de performance
- ✅ Constraints de integridade referencial
- ✅ Cálculo automático de valores

## 📝 Requisitos Atendidos

- [x] Modelagem de clientes PJ e PF
- [x] Pagamentos associados aos pedidos
- [x] Entrega com status de rastreamento
- [x] Relacionamento produto/estoque
- [x] Relacionamento com vendedores terceiros
- [x] Queries complexas de análise
- [x] Documentação completa

## 🔗 Links do Projeto

- **GitHub**: https://github.com/Hbini/projeto-logico-bd-ecommerce-dio
- **GitLab**: [Em breve]
- **Pastebin**: https://pastebin.com/pK29yr97

## 👨‍💻 Autor

**Hbini**  
Desafio DIO - Construindo seu Primeiro Projeto Lógico de Banco de Dados  
Data: 2025

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais como parte do bootcamp da Digital Innovation One (DIO).

---

⭐ Desenvolvido com dedicação para o desafio DIO
