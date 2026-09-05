-- Databricks notebook source
SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN AnoMes IS NULL THEN 1 ELSE 0 END) AS nulos_anomes,
    SUM(CASE WHEN PAG_PFPJ IS NULL THEN 1 ELSE 0 END) AS nulos_pag_pfpj,
    SUM(CASE WHEN REC_PFPJ IS NULL THEN 1 ELSE 0 END) AS nulos_rec_pfpj,
    SUM(CASE WHEN PAG_REGIAO IS NULL THEN 1 ELSE 0 END) AS nulos_pag_regiao,
    SUM(CASE WHEN REC_REGIAO IS NULL THEN 1 ELSE 0 END) AS nulos_rec_regiao,
    SUM(CASE WHEN VALOR IS NULL THEN 1 ELSE 0 END) AS nulos_valor,
    SUM(CASE WHEN QUANTIDADE IS NULL THEN 1 ELSE 0 END) AS nulos_quantidade
FROM workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Checar o preenchimento dos dados antes da criação da camada Silver. Foram verificados valores nulos nos principais campos utilizados no projeto enão foram encontrados valores nulos nas colunas analisadas.

-- COMMAND ----------

SELECT
    PAG_REGIAO,
    COUNT(*) AS quantidade
FROM workspace.default.bronze_pix
GROUP BY PAG_REGIAO
ORDER BY quantidade DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Verificar a consistência dos valores existentes na região do pagador. Apesar de não existirem valores nulos, foram identificados 101.093 registros classificados como “Nao informado”. Esses registros foram mantidos para preservar a informação original da fonte.

-- COMMAND ----------

SELECT
    REC_REGIAO,
    COUNT(*) AS quantidade
FROM workspace.default.bronze_pix
GROUP BY REC_REGIAO
ORDER BY quantidade DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Verificar a consistência dos valores da região do recebedor. Foram encontrados 94.196 registros classificados como “Nao informado”. Assim como na região do pagador, esses registros foram preservados.

-- COMMAND ----------

SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT
        AnoMes,
        PAG_PFPJ,
        REC_PFPJ,
        PAG_REGIAO,
        REC_REGIAO,
        PAG_IDADE,
        REC_IDADE,
        FORMAINICIACAO,
        NATUREZA,
        FINALIDADE,
        VALOR,
        QUANTIDADE
    ) AS registros_distintos
FROM workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Identificar possíveis registros completamente duplicados na base. A comparação apresentou 741.383 registros totais e 741.383 registros distintos, indicando ausência de duplicidades completas.

-- COMMAND ----------

DESCRIBE TABLE workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Conferir o formato dos dados recebidos. Foi identificado que VALOR estava armazenado como string, enquanto QUANTIDADE e AnoMes foram reconhecidos como int. Por representar um valor financeiro, foi necessário preparar a conversão de VALOR para um tipo numérico.

-- COMMAND ----------

SELECT
    VALOR AS valor_original,
    CAST(REPLACE(VALOR, ',', '.') AS DECIMAL(18,2)) AS valor_convertido
FROM workspace.default.bronze_pix
LIMIT 10;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Testar a conversão da coluna VALOR de texto para número decimal. Como os valores utilizam vírgula como separador decimal, a vírgula foi substituída por ponto antes da conversão para DECIMAL(18,2). A amostra confirmou que a transformação estava funcionando corretamente.

-- COMMAND ----------

SELECT
    COUNT(*) AS total_registros,
    SUM(
        CASE 
            WHEN TRY_CAST(REPLACE(VALOR, ',', '.') AS DECIMAL(18,2)) IS NULL
            THEN 1 
            ELSE 0 
        END
    ) AS valores_invalidos
FROM workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validar a conversão da coluna VALOR em todos os registros antes de realizar a transformação definitiva. O teste analisou os 741.383 registros e não identificou nenhum valor inválido para conversão.

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.default.silver_pix
USING DELTA
AS
SELECT
    AnoMes,
    PAG_PFPJ,
    REC_PFPJ,
    PAG_REGIAO,
    REC_REGIAO,
    PAG_IDADE,
    REC_IDADE,
    FORMAINICIACAO,
    NATUREZA,
    FINALIDADE,
    CAST(REPLACE(VALOR, ',', '.') AS DECIMAL(18,2)) AS VALOR,
    QUANTIDADE
FROM workspace.default.bronze_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Criar a camada Silver contendo os dados tratados e preparados para análise. A coluna VALOR foi convertida para DECIMAL(18,2) e a coluna técnica _rescued_data não foi incluída, mantendo apenas os 12 campos de negócio necessários.

-- COMMAND ----------

SELECT
    COUNT(*) AS total_registros,
    MIN(AnoMes) AS primeiro_periodo,
    MAX(AnoMes) AS ultimo_periodo
