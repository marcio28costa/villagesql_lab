
USE village;

INSTALL EXTENSION vsql_crypto;

-- Tabela simples
DROP TABLE IF EXISTS usuarios;
CREATE TABLE usuarios (
  id        UUID PRIMARY KEY,
  nome      VARCHAR(100),
  email     VARCHAR(100),
  cpf_hash  VARCHAR(200),   -- hash do CPF para busca
  senha     TEXT            -- hash da senha com PBKDF2
);

-- Inserir com dados protegidos
INSERT INTO usuarios (id, nome, email, cpf_hash, senha) VALUES
(UUID_V7(), 'Joao Silva',  'joao@email.com',  HEX(digest('123.456.789-00', 'sha256')), crypt('senha123',   gen_salt('pbkdf2-sha256', 100000))),
(UUID_V7(), 'Maria Souza', 'maria@email.com', HEX(digest('987.654.321-00', 'sha256')), crypt('maria@2026', gen_salt('pbkdf2-sha256', 100000)));

-- Ver como ficou no banco (CPF virou hash, senha ilegível)
SELECT id, nome, email, cpf_hash, senha FROM usuarios;

-- Buscar por CPF sem armazenar ele
SELECT nome, email
FROM usuarios
WHERE cpf_hash = HEX(digest('987.654.321-00', 'sha256'));

-- Simular login correto
SELECT nome,
  CASE WHEN crypt('senha123', senha) = senha
    THEN 'Login OK'
    ELSE 'Senha incorreta'
  END AS resultado
FROM usuarios WHERE email = 'joao@email.com';

-- Simular login errado
SELECT nome,
  CASE WHEN crypt('senha_errada', senha) = senha
    THEN 'Login OK'
    ELSE 'Senha incorreta'
  END AS resultado
FROM usuarios WHERE email = 'joao@email.com';
