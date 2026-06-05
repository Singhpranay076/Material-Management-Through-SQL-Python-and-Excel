-- 1. Historical Actual Demand
CREATE TABLE actual_demand (
    demand_id SERIAL PRIMARY KEY,
    material_id VARCHAR(50),
    demand_month DATE, -- Store as the first of the month (e.g., '2023-01-01')
    actual_qty INT
);

-- 2. Forecast Output
CREATE TABLE forecast_demand (
    forecast_id SERIAL PRIMARY KEY,
    material_id VARCHAR(50),
    forecast_month DATE,
    model_name VARCHAR(50), -- e.g., '3-Month Moving Average', 'Exponential Smoothing'
    forecast_qty NUMERIC(10, 2)
);

WITH ForecastComparison AS (
    SELECT 
        a.material_id,
        a.demand_month,
        a.actual_qty,
        f.model_name,
        f.forecast_qty,
        -- Calculate Absolute Error
        ABS(a.actual_qty - f.forecast_qty) AS absolute_error
    FROM actual_demand a
    JOIN forecast_demand f 
        ON a.material_id = f.material_id 
        AND a.demand_month = f.forecast_month
)
SELECT 
    model_name,
    COUNT(demand_month) as months_evaluated,
    ROUND(AVG(absolute_error), 2) AS mean_absolute_error,
    -- Calculate MAPE (Mean Absolute Percentage Error)
    -- NULLIF prevents division by zero if actual_qty is ever 0
    ROUND(AVG(absolute_error / NULLIF(actual_qty, 0)) * 100, 2) AS mape_percentage
FROM ForecastComparison
GROUP BY model_name
ORDER BY mape_percentage ASC;

