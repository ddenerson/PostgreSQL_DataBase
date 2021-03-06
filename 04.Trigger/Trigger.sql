1 -- Crie uma trigger para preencher o conteúdo de uma coluna caso ele seja deixado em
-- branco durante uma operação de insert. Nesse exercício caso seja deixado em banco
-- o campo data de cadastro durante a inclusão, a trigger automaticamente preenche
-- com a data do sistema.

CREATE TABLE piloto
(
	codpiloto INTEGER PRIMARY KEY,
	nomepilot VARCHAR(100),
	salario   NUMERIC(9,2),
	gratificacao NUMERIC(9,2),
	companhia    VARCHAR(30),
	pais		 VARCHAR(15),
	dtcadastrp	 DATE,
	usupdate 	 VARCHAR(30)
);


INSERT INTO piloto
VALUES(1,'luiz fernando',9800.00,3000.00,'gol','brasil');

--- FUNCAO 
CREATE OR REPLACE FUNCTION dt_inclusao()
	RETURNS TRIGGER
AS
$BODY$
BEGIN
  NEW.dtcadastrp = NOW();
  RETURN NEW;
END;
$BODY$
 LANGUAGE plpgsql VOLATILE

-- TRIGGER

CREATE TRIGGER tr_dt_cadastro
BEFORE INSERT
ON piloto
FOR EACH ROW
EXECUTE PROCEDURE dt_inclusao();


-- 2. Vamos estabelecer um valor máximo para o campo salário. Nenhum Piloto poderá
-- ganha mais do que 10.000 dólares. Além de ativar a trigger na inclusão, evitando
-- que um novo funcionário tenha um salário superior ao limite, as rotinas de
-- atualização(update) devem ser verificadas para evitar que os Pilotos existentes
-- sejam alterados para valores não-permitidos.




CREATE FUNCTION limit_salario() RETURNS TRIGGER
AS
$BODY$
BEGIN
 IF NEW.salario > 10000.00 THEN
  RAISE EXCEPTION 'O VALOR DEVE SEGUIR O LIMITE DE ATE 10 MIL';
 END IF;
RETURN NEW; 
END;
$BODY$
LANGUAGE plpgsql VOLATILE


CREATE TRIGGER tr_limit_salario_upd
BEFORE UPDATE
ON PILOTO
FOR EACH ROW
EXECUTE PROCEDURE limit_salario();


CREATE TRIGGER tr_limit_salario_in
BEFORE UPDATE
ON PILOTO
FOR EACH ROW
EXECUTE PROCEDURE limit_salario();


-- 3 Vamos criar uma Trigger que não permita atualização da tabela de pilotos entre os
-- dias 10 e 20 do mês


-- FUNCAO DE AJUSTO

CREATE OR REPLACE FUNCTION upd_pilotos() 
RETURNS TRIGGER
AS
$BODY$
DECLARE dia DATE;
BEGIN
	SELECT EXTRACT(DAY FROM NOW()) INTO dia;
	
	IF dia >= 10 and dia <= 20 THEN
	 RAISE EXCEPTION 'A TABELA NÃO PODE SER ATUALIZADA NESSE PERIODO';
	END IF;
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE

-- TRIGGERS 

CREATE TRIGGER tr_upd_pilotos
BEFORE UPDATE
ON piloto
FOR EACH ROW
EXECUTE PROCEDURE upd_pilotos();


-- 4. Neste exercício todo registro inserido na tabela de Piloto será inserido também na
-- tabela Piloto resumido. Inclua uma trigger para realizar esta tarefa

CREATE TABLE piloto_resumido
(
	codpiloto INTEGER PRIMARY KEY,
	nomepilot VARCHAR(100)
);

-- FUNCAO 

CREATE OR  REPLACE FUNCTION copia_piloto() RETURNS TRIGGER
AS 
$BODY$
BEGIN
	INSERT INTO piloto_resumido(codpiloto, nomepilot)
	VALUES(NEW.codpiloto,NEW.nomepilot);
RETURN NEW;
END;
$BODY$ 
LANGUAGE PLPGSQL VOLATILE


-- TRIGGER

CREATE TRIGGER tr_in_copia_piloto
AFTER INSERT 
ON piloto
FOR EACH ROW
EXECUTE PROCEDURE copia_piloto();

INSERT INTO piloto(codpiloto, nomepilot, salario, gratificacao, companhia, pais)
	VALUES(3,'MATHEUES FERRAZ',8000,3000,'AZUL','BRASIL');

SELECT * FROM piloto_resumido;


5. Para que a tabela de Piloto resumido fique sempre com a mesma quantidade de
registros uma outra trigger deve ser criada para excluir registros.

-- FUNCAO

CREATE OR REPLACE FUNCTION delete_registro() returns TRIGGER
AS
$BODY$
BEGIN
	DELETE
	FROM piloto_resumido
	WHERE codpiloto NOT IN (SELECT codpiloto FROM piloto);
  RETURN NEW;
END;
$BODY$
LANGUAGE PLPGSQL VOLATILE

-- TRIGGER

CREATE TRIGGER tr_delete_registro
AFTER DELETE
ON piloto
FOR EACH ROW 
EXECUTE PROCEDURE delete_registro();


-- 6 Implemente uma trigger que armazena o nome do usuário que realizou a última
-- atualização na tabela piloto.
