
# RUNBOOK COMPLETO

## 1. Subir ambiente
docker compose up -d

## 2. Entrar no MySQL
docker exec -it villagesql mysql -uvillage -pvillage -A

## 3. Instalar extensões
INSTALL EXTENSION vsql_uuid;
INSTALL EXTENSION vsql_ai;

## 4. Instalar HTTP
bash extensions/install_http.sh
INSTALL EXTENSION vsql_http;

## 5. Baixar modelo
docker exec -it ollama ollama pull phi3:mini

## 6. Criar procedures
source procedures/ollama_prompt.sql;
source procedures/sentimento_llama.sql;

## 7. Testar IA
CALL ollama_prompt('Responda ok', @r);
SELECT @r;

## 8. Classificação
CALL prc_sentimento_llama();

## 9. UUID
source examples/uuid.sql;

## 10. Crypto
bash extensions/install_crypto.sh
INSTALL EXTENSION vsql_crypto;
source examples/crypto.sql;
