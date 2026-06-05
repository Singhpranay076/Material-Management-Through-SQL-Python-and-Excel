-- 1. Warehouse Master Table
CREATE TABLE warehouse (
    warehouse_id VARCHAR(10) PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(100)
);

-- 2. Storage Bins Master Table
-- This defines the physical spots in the warehouse and their maximum capacity.
CREATE TABLE storage_bins (
    bin_id VARCHAR(20) PRIMARY KEY,
    warehouse_id VARCHAR(10) REFERENCES warehouse(warehouse_id),
    bin_type VARCHAR(50), -- e.g., 'High Rack', 'Floor', 'Cold Storage'
    max_capacity_qty INT
);

-- 3. Goods Receipts (Inbound / Receiving & Putaway)
-- When stock arrives and is placed into a bin.
CREATE TABLE goods_receipts (
    receipt_id SERIAL PRIMARY KEY,
    material_id VARCHAR(50),
    receipt_date DATE,
    qty_received INT,
    destination_bin_id VARCHAR(20) REFERENCES storage_bins(bin_id)
);

-- 4. Goods Issues (Outbound / Picking & Shipping)
-- When stock is removed from a bin to be shipped.
CREATE TABLE goods_issues (
    issue_id SERIAL PRIMARY KEY,
    material_id VARCHAR(50),
    issue_date DATE,
    qty_issued INT,
    source_bin_id VARCHAR(20) REFERENCES storage_bins(bin_id)
);

WITH TotalReceipts AS (
    SELECT destination_bin_id as bin_id, material_id, SUM(qty_received) as total_in
    FROM goods_receipts
    GROUP BY destination_bin_id, material_id
),
TotalIssues AS (
    SELECT source_bin_id as bin_id, material_id, SUM(qty_issued) as total_out
    FROM goods_issues
    GROUP BY source_bin_id, material_id
)
SELECT 
    r.bin_id,
    r.material_id,
    r.total_in,
    COALESCE(i.total_out, 0) as total_out,
    (r.total_in - COALESCE(i.total_out, 0)) as current_stock
FROM TotalReceipts r
LEFT JOIN TotalIssues i ON r.bin_id = i.bin_id AND r.material_id = i.material_id
ORDER BY r.bin_id;


WITH CurrentBinStock AS (
    -- Reusing logic from above to get total stock per bin
    SELECT r.destination_bin_id as bin_id, SUM(r.qty_received) - COALESCE((SELECT SUM(qty_issued) FROM goods_issues WHERE source_bin_id = r.destination_bin_id), 0) as current_qty
    FROM goods_receipts r
    GROUP BY r.destination_bin_id
)
SELECT 
    b.bin_id,
    b.max_capacity_qty,
    COALESCE(c.current_qty, 0) as current_qty,
    ROUND((COALESCE(c.current_qty, 0)::numeric / b.max_capacity_qty) * 100, 2) as utilization_percentage
FROM storage_bins b
LEFT JOIN CurrentBinStock c ON b.bin_id = c.bin_id
ORDER BY utilization_percentage DESC;
