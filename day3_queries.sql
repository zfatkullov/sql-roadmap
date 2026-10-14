-- День 3. Изменение данных и агрегаты

-- ============================================
-- База learn_sql (psql learn_sql)
-- ============================================

-- Исправляем «Vera» на «Вера»
UPDATE users SET name = 'Вера' WHERE id = 5 RETURNING *;


-- ============================================
-- База shop (psql -U shop_user -d shop)
-- ============================================

-- --- Разбор COUNT и агрегатов ---

SELECT COUNT(*) FROM products;

SELECT COUNT(*) FROM products WHERE in_stock;

SELECT in_stock, COUNT(*) FROM products GROUP BY in_stock;

SELECT SUM(price), AVG(price), MIN(price), MAX(price) FROM products;

SELECT in_stock, AVG(price)
FROM products
GROUP BY in_stock
HAVING AVG(price) > 5000;

SELECT DISTINCT in_stock FROM products;


-- --- INSERT / UPDATE / DELETE ---

-- 1. Два товара одним INSERT
-- (типичные ошибки: INSERT без INTO/VALUES; INSERT (колонки) INTO ... -- неверный порядок)
INSERT INTO products (name, price, in_stock)
VALUES
('a', 777, TRUE),
('b', 666, FALSE);

SELECT * FROM products;

-- 2. Цена +10% для товаров не в наличии (выполнять ОДИН раз)
-- Результат: UPDATE 3. Без ORDER BY порядок строк после UPDATE не гарантирован.
UPDATE products
SET price = price * 1.1
WHERE in_stock = FALSE;

SELECT * FROM products;

-- 3. Удаление товара test: сначала проверка, потом DELETE
-- (ошибка: DELETE * FROM -- у DELETE нет списка колонок)
SELECT * FROM products
WHERE name = 'test';

DELETE FROM products
WHERE name = 'test'
RETURNING *;
