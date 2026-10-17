-- День 6. Проектирование схемы, база shop (DBeaver)

-- Исходное состояние: в shop_orders текстовый столбец customer
SELECT * FROM shop_orders;  -- 2 строки: (1, Аня), (2, Борис)

-- Отдельная таблица покупателей
-- UNIQUE на name не ставим: могут быть два разных покупателя с одним именем
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Перенос уникальных имён (INSERT ... SELECT)
-- Порядок id не гарантирован: после DISTINCT порядок строк не определён
-- Получилось: Борис = 1, Аня = 2
INSERT INTO customers (name)
SELECT DISTINCT customer FROM shop_orders;

SELECT * FROM customers;

-- Новый столбец под FK
ALTER TABLE shop_orders ADD COLUMN customer_id INTEGER;

-- Заполнение по имени, а не по предположению о номерах
-- ОШИБКА: при псевдониме c в SET было customers.id,
-- надо c.id (после введения псевдонима старое имя таблицы не работает)
UPDATE shop_orders so
SET customer_id = c.id
FROM customers c
WHERE c.name = so.customer;

SELECT * FROM shop_orders;  -- заказ 1 -> 2 (Аня), заказ 2 -> 1 (Борис)

-- FK и обязательность
ALTER TABLE shop_orders
    ADD CONSTRAINT fk_shop_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers (id);

ALTER TABLE shop_orders ALTER COLUMN customer_id SET NOT NULL;

-- Проверка FK.
-- ОШИБКА 23502: null value in column "customer" violates not-null constraint
-- (старый столбец customer был NOT NULL, до проверки FK дело не дошло;
-- NOT NULL проверяется раньше FK)
INSERT INTO shop_orders (customer_id) VALUES (999);

-- ОШИБКА 23503: violates foreign key constraint "fk_shop_orders_customer"
-- Key (customer_id)=(999) is not present in table "customers"
INSERT INTO shop_orders (customer, customer_id) VALUES ('Тест', 999);

-- Старый текстовый столбец больше не нужен
ALTER TABLE shop_orders DROP COLUMN customer;

-- JOIN вместо LEFT JOIN: заказа без покупателя быть не может
-- (customer_id NOT NULL + FK)
SELECT so.id, c.name, so.created_at
FROM shop_orders so
JOIN customers c ON c.id = so.customer_id
ORDER BY so.id;  -- 1 Аня, 2 Борис

-- Проверка внешних ключей order_items
SELECT * FROM order_items;
-- FK: order_items_order_id_fkey, order_items_product_id_fkey

-- Суммы заказов по текущей цене из products
SELECT so.id, SUM(oi.quantity * p.price) AS total
FROM shop_orders so
JOIN order_items oi ON oi.order_id = so.id
JOIN products p ON p.id = oi.product_id
GROUP BY so.id
ORDER BY so.id;  -- 155050.5 и 88860

-- Проблема: смена цены меняет старые заказы задним числом
UPDATE products SET price = 80000 WHERE id = 1;
-- те же запросы дали 165050.5 и 93860
UPDATE products SET price = 75000 WHERE id = 1;  -- вернули

-- Решение: цена на момент покупки хранится в order_items
ALTER TABLE order_items ADD COLUMN unit_price NUMERIC(10,2);

UPDATE order_items oi
SET unit_price = p.price
FROM products p
WHERE p.id = oi.product_id;

ALTER TABLE order_items ALTER COLUMN unit_price SET NOT NULL;
ALTER TABLE order_items ADD CONSTRAINT chk_unit_price CHECK (unit_price > 0);

-- Суммы по unit_price не зависят от products.price
SELECT so.id, SUM(oi.quantity * oi.unit_price) AS total
FROM shop_orders so
JOIN order_items oi ON oi.order_id = so.id
GROUP BY so.id
ORDER BY so.id;  -- 155050.5 и 88860

-- Проверки: цена товара 1 = 75000, CHECK у order_items:
-- order_items_quantity_check, chk_unit_price; unit_price is_nullable = NO