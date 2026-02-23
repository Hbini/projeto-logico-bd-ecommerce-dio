-- =====================================================
-- QUERIES COMPLEXAS - E-COMMERCE DATABASE
-- Projeto Lógico de Banco de Dados DIO
-- =====================================================

-- =====================================================
-- 1. RECUPERAÇÕES SIMPLES COM SELECT
-- =====================================================

-- Listar todos os clientes
SELECT * FROM Cliente;

-- Listar todos os produtos ordenados por preço
SELECT nomeProduto, precoProduto 
FROM Produto 
ORDER BY precoProduto DESC;

-- Listar clientes pessoa física com CPF
SELECT c.nomeCliente, c.email, pf.cpf
FROM Cliente c
INNER JOIN ClientePessoaFisica pf ON c.idCliente = pf.idCliente;

-- Listar clientes pessoa jurídica com CNPJ
SELECT c.nomeCliente, c.email, pj.cnpj, pj.razaoSocial
FROM Cliente c
INNER JOIN ClientePessoaJuridica pj ON c.idCliente = pj.idCliente;

-- =====================================================
-- 2. FILTROS COM WHERE
-- =====================================================

-- Produtos com preço acima de R$ 100
SELECT nomeProduto, precoProduto
FROM Produto
WHERE precoProduto > 100.00;

-- Pedidos com status 'Confirmado'
SELECT idPedido, idCliente, statusPedido, valorTotal, dataPedido
FROM Pedido
WHERE statusPedido = 'Confirmado';

-- Produtos ativos em estoque
SELECT p.nomeProduto, e.localEstoque, pe.quantidade
FROM Produto p
INNER JOIN Produto_Estoque pe ON p.idProduto = pe.idProduto
INNER JOIN Estoque e ON pe.idEstoque = e.idEstoque
WHERE p.ativo = TRUE AND pe.quantidade > 0;

-- =====================================================
-- 3. EXPRESSÕES COM ATRIBUTOS DERIVADOS
-- =====================================================

-- Valor total de cada item do pedido (quantidade * preço)
SELECT 
    ip.idPedido,
    p.nomeProduto,
    ip.quantidade,
    ip.valorUnitario,
    (ip.quantidade * ip.valorUnitario) AS valorTotalItem
FROM ItemPedido ip
INNER JOIN Produto p ON ip.idProduto = p.idProduto;

-- Percentual de comissão dos vendedores sobre seus produtos
SELECT 
    v.nomeVendedor,
    p.nomeProduto,
    vp.precoProduto,
    v.percentualComissao,
    (vp.precoProduto * v.percentualComissao / 100) AS valorComissao
FROM VendedorTerceirizado v
INNER JOIN Vendedor_Produto vp ON v.idVendedor = vp.idVendedor
INNER JOIN Produto p ON vp.idProduto = p.idProduto;

-- =====================================================
-- 4. ORDENAÇÃO COM ORDER BY
-- =====================================================

-- Pedidos mais recentes primeiro
SELECT idPedido, idCliente, valorTotal, dataPedido
FROM Pedido
ORDER BY dataPedido DESC;

-- Produtos por categoria e preço
SELECT 
    cat.nomeCategoria,
    p.nomeProduto,
    p.precoProduto
FROM Produto p
INNER JOIN Produto_Categoria pc ON p.idProduto = pc.idProduto
INNER JOIN Categoria cat ON pc.idCategoria = cat.idCategoria
ORDER BY cat.nomeCategoria, p.precoProduto DESC;

-- =====================================================
-- 5. FILTROS COM HAVING E GROUP BY
-- =====================================================

-- Total de pedidos por cliente (somente clientes com mais de 1 pedido)
SELECT 
    c.nomeCliente,
    COUNT(p.idPedido) AS totalPedidos,
    SUM(p.valorTotal) AS valorTotalCompras
