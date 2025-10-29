SELECT
  provinsi,
  SUM(nett_profit) AS total_profit
FROM `kimia-farma-476019.kimia_farma_analysis.v_kf_analisis_time`
WHERE provinsi IS NOT NULL
GROUP BY provinsi
ORDER BY total_profit DESC
