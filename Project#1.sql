CREATE TABLE materials (
    material_id VARCHAR(20) PRIMARY KEY,
    material_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_cost DECIMAL(10, 2)
);

CREATE TABLE inventory (
    material_id VARCHAR(20) REFERENCES materials(material_id),
    plant_id VARCHAR(10),
    current_stock INTEGER DEFAULT 0,
    safety_stock INTEGER DEFAULT 0,
    reorder_point INTEGER DEFAULT 0,
    PRIMARY KEY (material_id, plant_id) 
);

CREATE TABLE inventory_transactions (
    transaction_id SERIAL PRIMARY KEY,
    material_id VARCHAR(20) REFERENCES materials(material_id),
    plant_id VARCHAR(10),
    quantity_moved INTEGER NOT NULL,
    movement_type VARCHAR(10) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


SELECT 
    m.material_name,
    m.category,
    i.current_stock,
    i.safety_stock,
    i.reorder_point
FROM 
    inventory i
JOIN 
    materials m ON i.material_id = m.material_id
WHERE 
    i.current_stock <= i.safety_stock;