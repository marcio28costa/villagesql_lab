
CREATE DATABASE IF NOT EXISTS village;
USE village;

CREATE TABLE avaliacoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto VARCHAR(100),
  texto TEXT,
  sentimento VARCHAR(50),
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE avaliacoes_llama LIKE avaliacoes;
CREATE TABLE avaliacoes_gemini LIKE avaliacoes;
