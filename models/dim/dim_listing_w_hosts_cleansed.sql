WITH 
l as (
    SELECT *
    FROM {{ ref('dim_listing_cleansed') }}
),
h as (
    SELECT *
    FROM {{ ref('dim_hosts_cleansed') }}
)
SELECT
    l.listing_id,
    l.listing_name,
    l.room_type,
    l.minimum_nights,
    l.price,
    L.host_id,
    h.host_name,
    h.is_superhost as host_is_superhost,
    l.created_at,
    GREATEST(l.updated_at, h.updated_at) as updated_at
FROM l
LEFT JOIN h ON l.host_id = h.host_id 