-- День 2. Запросы к таблице products (база shop)

-- Все товары
SELECT * FROM products;

-- Только название и цена
SELECT name, price FROM products;

-- Товары в наличии, от дорогого к дешёвому
SELECT name, price FROM products
WHERE in_stock = TRUE
ORDER BY price DESC;

-- Товары НЕ в наличии, от дорогого к дешёвому
SELECT name, price FROM products
WHERE in_stock = FALSE
ORDER BY price DESC;

-- Дешевле 5000, от дешёвых к дорогим
SELECT name FROM products
WHERE price < 5000
ORDER BY price;

-- Самый дорогой товар в наличии
SELECT name, price FROM products
WHERE in_stock = TRUE
ORDER BY price DESC
LIMIT 1;

-- Три самых дешёвых товара
SELECT name, price FROM products ORDER BY price ASC LIMIT 3;

-- Цена в диапазоне и нет в наличии
SELECT name FROM products
WHERE price BETWEEN 1000 AND 5000 AND in_stock = FALSE;

-- LIKE различает регистр, ILIKE нет
SELECT name FROM products WHERE name LIKE 'М%';
SELECT name FROM products WHERE name LIKE 'м%';
SELECT name FROM products WHERE name ILIKE 'м%';
SELECT name FROM products WHERE name ILIKE '%о%';

-- IN и IS NULL
SELECT name FROM products WHERE price IN (100, 4200, 7000);
SELECT name FROM products WHERE name IS NULL;

-- Проверка CHECK (должна быть ошибка products_price_check)
-- INSERT INTO products (name, price) VALUES ('brak', -10);
