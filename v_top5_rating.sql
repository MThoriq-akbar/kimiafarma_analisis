CREATE OR REPLACE VIEW `kimia-farma-476019.kimia_farma_analysis.v_top5_rating` AS
SELECT
  branch_name,
  AVG(rating_cabang)    AS avg_rating_cabang,
  AVG(rating_transaksi) AS avg_rating_transaksi,
  (AVG(rating_cabang) - AVG(rating_transaksi)) AS selisih_rating
FROM `kimia-farma-476019.kimia_farma_analysis.v_kf_analisis_time`
GROUP BY branch_name
ORDER BY selisih_rating DESC
LIMIT 5;
