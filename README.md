# VillageSQL Lab — Runbook Completo

Projeto de laboratório utilizando MySQL com extensões do VillageSQL, integração com IA local utilizando Ollama e modelo LLM, além de exemplos de UUID, criptografia e classificação de sentimentos.

---

# Visão Geral do Projeto

Este laboratório demonstra como estender o MySQL com funcionalidades modernas utilizando o ecossistema do VillageSQL.

O ambiente contempla:

* MySQL com extensões VillageSQL
* Integração com IA local via Ollama
* Geração de UUIDs
* Criptografia de dados
* Procedures inteligentes
* Classificação de sentimentos
* Comunicação HTTP diretamente do MySQL
* Execução de LLM local sem dependência de APIs externas

---

# Arquitetura do Ambiente

O ambiente é composto pelos seguintes containers:

| Serviço              | Função                                           |
| -------------------- | ------------------------------------------------ |
| MySQL / VillageSQL   | Banco de dados principal                         |
| Ollama               | Execução local do modelo LLM                     |
| Extensões VillageSQL | Recursos adicionais para IA, HTTP, UUID e Crypto |

Fluxo principal:

```text
MySQL (VillageSQL)
        │
        │ HTTP POST
        ▼
Ollama API
        │
        ▼
Modelo phi3:mini
        │
        ▼
Resposta retornando ao MySQL
```

---

# Pré-requisitos

Antes de iniciar, é recomendado possuir:

* Docker
* Docker Compose
* Git
* Linux, WSL ou ambiente compatível

Verifique:

```bash
docker --version
docker compose version
```

---

# Estrutura Recomendada do Projeto

```text
villagesql_lab/
├── docker-compose.yml
├── extensions/
│   ├── install_http.sh
│   └── install_crypto.sh
├── procedures/
│   ├── ollama_prompt.sql
│   └── sentimento_llama.sql
├── examples/
│   ├── uuid.sql
│   └── crypto.sql
└── README.md
```

---

# RUNBOOK COMPLETO

# 1. Subir o ambiente

Inicialize todos os containers:

```bash
docker compose up -d
```

Verifique os containers:

```bash
docker ps
```

Containers esperados:

* villagesql
* ollama

---

# 2. Entrar no MySQL

Acesse o banco de dados:

```bash
docker exec -it villagesql mysql -uvillage -pvillage -A
```

Parâmetros:

| Parâmetro | Descrição                                       |
| --------- | ----------------------------------------------- |
| -u        | Usuário                                         |
| -p        | Senha                                           |
| -A        | Desabilita auto-complete para login mais rápido |

---

# 3. Instalar extensões VillageSQL

Instale as extensões principais:

```sql
INSTALL EXTENSION vsql_uuid;
INSTALL EXTENSION vsql_ai;
```

## vsql_uuid

Adiciona suporte avançado para geração de UUID.

## vsql_ai

Adiciona funcionalidades de IA diretamente no MySQL.

---

# 4. Instalar suporte HTTP
# Instalar vsql_http (compilação)
# Entrar no container

```bash
docker exec -it villagesql bash
```

# Instalar dependências
```bash
apt-get update && apt-get install -y \
git cmake g++ libcurl4-openssl-dev pkg-config make
```
# Clonar e compilar
```bash
cd /tmp
git clone https://github.com/villagesql/vsql-http.git
cd vsql-http
```
# aumentar o tempo de resposta
```bash
sed -i 's/long timeout_s = 30/long timeout_s = 90/g' src/vsql_http.cc

vsql-build-extension.sh /tmp/vsql-http
exit
```
# Instalar no MySQL
```bash
docker exec -it villagesql mysql -uvillage -pvillage -A
INSTALL EXTENSION vsql_http;
```
---

# O que o vsql_http permite?

A extensão HTTP possibilita:

* Chamadas REST
* Integração com APIs
* Comunicação com Ollama
* Integração com IA local
* Consumo de serviços externos

Exemplo conceitual:

```sql
SELECT http_post(...);
```

---

# 5. Baixar modelo de IA

Baixe o modelo local:

```bash
docker exec -it ollama ollama pull phi3:mini
```

---

# Sobre o modelo phi3:mini

O modelo Phi-3 Mini é um LLM leve e rápido, ideal para laboratórios locais.

Vantagens:

* Baixo consumo de memória
* Respostas rápidas
* Excelente para testes locais
* Integração simples com Ollama
* Funciona offline

---

# 6. Criar procedures

Execute as procedures:

```sql
docker exec -i villagesql mysql -uvillage -pvillage village < procedures/ollama_prompt.sql
docker exec -i villagesql mysql -uvillage -pvillage village < procedures/gemini_sentimento.sql
docker exec -i villagesql mysql -uvillage -pvillage village < procedures/sentimento_llama.sql
```

---

# Procedure ollama_prompt

Esta procedure:

