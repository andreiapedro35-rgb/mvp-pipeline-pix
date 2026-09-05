-- Databricks notebook source
SELECT
    AnoMes,
    SUM(QUANTIDADE) AS total_transacoes
FROM workspace.default.silver_pix
GROUP BY AnoMes
ORDER BY AnoMes;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Consulta inicial para verificar a evolução da quantidade total de transações Pix por mês.

-- COMMAND ----------

SELECT
    AnoMes,
    SUM(QUANTIDADE) AS total_transacoes,
    SUM(VALOR) AS volume_financeiro,
    SUM(VALOR) / SUM(QUANTIDADE) AS valor_medio
FROM workspace.default.silver_pix
GROUP BY AnoMes
ORDER BY AnoMes;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Consulta para calcular, por mês, a quantidade total de transações, o volume financeiro movimentado e o valor médio das transações Pix.

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.default.gold_pix_mensal
USING DELTA
AS
SELECT
    AnoMes,
    SUM(QUANTIDADE) AS total_transacoes,
    SUM(VALOR) AS volume_financeiro,
    ROUND(SUM(VALOR) / SUM(QUANTIDADE), 2) AS valor_medio
FROM workspace.default.silver_pix
GROUP BY AnoMes;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Criação da tabela gold_pix_mensal, consolidando os principais indicadores mensais para utilização nas análises do projeto.

-- COMMAND ----------

SELECT
    COUNT(*) AS total_meses,
    MIN(AnoMes) AS primeiro_periodo,
    MAX(AnoMes) AS ultimo_periodo
FROM workspace.default.gold_pix_mensal;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validação da tabela Gold mensal, verificando a quantidade de meses e o período inicial e final disponível na base.

-- COMMAND ----------

SELECT
    NATUREZA,
    SUM(QUANTIDADE) AS total_transacoes,
    SUM(VALOR) AS volume_financeiro
FROM workspace.default.silver_pix
GROUP BY NATUREZA
ORDER BY total_transacoes DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Consulta para identificar a quantidade de transações e o volume financeiro de cada natureza de transação Pix.

-- COMMAND ----------

SELECT
    PAG_PFPJ AS tipo_pagador,
    SUM(QUANTIDADE) AS total_transacoes,
    SUM(VALOR) AS volume_financeiro,
    ROUND(SUM(VALOR) / SUM(QUANTIDADE), 2) AS valor_medio
FROM workspace.default.silver_pix
GROUP BY PAG_PFPJ
ORDER BY total_transacoes DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Consulta para comparar quantidade de transações, volume financeiro e valor médio de acordo com o tipo de pagador.

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.default.gold_pix_natureza
USING DELTA
AS
SELECT
    NATUREZA,
    SUM(QUANTIDADE) AS total_transacoes,
    SUM(VALOR) AS volume_financeiro,
    ROUND(SUM(VALOR) / SUM(QUANTIDADE), 2) AS valor_medio
FROM workspace.default.silver_pix
GROUP BY NATUREZA;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Criação da tabela gold_pix_natureza, contendo indicadores consolidados por natureza da transação.

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.default.gold_pix_tipo_pagador
USING DELTA
AS
SELECT
    PAG_PFPJ AS tipo_pagador,
    SUM(QUANTIDADE) AS total_transacoes,
    SUM(VALOR) AS volume_financeiro,
    ROUND(SUM(VALOR) / SUM(QUANTIDADE), 2) AS valor_medio
FROM workspace.default.silver_pix
GROUP BY PAG_PFPJ;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Criação da tabela gold_pix_tipo_pagador, consolidando os indicadores de transações Pix de acordo com o tipo de pagador.

-- COMMAND ----------

SELECT 'gold_pix_mensal' AS tabela, COUNT(*) AS registros
FROM workspace.default.gold_pix_mensal

UNION ALL

SELECT 'gold_pix_natureza', COUNT(*)
FROM workspace.default.gold_pix_natureza

UNION ALL

SELECT 'gold_pix_tipo_pagador', COUNT(*)
FROM workspace.default.gold_pix_tipo_pagador;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validação final das tabelas Gold, verificando a quantidade de registros gerados em cada agregação.

-- COMMAND ----------

DESCRIBE TABLE workspace.default.gold_pix_mensal;


-- COMMAND ----------

DESCRIBE TABLE workspace.default.gold_pix_natureza;

-- COMMAND ----------

DESCRIBE TABLE workspace.default.gold_pix_tipo_pagador;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validação da estrutura das tabelas Gold
-- MAGIC Foram consultados os metadados das três tabelas da camada Gold para documentar seus campos, tipos de dados e finalidade no catálogo de dados do projeto.