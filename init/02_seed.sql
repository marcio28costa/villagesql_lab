
USE village;

INSERT INTO avaliacoes (produto, texto) VALUES
('Fone BT X200','Chegou rapido, som excelente!'),
('Tenis Runner Pro','Veio com defeito, decepcionante'),
('Mochila Urbana','Qualidade razoavel pelo preco');

INSERT INTO avaliacoes_llama SELECT * FROM avaliacoes;
INSERT INTO avaliacoes_gemini SELECT * FROM avaliacoes;
