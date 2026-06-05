-- 1. Product Master Table
CREATE TABLE mrp_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_description VARCHAR(100),
    product_type VARCHAR(20) 
);

-- 2. Bill of Materials (BOM)
CREATE TABLE mrp_bom (
    bom_id SERIAL PRIMARY KEY,
    parent_product_id VARCHAR(50) REFERENCES mrp_products(product_id),
    child_product_id VARCHAR(50) REFERENCES mrp_products(product_id),
    quantity_required NUMERIC(10, 2)
);

-- 3. Current Inventory (Renamed to avoid collision)
CREATE TABLE mrp_inventory (
    product_id VARCHAR(50) REFERENCES mrp_products(product_id),
    on_hand_qty NUMERIC(10, 2)
);

-- 4. MRP Output 
CREATE TABLE mrp_results (
    mrp_run_id SERIAL PRIMARY KEY,
    product_id VARCHAR(50),
    gross_requirement NUMERIC(10, 2), 
    on_hand_inventory NUMERIC(10, 2), 
    net_requirement NUMERIC(10, 2),   
    planned_order_qty NUMERIC(10, 2)  
);

SELECT 
    m.product_id,
    p.product_description,
    p.product_type,
    m.gross_requirement,
    m.on_hand_inventory,
    m.planned_order_qty as shortage_to_buy
FROM mrp_results m
JOIN mrp_products p ON m.product_id = p.product_id 
WHERE m.planned_order_qty > 0
ORDER BY m.planned_order_qty DESC;