{{
    config(
        materialized='incremental',
        on_schema_change='fail'
    )
}}
WITH src_reviews AS (
    SELECT * FROM {{ ref('src_reviews') }}
)
SELECT * from src_reviews
WHERE review_text is not NULL
{% if is_incremental() %}
    AND review_date > (SELECT MAX(review_date) FROM {{ this }})
{% endif %}