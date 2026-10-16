-- День 5: подзапросы и WITH

-- ===== shop =====
-- Среднее по всем товарам (результат 14010.136...)
SELECT AVG(price) FROM products;

-- Подзапрос с одним значением: товары дороже средней цены
-- (Ноутбук, Монитор)
SELECT name FROM products
WHERE products.price > (SELECT AVG(price) FROM products);

-- WITH + склейка через запятую: тот же результат
WITH avg_p AS (SELECT AVG(price) AS avg_price FROM products)
SELECT name, price FROM products, avg_p WHERE price > avg_price;

-- ===== learn_sql =====
-- Подзапрос со списком: пользователи с заказами (Аня, Борис)
SELECT name FROM users
WHERE id IN (SELECT user_id FROM orders);

-- NOT IN: пользователи без заказов (Вера)
SELECT name FROM users
WHERE id NOT IN (SELECT user_id FROM orders);

-- Коррелированный подзапрос: заказы выше средней суммы своего пользователя
-- (только заказ 1)
SELECT id, user_id, amount FROM orders
WHERE amount > (SELECT AVG(o2.amount) FROM orders AS o2
                WHERE o2.user_id = orders.user_id);

-- WITH: пользователи без заказов (Вера)
WITH active AS (SELECT user_id FROM orders)
SELECT name FROM users WHERE id NOT IN (SELECT user_id FROM active);