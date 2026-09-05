-- Databricks notebook source
SELECT *
FROM read_files(
  '/Volumes/workspace/default/pix_raw/*.csv',
  format => 'csv',
  header => true
)
LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Realizar uma leitura inicial do arquivo CSV armazenado no volume pix_raw. A consulta foi limitada a 10 registros para validar se o arquivo poderia ser acessado corretamente e visualizar sua estrutura antes da criação da tabela Bronze.

-- COMMAND ----------

SELECT *
FROM read_files(
  '/Volumes/workspace/default/pix_raw/*.csv',
  format => 'csv',
  header => true
)
LIMIT 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Visualizar todas as colunas existentes no arquivo e identificar os campos disponíveis para o projeto. 

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.default.bronze_pix
USING DELTA
AS
SELECT *
FROM read_files(
  '/Volumes/workspace/default/pix_raw/*.csv',
  format => 'csv',
  header => true
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Criar a camada Bronze a partir do arquivo CSV original armazenado no volume pix_raw. Os dados foram carregados e mantidos próximos ao formato de origem, sem aplicação de tratamentos ou regras de negócio.

-- COMMAND ----------

SELECT COUNT(*) AS total_registros
FROM workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validar a quantidade de registros carregados. A consulta confirmou a existência de 741.383 registros na tabela

-- COMMAND ----------

SELECT
    MIN(AnoMes) AS primeiro_periodo,
    MAX(AnoMes) AS ultimo_periodo,
    COUNT(*) AS total_registros
FROM workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validar o intervalo de tempo e a quantidade de dados após a carga. Foi identificado que a base possui 741.383 registros, compreendendo o período de novembro de 2020 a agosto de 2026.

-- COMMAND ----------

DESCRIBE TABLE workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validação da estrutura da tabela Bronze
-- MAGIC Foi utilizado o comando DESCRIBE TABLE para consultar os metadados da tabela e identificar as colunas e seus respectivos tipos de dados. Essas informações foram utilizadas posteriormente na elaboração do catálogo de dados.