* Envia prompts para o Ollama
* Recebe respostas do modelo
* Integra IA diretamente no MySQL

Fluxo:

```text
MySQL Procedure
      ↓
HTTP POST
      ↓
Ollama API
      ↓
LLM responde
      ↓
Resultado retorna ao MySQL
```

---

# Procedure sentimento_llama

Procedure responsável por:

* Analisar sentimentos
* Classificar textos
* Utilizar IA local para inferência

Classificações possíveis:

* Positivo
* Negativo
* Neutro

---

# 7. Testar IA

Teste a integração:

```sql
CALL ollama_prompt('Responda ok', @r);
SELECT @r;
```

Resultado esperado:

```text
ok
```

---

# Como funciona o teste?

A procedure:

1. Recebe um prompt
2. Faz requisição HTTP
3. Envia ao Ollama
4. O modelo processa
5. O resultado retorna ao MySQL

Tudo isso diretamente do banco de dados.

---

# 8. Executar classificação de sentimentos

Execute:

```sql
mysql> show tables;
+-------------------+
| Tables_in_village |
+-------------------+
| avaliacoes        |
| avaliacoes_gemini |
| avaliacoes_llama  |
+-------------------+
3 rows in set (0.02 sec)

mysql> select * from avaliacoes_llama;
+----+------------------+---------------------------------+------------+---------------------+
| id | produto          | texto                           | sentimento | criado_em           |
+----+------------------+---------------------------------+------------+---------------------+
|  1 | Fone BT X200     | Chegou rapido, som excelente!   | NULL       | 2026-05-09 19:46:48 |
|  2 | Tenis Runner Pro | Veio com defeito, decepcionante | NULL       | 2026-05-09 19:46:48 |
|  3 | Mochila Urbana   | Qualidade razoavel pelo preco   | NULL       | 2026-05-09 19:46:48 |
+----+------------------+---------------------------------+------------+---------------------+
3 rows in set (0.02 sec)

mysql> call prc_sentimento_llama();
+--------------------------------------------------+
| resultado                                        |
+--------------------------------------------------+
| ID 1 | Chegou rapido, som excelente! -> positivo |
+--------------------------------------------------+
1 row in set (9.11 sec)

+----------------------------------------------------+
| resultado                                          |
+----------------------------------------------------+
| ID 2 | Veio com defeito, decepcionante -> negativo |
+----------------------------------------------------+
1 row in set (12.75 sec)

+----------------------------------------------------+
| resultado                                          |
+----------------------------------------------------+
| ID 3 | Qualidade razoavel pelo preco -> indefinido |
+----------------------------------------------------+
1 row in set (1 min 50.33 sec)

Query OK, 0 rows affected (1 min 50.34 sec)

------------
mysql> select * from avaliacoes_llama;
+----+------------------+---------------------------------+------------+---------------------+
| id | produto          | texto                           | sentimento | criado_em           |
+----+------------------+---------------------------------+------------+---------------------+
|  1 | Fone BT X200     | Chegou rapido, som excelente!   | positivo   | 2026-05-09 19:46:48 |
|  2 | Tenis Runner Pro | Veio com defeito, decepcionante | negativo   | 2026-05-09 19:46:48 |
|  3 | Mochila Urbana   | Qualidade razoavel pelo preco   | indefinido | 2026-05-09 19:46:48 |
+----+------------------+---------------------------------+------------+---------------------+
3 rows in set (0.00 sec)
-------------

mysql> select * from avaliacoes_gemini;
+----+------------------+---------------------------------+------------+---------------------+
| id | produto          | texto                           | sentimento | criado_em           |
+----+------------------+---------------------------------+------------+---------------------+
|  1 | Fone BT X200     | Chegou rapido, som excelente!   | NULL       | 2026-05-09 19:46:48 |
|  2 | Tenis Runner Pro | Veio com defeito, decepcionante | NULL       | 2026-05-09 19:46:48 |
|  3 | Mochila Urbana   | Qualidade razoavel pelo preco   | NULL       | 2026-05-09 19:46:48 |
+----+------------------+---------------------------------+------------+---------------------+
3 rows in set (0.01 sec)

mysql> call prc_sentimento_gemini('Sua_chave_gemini');
+--------------------------------------------------+
| resultado                                        |
+--------------------------------------------------+
| ID 1 | Chegou rapido, som excelente! -> positivo |
+--------------------------------------------------+
1 row in set (1.83 sec)

+----------------------------------------------------+
| resultado                                          |
+----------------------------------------------------+
| ID 2 | Veio com defeito, decepcionante -> negativo |
+----------------------------------------------------+
1 row in set (3.14 sec)

+------------------------------------------------+
| resultado                                      |
+------------------------------------------------+
| ID 3 | Qualidade razoavel pelo preco -> neutro |
+------------------------------------------------+
1 row in set (5.90 sec)

Query OK, 0 rows affected (5.90 sec)

----------------
mysql> select * from avaliacoes_gemini;
+----+------------------+---------------------------------+------------+---------------------+
| id | produto          | texto                           | sentimento | criado_em           |
+----+------------------+---------------------------------+------------+---------------------+
|  1 | Fone BT X200     | Chegou rapido, som excelente!   | positivo   | 2026-05-09 19:46:48 |
|  2 | Tenis Runner Pro | Veio com defeito, decepcionante | negativo   | 2026-05-09 19:46:48 |
|  3 | Mochila Urbana   | Qualidade razoavel pelo preco   | neutro     | 2026-05-09 19:46:48 |
+----+------------------+---------------------------------+------------+---------------------+
3 rows in set (0.00 sec)

```
# Exemplo de classificação

