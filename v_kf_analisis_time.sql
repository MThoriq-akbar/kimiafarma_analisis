WITH
t AS (
  SELECT
    CAST(transaction_id AS STRING) AS transaction_id,
    DATE(date)                     AS date,
    CAST(branch_id  AS STRING)     AS branch_id_raw,
    CAST(product_id AS STRING)     AS product_id_raw,
    customer_name,
    CAST(discount_percentage AS FLOAT64) AS discount_percentage,
    CAST(rating AS FLOAT64)             AS rating_transaksi
  FROM `kimia-farma-476019.kimia_farma_analysis.kf_final_transaksi`
),
p AS (
  SELECT
    CAST(product_id AS STRING)     AS product_id_raw,
    product_name,
    CAST(price AS FLOAT64)         AS price
  FROM `kimia-farma-476019.kimia_farma_analysis.kf_product`
),
c AS (
  SELECT
    CAST(branch_id AS STRING)      AS branch_id_raw,
    branch_name, kota, provinsi,
    CAST(rating AS FLOAT64)        AS rating_cabang
  FROM `kimia-farma-476019.kimia_farma_analysis.kf_kantor_cabang`
),
tn AS (
  SELECT
    transaction_id, date, customer_name, discount_percentage, rating_transaksi,
    -- NORMALIZE key
    REGEXP_REPLACE(UPPER(TRIM(branch_id_raw)),  r'[^A-Z0-9]', '') AS branch_id_key,
    REGEXP_REPLACE(UPPER(TRIM(product_id_raw)), r'[^A-Z0-9]', '') AS product_id_key,
    branch_id_raw AS branch_id,     -- simpan raw untuk referensi
    product_id_raw AS product_id
  FROM t
),
pn AS (
  SELECT
    REGEXP_REPLACE(UPPER(TRIM(product_id_raw)), r'[^A-Z0-9]', '') AS product_id_key,
    product_name,
    price
  FROM p
),
cn AS (
  SELECT
    REGEXP_REPLACE(UPPER(TRIM(branch_id_raw)),  r'[^A-Z0-9]', '') AS branch_id_key,
    branch_name, kota, provinsi, rating_cabang
  FROM c
)
SELECT
  -- Kolom wajib (sesuai challenge)
  tn.transaction_id,
  tn.date,
  tn.branch_id,
  cn.branch_name,
  cn.kota,
  cn.provinsi,
  cn.rating_cabang,
  tn.customer_name,
  tn.product_id,
  pn.product_name,
  pn.price AS actual_price,
  tn.discount_percentage,
  CASE
    WHEN pn.price <=  50000 THEN 0.10
    WHEN pn.price <= 100000 THEN 0.15
    WHEN pn.price <= 300000 THEN 0.20
    WHEN pn.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS persentase_gross_laba,
  (pn.price * (1 - (tn.discount_percentage / 100.0))) AS nett_sales,
  (pn.price * (1 - (tn.discount_percentage / 100.0))) *
  CASE
    WHEN pn.price <=  50000 THEN 0.10
    WHEN pn.price <= 100000 THEN 0.15
    WHEN pn.price <= 300000 THEN 0.20
    WHEN pn.price <= 500000 THEN 0.25
    ELSE 0.30
  END AS nett_profit,
  tn.rating_transaksi,

  -- Turunan waktu
  EXTRACT(YEAR  FROM tn.date)                  AS tahun,
  EXTRACT(MONTH FROM tn.date)                  AS bulan,
  FORMAT_DATE('%Y-%m', tn.date)                AS periode

FROM tn
LEFT JOIN pn ON tn.product_id_key = pn.product_id_key
LEFT JOIN cn ON tn.branch_id_key  = cn.branch_id_key
