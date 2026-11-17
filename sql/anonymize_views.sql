-- Drop both views first to start clean
DROP VIEW IF EXISTS anon_analytics_item_performance CASCADE;
DROP VIEW IF EXISTS anon_analytics_product_menu_mix CASCADE;

-- 1. Anonymized Item Performance View (Unique ID per item)
CREATE VIEW anon_analytics_item_performance AS
SELECT 
    operational_period,
    sales_category,
    CASE 
        WHEN standardized_product_name ILIKE '%birria%' THEN 'Slow-Braised Taco - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%taco%' THEN 'Specialty Street Taco - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%modelo%' OR standardized_product_name ILIKE '%beer%' THEN 'Draft Lager - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%pinot%' OR standardized_product_name ILIKE '%wine%' THEN 'House Wine - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%rita%' OR standardized_product_name ILIKE '%oro%' THEN 'Signature Cocktail - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        ELSE 'Menu Item - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
    END AS standardized_product_name,
    gross_product_revenue,
    absolute_product_revenue,
    units_sold_count
FROM analytics_item_performance;

-- 2. Anonymized Product Menu Mix View (Unique ID per item)
CREATE VIEW anon_analytics_product_menu_mix AS
SELECT 
    operational_period,
    CASE 
        WHEN standardized_product_name ILIKE '%birria%' THEN 'Slow-Braised Taco - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%taco%' THEN 'Specialty Street Taco - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%modelo%' OR standardized_product_name ILIKE '%beer%' THEN 'Draft Lager - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%pinot%' OR standardized_product_name ILIKE '%wine%' THEN 'House Wine - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        WHEN standardized_product_name ILIKE '%rita%' OR standardized_product_name ILIKE '%oro%' THEN 'Signature Cocktail - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
        ELSE 'Menu Item - ' || UPPER(SUBSTR(MD5(standardized_product_name), 1, 4))
    END AS standardized_product_name,
    gross_product_revenue,
    absolute_product_revenue,
    units_sold_count
FROM analytics_product_menu_mix;