Entrada:

```text
Produto excelente
```

Saída:

```text
positivo
```

Outro exemplo:

```text
Produto horrível
```

Saída:

```text
negativo
```

---

# 9. Trabalhando com UUID

Execute:

```sql
source examples/uuid.sql;
```

---

# Benefícios do UUID

UUIDs são importantes para:

* Sistemas distribuídos
* Alta disponibilidade
* Replicação
* Evitar colisões
* Segurança
* APIs modernas

Exemplo conceitual:

```sql
SELECT uuid_v4();
```

---

# 10. Trabalhando com criptografia

Instale a extensão:

```sql
INSTALL EXTENSION vsql_crypto;
```

Execute os exemplos:

```sql
source examples/crypto.sql;
```

---

# Recursos de criptografia

O módulo crypto possibilita:

* Criptografia de dados
* Hashes
* Segurança de informações
* Proteção de dados sensíveis

Possíveis usos:

* CPF
* Senhas
* Tokens
* Dados pessoais
* APIs seguras

---

# Exemplo conceitual de criptografia

```sql
SELECT encrypt('dados');
```

Exemplo de retorno:

```text
D57A29A3320EFA5868E3DA47E0226BD7...
```

---

# Casos de Uso do Projeto

Este laboratório pode ser utilizado para:

* Estudos de IA integrada ao banco
* Demonstrações técnicas
* Artigos técnicos
* Apresentações
* Provas de conceito
* Laboratórios educacionais
* Testes locais de LLM
* Pesquisa em banco de dados inteligente

---

# Diferenciais do Projeto

## IA local integrada ao MySQL

Sem dependência de APIs pagas.

## Execução offline

O modelo roda localmente.

## Banco de dados inteligente

MySQL executando inferência diretamente.

## Arquitetura moderna

Integração via HTTP + LLM.

## Extensível

Pode ser adaptado para:

* Chatbots
* Classificadores
* Sistemas analíticos
* APIs inteligentes
* RAG
* Assistentes internos

---

# Possíveis Evoluções

O laboratório pode evoluir para:

* RAG com documentos
* Vetorização
* Embeddings
* IA generativa no banco
* ProxySQL + IA
* Cache inteligente
* Classificação automática de tickets
* Auditoria inteligente
* Análise de logs
* Observabilidade com IA

---

# Troubleshooting

# Container não sobe

Verifique logs:

```bash
docker logs villagesql
docker logs ollama
```

---

# Ollama não responde

Teste:

```bash
curl http://localhost:11434/api/tags
```

---

# Modelo não encontrado

Baixe novamente:

```bash
docker exec -it ollama ollama pull phi3:mini
```

---

# Erro na extensão

Verifique extensões instaladas:

```sql
SHOW EXTENSIONS;
```

---

# Conceitos Técnicos Utilizados

| Tecnologia       | Finalidade             |
| ---------------- | ---------------------- |
| Docker           | Containers             |
| MySQL            | Banco de dados         |
| VillageSQL       | Extensões avançadas    |
| Ollama           | Execução local de LLM  |
| Phi3 Mini        | Modelo de IA           |
| HTTP Extension   | Integração REST        |
| Crypto Extension | Segurança              |
| UUID Extension   | Identificadores únicos |

---

# Conceito Central

O principal objetivo deste laboratório é demonstrar que:

> O banco de dados pode se tornar uma plataforma inteligente capaz de consumir IA local diretamente via SQL.

---

# Autor

Projeto desenvolvido por:
**Marcio Costa**

Este projeto possui caráter didático e tem como objetivo explorar funcionalidades modernas do VillageSQL na prática, incluindo integrações HTTP via SQL, recursos de IA com Ollama, UUID v7 e extensões avançadas sobre o MySQL.

A proposta é permitir estudos, testes e demonstrações técnicas utilizando recursos modernos e experimentais voltados para automação, APIs e novas possibilidades dentro do ecossistema MySQL.

---

# Conclusão

Este laboratório demonstra uma abordagem moderna para bancos de dados inteligentes utilizando:

* MySQL
* VillageSQL
* IA Local
* Ollama
* LLMs
* Procedures inteligentes
* Extensões avançadas

Tudo isso executando localmente com Docker e SQL.
