create database gato_caolho;
\c gato_caolho
set datestyle to 'ISO,DMY';

-- ##########################################################################################################################################################
-- CREATE TABLES
-- ##########################################################################################################################################################
CREATE TABLE IF NOT EXISTS "usuario" (
  "id_usuario" SERIAL PRIMARY KEY,
  "nome" VARCHAR(100) NOT NULL,
  "cpf" VARCHAR(20) NOT NULL,
  "senha" VARCHAR(100) NOT NULL,
  "email" VARCHAR(256) NOT NULL,
  "telefone" BIGINT NOT NULL,
  "cargo_id" INTEGER NOT NULL,
  "status" BOOLEAN,
  "comanda_id" INTEGER
);

CREATE TABLE IF NOT EXISTS "cargo" (
  "id_cargo" INTEGER PRIMARY KEY,
  "cargo" VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS "comanda" (
  "id_comanda" SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS "venda" (
  "id_venda" SERIAL PRIMARY KEY,
  "comanda_id" INTEGER NOT NULL,
  "forma_pagamento_id" INTEGER NOT NULL,
  "data_venda" DATE NOT NULL,
  "hora_venda" TIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "forma_pagamento" (
  "id_forma_pagamento" SERIAL PRIMARY KEY,
  "nome" VARCHAR(20) NOT NULL,
  "status" BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS "pedido" (
  "id_pedido" SERIAL PRIMARY KEY,
  "comanda_id" INTEGER NOT NULL,
  "mesa" INTEGER NOT NULL,
  "valor" INTEGER NOT NULL,
  "status" BOOLEAN NOT NULL,
  "data_pedido" DATE NOT NULL,
  "hora_pedido" TIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "item_pedido" (
  "id_item_pedido" SERIAL PRIMARY KEY,
  "pedido_id" INTEGER NOT NULL,
  "produto_id" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "produto" (
  "id_produto" SERIAL PRIMARY KEY,
  "nome" VARCHAR(50) NOT NULL,
  "descricao" VARCHAR(200) NOT NULL,
  "unidade_medida" VARCHAR(5) NOT NULL,
  "valor" money NOT NULL,
  "marca" VARCHAR(15),
  "secao_id" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "secao" (
  "id_secao" SERIAL PRIMARY KEY,
  "nome" VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS "desconto" (
  "id_desconto" SERIAL PRIMARY KEY,
  "produto_id" INTEGER NOT NULL,
  "valor_desconto" money NOT NULL,
  "descricao" VARCHAR(200),
  "data_inicial" DATE,
  "data_final" DATE,
  "hora_inicial" TIME,
  "hora_final" TIME
);

-- ##########################################################################################################################################################
-- FOREIGN KEYS
-- ##########################################################################################################################################################

ALTER TABLE "usuario" ADD CONSTRAINT "fk_cargo_funcionario" FOREIGN KEY ("cargo_id") REFERENCES "cargo" ("id_cargo");

ALTER TABLE "usuario" ADD CONSTRAINT "fk_comanda_cliente" FOREIGN KEY ("comanda_id") REFERENCES "comanda" ("id_comanda");

ALTER TABLE "venda" ADD CONSTRAINT "fk_venda_comanda" FOREIGN KEY ("comanda_id") REFERENCES "comanda" ("id_comanda");

ALTER TABLE "venda" ADD CONSTRAINT "fk_venda_forma_pagamento" FOREIGN KEY ("forma_pagamento_id") REFERENCES "forma_pagamento" ("id_forma_pagamento");

ALTER TABLE "pedido" ADD CONSTRAINT "fk_pedido_comanda" FOREIGN KEY ("comanda_id") REFERENCES "comanda" ("id_comanda");

ALTER TABLE "item_pedido" ADD CONSTRAINT "fk_item_pedido_pedido" FOREIGN KEY ("pedido_id") REFERENCES "pedido" ("id_pedido");

ALTER TABLE "item_pedido" ADD CONSTRAINT "fk_item_pedido_produto" FOREIGN KEY ("produto_id") REFERENCES "produto" ("id_produto");

ALTER TABLE "produto" ADD CONSTRAINT "fk_produto_secao" FOREIGN KEY ("secao_id") REFERENCES "secao" ("id_secao");

ALTER TABLE "desconto" ADD CONSTRAINT "fk_desconto_produto" FOREIGN KEY ("produto_id") REFERENCES "produto" ("id_produto");


-- ##########################################################################################################################################################
-- Triggers
-- ##########################################################################################################################################################

-- RODAR UM POR VEZ
CREATE OR REPLACE FUNCTION criar_comanda_para_cliente()
RETURNS TRIGGER AS $$
DECLARE
    new_comanda_id INTEGER;
BEGIN
    -- Verificar se o cargo_id é 3
    IF NEW.cargo_id = 3 THEN
        -- Inserir uma nova comanda e obter o id_comanda gerado
        INSERT INTO comanda DEFAULT VALUES RETURNING id_comanda INTO new_comanda_id;

        -- Atualizar o comanda_id do novo usuário
		UPDATE usuario SET comanda_id = new_comanda_id WHERE id_usuario = NEW.id_usuario;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- RODAR UM POR VEZ
CREATE TRIGGER after_usuario_insert
AFTER INSERT ON usuario
FOR EACH ROW
EXECUTE FUNCTION criar_comanda_para_cliente();

-- RODAR UM POR VEZ ESSES 2 APÓS CRIAR AS 100 COMANDAS PADRÃO
-- Verificar a sequência atual
SELECT last_value FROM comanda_id_comanda_seq;

-- RODAR UM POR VEZ
-- Ajustar a sequência para o maior valor + 1 na tabela comanda
SELECT setval('comanda_id_comanda_seq', (SELECT MAX(id_comanda) FROM comanda) + 1);


-- ##########################################################################################################################################################
-- INSERTS
-- ##########################################################################################################################################################
insert into cargo (id_cargo, cargo) values 
                  (1, 'Gerente'), 
                  (2, 'Funcionário'),
                  (3, 'Cliente');

insert into comanda (id_comanda) select * from generate_series(1,100);


insert into usuario (nome, cpf, senha, email, telefone, cargo_id, status) values 
                    ('Julia', '662.929.240-50', 'senhavalida', 'juju@gmail.com', 49938768385, 3, true),
                    ('Gatinha Comunista', '571.049.780-03', 'senhavalida', 'gata@gmail.com',97933515513, 3, true),
                    ('Bruno', '172.336.570-09', 'senhavalida', 'brunao@gmail.com',62323278913 , 1, true),
                    ('Fran', '001.720.750-92', 'senhavalida', 'fran@gmail.com',12345678910 , 2, true);
