
USE village;

INSTALL EXTENSION vsql_uuid;

CREATE TABLE produtos (
  id UUID PRIMARY KEY,
  nome VARCHAR(100),
  preco DECIMAL(10,2)
);

INSERT INTO produtos VALUES
(UUID_V7(),'Produto A',10.0),
(UUID_V7(),'Produto B',20.0);

SELECT id, UUID_VERSION(id) FROM produtos;