FROM Cliente c
INNER JOIN Pedido p ON c.idCliente = p.idCliente
GROUP BY c.idCliente
HAVING COUNT(p.idPedido) > 1
ORDER BY totalPedidos DESC;

-- Produtos mais vendidos (quantidade total > 5)
SELECT 
    p.nomeProduto,
    SUM(ip.quantidade) AS totalVendido,
    SUM(ip.quantidade * ip.valorUnitario) AS receitaTotal
FROM Produto p
INNER JOIN ItemPedido ip ON p.idProduto = ip.idProduto
GROUP BY p.idProduto
HAVING SUM(ip.quantidade) > 5
ORDER BY totalVendido DESC;

-- Categorias com receita acima de R$ 500
SELECT 
    cat.nomeCategoria,
    COUNT(DISTINCT p.idProduto) AS qtdProdutos,
    SUM(ip.quantidade * ip.valorUnitario) AS receitaCategoria
FROM Categoria cat
INNER JOIN Produto_Categoria pc ON cat.idCategoria = pc.idCategoria
INNER JOIN Produto p ON pc.idProduto = p.idProduto
INNER JOIN ItemPedido ip ON p.idProduto = ip.idProduto
GROUP BY cat.idCategoria
HAVING SUM(ip.quantidade * ip.valorUnitario) > 500
ORDER BY receitaCategoria DESC;

-- =====================================================
-- 6. JUNÇÕES ENTRE TABELAS
-- =====================================================

-- Pedidos com informações completas do cliente
SELECT 
    p.idPedido,
    c.nomeCliente,
    c.email,
    p.statusPedido,
    p.valorTotal,
    p.dataPedido
FROM Pedido p
INNER JOIN Cliente c ON p.idCliente = c.idCliente
ORDER BY p.dataPedido DESC;

-- Detalhamento completo de itens do pedido
SELECT 
    ped.idPedido,
    c.nomeCliente,
    prod.nomeProduto,
    ip.quantidade,
    ip.valorUnitario,
    (ip.quantidade * ip.valorUnitario) AS subtotal
FROM Pedido ped
INNER JOIN Cliente c ON ped.idCliente = c.idCliente
INNER JOIN ItemPedido ip ON ped.idPedido = ip.idPedido
INNER JOIN Produto prod ON ip.idProduto = prod.idProduto
ORDER BY ped.idPedido;

-- Pedidos com suas formas de pagamento
SELECT 
    ped.idPedido,
    c.nomeCliente,
    pag.tipoPagamento,
    pag.valorPagamento,
    pag.statusPagamento
FROM Pedido ped
INNER JOIN Cliente c ON ped.idCliente = c.idCliente
INNER JOIN Pagamento pag ON ped.idPedido = pag.idPedido
ORDER BY ped.idPedido;

-- Pedidos com informações de entrega
SELECT 
    ped.idPedido,
    c.nomeCliente,
    ent.statusEntrega,
    ent.codigoRastreio,
    ent.dataPrevistaEntrega,
    ent.dataEntrega
FROM Pedido ped
INNER JOIN Cliente c ON ped.idCliente = c.idCliente
LEFT JOIN Entrega ent ON ped.idPedido = ent.idPedido
ORDER BY ped.dataPedido DESC;

-- =====================================================
-- 7. QUERIES COMPLEXAS DE ANÁLISE DE NEGÓCIO
-- =====================================================

-- Análise de vendas por categoria
SELECT 
    cat.nomeCategoria,
    COUNT(DISTINCT ip.idPedido) AS qtdPedidos,
    SUM(ip.quantidade) AS qtdItensVendidos,
    SUM(ip.quantidade * ip.valorUnitario) AS receitaTotal,
    AVG(ip.valorUnitario) AS precoMedio
FROM Categoria cat
INNER JOIN Produto_Categoria pc ON cat.idCategoria = pc.idCategoria
INNER JOIN Produto p ON pc.idProduto = p.idProduto
INNER JOIN ItemPedido ip ON p.idProduto = ip.idProduto
GROUP BY cat.idCategoria
ORDER BY receitaTotal DESC;

-- Ranking dos clientes por valor de compras
SELECT 
    c.nomeCliente,
    c.email,
    COUNT(ped.idPedido) AS totalPedidos,
    SUM(ped.valorTotal) AS valorTotalCompras,
    AVG(ped.valorTotal) AS ticketMedio
FROM Cliente c
INNER JOIN Pedido ped ON c.idCliente = ped.idCliente
GROUP BY c.idCliente
ORDER BY valorTotalCompras DESC
LIMIT 10;

-- Produtos com estoque baixo (menos de 10 unidades)
SELECT 
    p.nomeProduto,
    p.precoProduto,
    e.localEstoque,
    pe.quantidade AS qtdEstoque
FROM Produto p
INNER JOIN Produto_Estoque pe ON p.idProduto = pe.idProduto
INNER JOIN Estoque e ON pe.idEstoque = e.idEstoque
WHERE pe.quantidade < 10 AND p.ativo = TRUE
ORDER BY pe.quantidade ASC;

-- Análise de performance de vendedores terceirizados
SELECT 
    v.nomeVendedor,
    v.percentualComissao,
    COUNT(vp.idProduto) AS qtdProdutosCadastrados,
    SUM(vp.estoque) AS totalEstoque
FROM VendedorTerceirizado v
LEFT JOIN Vendedor_Produto vp ON v.idVendedor = vp.idVendedor
GROUP BY v.idVendedor
ORDER BY qtdProdutosCadastrados DESC;

-- Taxa de conclusão de entregas
SELECT 
    statusEntrega,
    COUNT(*) AS quantidade,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Entrega), 2) AS percentual
FROM Entrega
GROUP BY statusEntrega
ORDER BY quantidade DESC;

-- Métodos de pagamento mais utilizados
SELECT 
    tipoPagamento,
    COUNT(*) AS qtdUtilizacoes,
    SUM(valorPagamento) AS valorTotal,
    AVG(valorPagamento) AS valorMedio
FROM Pagamento
GROUP BY tipoPagamento
ORDER BY qtdUtilizacoes DESC;

-- =====================================================
-- 8. QUERIES COM SUBQUERIES
-- =====================================================

-- Clientes que nunca fizeram pedidos
SELECT nomeCliente, email
FROM Cliente
WHERE idCliente NOT IN (SELECT DISTINCT idCliente FROM Pedido);

-- Produtos que nunca foram vendidos
SELECT nomeProduto, precoProduto
FROM Produto
WHERE idProduto NOT IN (SELECT DISTINCT idProduto FROM ItemPedido);

-- Pedidos acima da média de valor
SELECT idPedido, valorTotal, dataPedido
FROM Pedido
WHERE valorTotal > (SELECT AVG(valorTotal) FROM Pedido)
ORDER BY valorTotal DESC;

-- =====================================================
-- 9. RELATÓRIOS GERENCIAIS
-- =====================================================

-- Resumo geral do e-commerce
SELECT 
    (SELECT COUNT(*) FROM Cliente) AS totalClientes,
    (SELECT COUNT(*) FROM Produto WHERE ativo = TRUE) AS totalProdutosAtivos,
    (SELECT COUNT(*) FROM Pedido) AS totalPedidos,
    (SELECT SUM(valorTotal) FROM Pedido) AS receitaTotal,
    (SELECT AVG(valorTotal) FROM Pedido) AS ticketMedio;

-- Evolução de pedidos por status
SELECT 
    statusPedido,
    COUNT(*) AS quantidade,
    SUM(valorTotal) AS valorTotal,
    AVG(valorTotal) AS valorMedio
FROM Pedido
GROUP BY statusPedido
ORDER BY quantidade DESC;
