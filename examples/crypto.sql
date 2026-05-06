
USE village;

INSTALL EXTENSION vsql_crypto;

SET @chave='chave-secreta';

CREATE TABLE clientes (
  id UUID PRIMARY KEY,
  nome VARCHAR(100),
  cpf_hash VARBINARY(64),
  cpf_cript VARBINARY(512)
);

INSERT INTO clientes VALUES (
  UUID_V7(),
  'Joao',
  digest('12345678900','sha256'),
  encrypt('12345678900',@chave,'aes-256')
);
