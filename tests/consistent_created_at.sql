-- tests/consistent_created_at.sql
SELECT
  f.*,
  d.created_at
FROM {{ ref('fct_reviews') }} AS f
JOIN {{ ref('dim_listing_cleansed') }} AS d
  ON f.listing_id = d.listing_id
WHERE
  CAST(f.review_date AS DATE) < CAST(d.created_at AS DATE)
LIMIT 10