
USE village;

INSTALL EXTENSION vsql_ai;

SET @key='SUA_API_KEY';

SELECT ai_prompt(
  'google',
  'gemini-2.5-flash',
  @key,
  'Responda positivo ou negativo: Produto excelente'
);