FROM workspace.default.silver_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validar se a transformação Bronze → Silver manteve a integridade da carga. A tabela Silver permaneceu com 741.383 registros, abrangendo o mesmo período de novembro de 2020 a agosto de 2026, indicando que não houve perda de registros durante o tratamento.

-- COMMAND ----------

DESCRIBE TABLE workspace.default.silver_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validar a estrutura final e os tipos de dados após o tratamento. A consulta confirmou que VALOR passou a ser DECIMAL(18,2), QUANTIDADE permaneceu como INT e a tabela final contém apenas as 12 colunas de negócio.

-- COMMAND ----------

DESCRIBE TABLE workspace.default.silver_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validação da estrutura da tabela Silver
-- MAGIC A estrutura da tabela Silver foi consultada para verificar os tipos de dados após as transformações realizadas e apoiar a documentação do catálogo de dados.

-- COMMAND ----------

SELECT DISTINCT PAG_PFPJ
FROM workspace.default.silver_pix
ORDER BY PAG_PFPJ;

-- COMMAND ----------

SELECT DISTINCT REC_PFPJ
FROM workspace.default.silver_pix
ORDER BY REC_PFPJ;

-- COMMAND ----------

SELECT DISTINCT PAG_REGIAO
FROM workspace.default.silver_pix
ORDER BY PAG_REGIAO;

-- COMMAND ----------

SELECT DISTINCT REC_REGIAO
FROM workspace.default.silver_pix
ORDER BY REC_REGIAO;

-- COMMAND ----------

SELECT DISTINCT NATUREZA
FROM workspace.default.silver_pix
ORDER BY NATUREZA;

-- COMMAND ----------

SELECT DISTINCT FINALIDADE
FROM workspace.default.silver_pix
ORDER BY FINALIDADE;

-- COMMAND ----------

SELECT DISTINCT FORMAINICIACAO
FROM workspace.default.silver_pix
ORDER BY FORMAINICIACAO;

-- COMMAND ----------

SELECT
    MIN(AnoMes) AS menor_periodo,
    MAX(AnoMes) AS maior_periodo,
    MIN(VALOR) AS menor_valor,
    MAX(VALOR) AS maior_valor,
    MIN(QUANTIDADE) AS menor_quantidade,
    MAX(QUANTIDADE) AS maior_quantidade
FROM workspace.default.silver_pix;

-- COMMAND ----------

SELECT DISTINCT PAG_IDADE
FROM workspace.default.silver_pix
ORDER BY PAG_IDADE;

-- COMMAND ----------

SELECT DISTINCT REC_IDADE
FROM workspace.default.silver_pix
ORDER BY REC_IDADE;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Verificação complementar de valores nulos
-- MAGIC
-- MAGIC Durante a análise dos domínios dos campos categóricos, foram identificados valores nulos nos campos PAG_IDADE, REC_IDADE e FORMAINICIACAO.
-- MAGIC
-- MAGIC Esses registros foram mantidos na camada Silver, pois a ausência dessas informações já está presente nos dados de origem e a remoção dos registros poderia causar perda de informações relevantes para outras análises.

-- COMMAND ----------

SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN PAG_IDADE IS NULL THEN 1 ELSE 0 END) AS nulos_pag_idade,
    SUM(CASE WHEN REC_IDADE IS NULL THEN 1 ELSE 0 END) AS nulos_rec_idade,
    SUM(CASE WHEN FORMAINICIACAO IS NULL THEN 1 ELSE 0 END) AS nulos_formainiciacao
FROM workspace.default.silver_pix;

-- COMMAND ----------

SELECT
    SUM(CASE WHEN LOWER(TRIM(PAG_IDADE)) = 'null' THEN 1 ELSE 0 END) AS texto_null_pag_idade,
    SUM(CASE WHEN LOWER(TRIM(REC_IDADE)) = 'null' THEN 1 ELSE 0 END) AS texto_null_rec_idade,
    SUM(CASE WHEN LOWER(TRIM(FORMAINICIACAO)) = 'null' THEN 1 ELSE 0 END) AS texto_null_formainiciacao
FROM workspace.default.silver_pix;

-- COMMAND ----------

SELECT
    MIN(AnoMes) AS menor_periodo,
    MAX(AnoMes) AS maior_periodo,
    FORMAT_NUMBER(MIN(VALOR), 2) AS menor_valor,
    FORMAT_NUMBER(MAX(VALOR), 2) AS maior_valor,
    FORMAT_NUMBER(MIN(QUANTIDADE), 0) AS menor_quantidade,
    FORMAT_NUMBER(MAX(QUANTIDADE), 0) AS maior_quantidade
FROM workspace.default.silver_pix;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Validação dos domínios numéricos
-- MAGIC
-- MAGIC Foi realizada uma consulta para identificar os valores mínimo e máximo dos campos `AnoMes`, `VALOR` e `QUANTIDADE` na tabela `silver_pix`.
-- MAGIC
-- MAGIC Essa verificação foi utilizada para documentar os domínios dos campos numéricos no catálogo de dados.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC