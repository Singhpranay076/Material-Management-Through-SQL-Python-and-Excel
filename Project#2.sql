-- 1. Vendors Table (The Master Data)
CREATE TABLE vendors (
    vendor_id VARCHAR(10) PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    region VARCHAR(50),
    contact_email VARCHAR(100)
);

-- 2. Purchase Orders Table (The Header Data)
CREATE TABLE purchase_orders (
    po_number VARCHAR(15) PRIMARY KEY,
    vendor_id VARCHAR(10) REFERENCES vendors(vendor_id),
    order_date DATE NOT NULL,
    expected_delivery_date DATE NOT NULL,
    actual_delivery_date DATE,
    status VARCHAR(20)
);

-- 3. PO Items Table (The Line Item Data)
CREATE TABLE purchase_order_items (
    po_item_id SERIAL PRIMARY KEY,
    po_number VARCHAR(15) REFERENCES purchase_orders(po_number),
    material_id VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

ALTER TABLE purchase_order_items 
ADD COLUMN total_value DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED;


-- Insight 1: Top Vendors by Spend (Relies on JOINs and Aggregation)
SELECT 
    v.vendor_name,
    SUM(poi.total_value) AS total_spend
FROM vendors v
JOIN purchase_orders po ON v.vendor_id = po.vendor_id
JOIN purchase_order_items poi ON po.po_number = poi.po_number
GROUP BY v.vendor_name
ORDER BY total_spend DESC;

-- Insight 2: Count of Delayed Deliveries per Vendor (Relies on Date Logic and Filtering)
SELECT 
    v.vendor_name,
    COUNT(po.po_number) AS total_delayed_orders
FROM vendors v
JOIN purchase_orders po ON v.vendor_id = po.vendor_id
WHERE po.actual_delivery_date > po.expected_delivery_date
GROUP BY v.vendor_name
ORDER BY total_delayed_orders DESC;