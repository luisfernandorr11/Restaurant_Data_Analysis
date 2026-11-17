-- 1. Labor Efficiency by Role
CREATE OR REPLACE VIEW analytics_labor_by_role AS
SELECT 
    source_month_folder AS operational_period,
    COALESCE(job_title, 'General Staff') AS job_title,
    SUM(regular_hours::numeric) AS total_regular_hours,
    SUM(overtime_hours::numeric) AS total_overtime_hours,
    SUM(total_hours::numeric) AS total_hours,
    SUM(regular_cost::numeric) AS regular_labor_cost,
    SUM(overtime_cost::numeric) AS overtime_labor_cost,
    SUM(total_cost::numeric) AS total_labor_cost,
    ROUND(AVG(labor_pct_net::numeric), 2) AS avg_labor_pct_net
FROM job_labor_cost
WHERE total_cost::numeric > 0 
  AND job_title IS NOT NULL
  AND last_name IS NULL 
GROUP BY source_month_folder, job_title;

-- 2. Standardized Item Performance
DROP VIEW IF EXISTS analytics_item_performance CASCADE;

CREATE OR REPLACE VIEW analytics_item_performance AS
SELECT 
    source_month_folder AS operational_period,
    COALESCE(
        NULLIF(TRIM(regexp_replace(item, '\s+HH$', '', 'i')), ''), 
        'Unknown Item'
    ) AS standardized_product_name,
    COALESCE(sales_category, 'Uncategorized') AS sales_category,
    SUM(NULLIF(regexp_replace(gross_item_amt::text, '[^0-9.-]', '', 'g'), '')::numeric) AS gross_product_revenue,
    SUM(NULLIF(regexp_replace(net_item_amt::text, '[^0-9.-]', '', 'g'), '')::numeric) AS absolute_product_revenue,
    SUM(NULLIF(regexp_replace(qty_sold::text, '[^0-9.-]', '', 'g'), '')::numeric) AS units_sold_count
FROM staging_item_sales
WHERE item IS NOT NULL 
  AND item != ''
GROUP BY 
    source_month_folder, 
    COALESCE(NULLIF(TRIM(regexp_replace(item, '\s+HH$', '', 'i')), ''), 'Unknown Item'), 
    sales_category;

-- 3. Product Menu Mix by Category
DROP TABLE IF EXISTS analytics_product_menu_mix;

CREATE TABLE analytics_product_menu_mix AS
SELECT 
    source_month_folder AS operational_period,
    TRIM(INITCAP(COALESCE(sales_category, 'Uncategorized'))) AS standardized_product_name,
    ROUND(SUM(gross_sales)::NUMERIC, 2) AS gross_product_revenue,
    ROUND(SUM(net_sales)::NUMERIC, 2) AS absolute_product_revenue,
    ROUND(SUM(items)::INTEGER, 0) AS units_sold_count,
    ROUND(SUM(discount_amount)::NUMERIC, 2) AS category_discounts_applied
FROM category_sales_summary
GROUP BY source_month_folder, sales_category;

-- 4. Weekday Seasonality & Guest Footfall
DROP TABLE IF EXISTS analytics_weekday_seasonality;

CREATE TABLE analytics_weekday_seasonality AS
SELECT 
    w.source_month_folder AS operational_period,
    TRIM(INITCAP(w.day_of_week)) AS clear_day_name,
    ROUND(SUM(w.net_sales)::numeric, 2) AS absolute_net_sales,
    ROUND(SUM(w.total_orders)::numeric, 0) AS historical_ticket_count,
    ROUND(AVG(w.total_guests)::numeric, 1) AS average_guest_footprint
FROM weekday_sales_data w
GROUP BY w.source_month_folder, w.day_of_week;

-- 5. Hourly Efficiency & Sales Per Labor Hour (SPLH)
DROP TABLE IF EXISTS analytics_hourly_efficiency;

CREATE TABLE analytics_hourly_efficiency AS
SELECT 
    h.source_month_folder AS operational_period,
    h.hour_of_day::integer AS explicit_hour,
    ROUND(SUM(h.net_sales)::numeric, 2) AS aggregated_hourly_revenue,
    ROUND(SUM(h.total_orders)::numeric, 0) AS calculated_order_volume,
    ROUND(
        (SUM(h.net_sales) / NULLIF(SUM(j.total_hours), 0))::numeric, 2
    ) AS sales_per_labor_hour_splh
FROM hourly_sales_data h
LEFT JOIN job_labor_cost j 
    ON h.source_month_folder = REPLACE(j.source_month_folder, 'Labor Break Down', 'Monthly Sales')
GROUP BY h.source_month_folder, h.hour_of_day;









