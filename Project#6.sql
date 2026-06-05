CREATE TABLE dw_dim_date (
    date_key INT PRIMARY KEY, -- e.g., 20231001
    full_date DATE,
    day_of_week VARCHAR(15),
    month_name VARCHAR(15),
    quarter INT,
    year INT
);

CREATE TABLE dw_dim_material (
    material_key SERIAL PRIMARY KEY,
    material_id VARCHAR(50),
    material_description VARCHAR(100),
    material_type VARCHAR(50),
    standard_cost NUMERIC(10,2)
);

CREATE TABLE dw_dim_vendor (
    vendor_key SERIAL PRIMARY KEY,
    vendor_id VARCHAR(50),
    vendor_name VARCHAR(100),
    vendor_country VARCHAR(50)
);

CREATE TABLE dw_dim_plant (
    plant_key SERIAL PRIMARY KEY,
    plant_id VARCHAR(50),
    plant_location VARCHAR(100)
);

-- ==========================================
-- FACT TABLES (The measurable events)
-- ==========================================

-- Fact 1: Procurement (Tracks purchasing events)
CREATE TABLE dw_fact_procurement (
    procurement_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw_dim_date(date_key),
    material_key INT REFERENCES dw_dim_material(material_key),
    vendor_key INT REFERENCES dw_dim_vendor(vendor_key),
    plant_key INT REFERENCES dw_dim_plant(plant_key),
    po_quantity INT,
    total_spend NUMERIC(12,2),
    lead_time_days INT
);

-- Fact 2: Inventory Snapshot (Tracks stock levels at the end of each day/month)
CREATE TABLE dw_fact_inventory (
    inventory_snapshot_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dw_dim_date(date_key),
    material_key INT REFERENCES dw_dim_material(material_key),
    plant_key INT REFERENCES dw_dim_plant(plant_key),
    on_hand_qty INT,
    inventory_value NUMERIC(12,2)
);

SELECT 
    v.vendor_name,
    d.year,
    d.quarter,
    SUM(f.total_spend) as total_quarterly_spend
FROM dw_fact_procurement f
JOIN dw_dim_vendor v ON f.vendor_key = v.vendor_key
JOIN dw_dim_date d ON f.date_key = d.date_key
WHERE d.quarter = 4 AND d.year = 2023
GROUP BY v.vendor_name, d.year, d.quarter;