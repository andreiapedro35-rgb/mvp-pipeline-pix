-- Databricks notebook source
-- MAGIC %md
-- MAGIC Como evoluiu a quantidade de transações Pix ao longo do período analisado?
-- MAGIC A consulta apresenta a quantidade total de transações Pix por mês, permitindo avaliar sua evolução entre novembro de 2020 e agosto de 2026.

-- COMMAND ----------

SELECT
    TO_DATE(CONCAT(CAST(AnoMes AS STRING), '01'), 'yyyyMMdd') AS mes,
    total_transacoes
FROM workspace.default.gold_pix_mensal
ORDER BY mes;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC A quantidade de transações Pix apresentou forte crescimento ao longo do período analisado. Os dados mostram uma trajetória predominantemente crescente entre novembro de 2020 e agosto de 2026, apesar de algumas oscilações mensais. O resultado evidencia a expansão da quantidade de operações realizadas por meio do Pix ao longo dos anos.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Como evoluiu o volume financeiro movimentado via Pix?
-- MAGIC A consulta apresenta o volume financeiro total movimentado mensalmente por meio do Pix, permitindo analisar sua evolução ao longo do período estudado.

-- COMMAND ----------

SELECT
    TO_DATE(CONCAT(CAST(AnoMes AS STRING), '01'), 'yyyyMMdd') AS mes,
    volume_financeiro
FROM workspace.default.gold_pix_mensal
ORDER BY mes;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC O volume financeiro movimentado por meio do Pix também apresentou crescimento significativo ao longo do período analisado. Apesar de oscilações em alguns meses, observa-se uma tendência geral de aumento, acompanhando a expansão da utilização do Pix.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Como evoluiu o valor médio das transações Pix?
-- MAGIC A análise busca verificar como o valor médio de cada transação Pix se comportou ao longo do período estudado.

-- COMMAND ----------

SELECT
    TO_DATE(CONCAT(CAST(AnoMes AS STRING), '01'), 'yyyyMMdd') AS mes,
    valor_medio
FROM workspace.default.gold_pix_mensal
ORDER BY mes;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC O valor médio das transações Pix apresentou forte redução nos primeiros anos analisados, partindo de aproximadamente R$ 876 em novembro de 2020 e chegando posteriormente a valores próximos de R$ 400. Após a queda inicial, observa-se maior estabilidade, com pequenas oscilações ao longo do tempo. 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Quais naturezas de transação possuem maior participação?
-- MAGIC A análise compara as diferentes naturezas das transações Pix para identificar quais concentram a maior quantidade de operações.

-- COMMAND ----------

SELECT
    NATUREZA,
    total_transacoes,
    volume_financeiro,
    valor_medio
FROM workspace.default.gold_pix_natureza
ORDER BY total_transacoes DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC A análise mostra que as transações P2P (pessoa para pessoa) apresentam a maior quantidade de operações no período analisado, com aproximadamente 121,66 bilhões de transações, seguidas pelas operações P2B (pessoa para empresa), com aproximadamente 94,74 bilhões. As demais naturezas apresentam participação significativamente menor em quantidade de transações. O resultado evidencia a predominância das transações P2P e P2B no conjunto de dados analisado.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Como o volume financeiro das transações Pix difere entre pessoas físicas e pessoas jurídicas?

-- COMMAND ----------

SELECT
    tipo_pagador,
    total_transacoes,
    volume_financeiro,
    valor_medio
FROM workspace.default.gold_pix_tipo_pagador
ORDER BY total_transacoes DESC;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Em relação ao volume financeiro movimentado, as pessoas jurídicas (PJ) apresentaram o maior valor no período analisado, com aproximadamente R$ 60,13 trilhões, enquanto as pessoas físicas (PF) movimentaram aproximadamente R$ 43,77 trilhões. Dessa forma, as pessoas jurídicas se destacaram pelo maior volume financeiro movimentado no período analisado.