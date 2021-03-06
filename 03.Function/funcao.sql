
CREATE TABLE produtos
(
	produtoid     INTEGER PRIMARY KEY,
	nomeprod      VARCHAR(20),
	categoriaidpr INTEGER,
	preco         DECIMAL(10,2),
	estoque       INTEGER
);

CREATE TABLE categorias
(
 	categoriaid INTEGER PRIMARY KEY,
	nome         VARCHAR(30),
	descricao    VARCHAR(55)
);

CREATE TABLE itenspedidos
(
	itensPedidosid INTEGER PRIMARY KEY,
	pedidoiditem   INTEGER,
	produtoiditem  INTEGER,
	preco          DECIMAL(10,2),
	quantidade     INTEGER
);


CREATE TABLE pedidos
(
	pedidoid       INTEGER PRIMARY KEY,
	clienteidped   INTEGER,
	dataped		   DATE,
	frete          INTEGER
);

CREATE TABLE clientes
(
	clienteid   INTEGER PRIMARY KEY,
	nmcliente   VARCHAR(20),
	enderecocl  VARCHAR(30),
	cidade 		VARCHAR(15),
	cep 		INTEGER,
	pais        VARCHAR(15),
	email       VARCHAR(15)	
);

-------------- INTEGRAÇAO DAS TABELAS -----------------------

ALTER TABLE produtos ADD CONSTRAINT categoriaidpr
FOREIGN KEY(categoriaidpr) REFERENCES categorias(categoriaid);

ALTER TABLE itenspedidos ADD CONSTRAINT produtoiditem
FOREIGN KEY(produtoiditem) REFERENCES produtos(produtoid);

ALTER TABLE itenspedidos ADD CONSTRAINT pedidoiditem
FOREIGN KEY(pedidoiditem) REFERENCES pedidos(pedidoid);

ALTER TABLE pedidos ADD CONSTRAINT clienteidped 
FOREIGN KEY(clienteidped) REFERENCES clientes(clienteid);

---------------------------------------------------------------

-- 1. Criar uma função para excluir um registro de cliente da tabela clientes. Observar
-- que o cliente poderá estar vinculado a vendas e itens de vendas através de chaves
-- estrangeiras, portanto, é necessário excluir também os registro vinculados. A
-- função deverá receber como parâmetro o código do cliente a ser excluído e retornar o código do cliente excluído.


INSERT INTO clientes 
VALUES(1,'Matheus Santos','Fontes  Damasceno ','São Paulo',38045800,'Brasil','@gmail.com');

INSERT INTO pedidos
VALUES(1,1,CURRENT_DATE,19.90);

INSERT INTO itenspedidos
VALUES(1,1,1,60.00,1);

INSERT INTO produtos
VALUES(1,'CAMISETA CK',1,69.90,500);

INSERT INTO categorias
VALUES(1,'CAMISETA','CAMISETA DA MARCA CALVIN KLEIN');




CREATE FUNCTION del_registro(x INTEGER) RETURNS void 
AS 
$BODY$
BEGIN
DELETE FROM itenspedidos WHERE pedidoiditem IN
     (SELECT pedidoid FROM pedidos WHERE clienteidped = $1);
DELETE FROM pedidos WHERE clienteidped = $1;
DELETE FROM clientes WHERE clienteid = $1;
END
$BODY$ 
LANGUAGE PLPGSQL;

SELECT del_registro(1);
SELECT * FROM clientes;


-- 2 Criar uma função para inserir um produto perecível na tabela de produtos. A
-- função deverá receber a descrição do produto e a data de validade como parâmetros e retornar o registro inserido.


-- 3 Criar uma função para excluir todos os produtos que não estiverem presentes em
-- nenhuma venda, isto é, aqueles que não são usados na tabela produtos_venda.
-- Consulte a documentação do comando DELETE do PostgreSQL para verificar
-- como isto pode ser feito com o auxílio de um SELECT.

CREATE FUNCTION del_produtos() RETURNS void 
AS 
$BODY$
BEGIN
	DELETE FROM produtos WHERE produtoid NOT IN
      (SELECT produtoiditem FROM itenspedidos);
END	  
$BODY$
LANGUAGE PLPGSQL;
				
SELECT del_produtos();

-- 4. Executar as funções criadas para confirmar a sua funcionalidade


SELECT del_registro(1);

SELECT * FROM clientes;


SELECT del_produtos();

SELECT * FROM produtos;






