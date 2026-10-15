-- ДЕНЬ 4: JOIN (INNER, LEFT, три таблицы)
-- Правило: левая таблица в LEFT JOIN = та, чьи строки хочу видеть все.
-- После LEFT JOIN считать COUNT(колонка_правой_таблицы), а не COUNT(*).

-- =====================================================
-- БАЗА learn_sql (psql learn_sql)
-- =====================================================

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- У Ани (id 1) два заказа, у Бориса (id 4) один, у Веры (id 5) ни одного
INSERT INTO orders (user_id, amount)
VALUES (1, 1500.00),
       (1, 320.50),
       (4, 2990.00);

SELECT * FROM orders;

-- INNER JOIN: только пользователи с заказами (3 строки, Веры нет)
SELECT name, amount FROM users
INNER JOIN orders
ON users.id = orders.user_id;

-- LEFT JOIN: все пользователи (4 строки, у Веры amount = NULL)
SELECT name, amount FROM users
LEFT JOIN orders
ON users.id = orders.user_id;

-- Пользователи без заказов: LEFT JOIN + IS NULL по первичному ключу правой таблицы
SELECT name, amount FROM users
LEFT JOIN orders
ON users.id = orders.user_id
WHERE orders.id IS NULL;

-- Число заказов и сумма по каждому пользователю, включая Веру
-- COALESCE(x, 0) заменяет NULL на 0
-- users.name не агрегат, поэтому он в GROUP BY
SELECT users.name, COUNT(orders.id) AS orders_count, COALESCE(SUM(orders.amount), 0) AS total
FROM users
LEFT JOIN orders ON users.id = orders.user_id
GROUP BY users.name;
-- Результат: Аня 2 / 1820.50, Борис 1 / 2990.00, Вера 0 / 0
-- Вопрос: что даст COUNT(*) вместо COUNT(orders.id)? Ответ: у Веры 1, потому что
-- COUNT(*) считает строки, а у Веры после LEFT JOIN одна строка с NULL справа.

-- =====================================================
-- БАЗА shop (psql -U shop_user -d shop)
-- =====================================================

CREATE TABLE shop_orders (
    id SERIAL PRIMARY KEY,
    customer TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Промежуточная таблица для связи M:N (заказ <-> товар)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES shop_orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0)
);

INSERT INTO shop_orders (customer)
VALUES ('Аня'),
       ('Борис');

INSERT INTO order_items (order_id, product_id, quantity)
VALUES (1, 1, 2), (1, 2, 1), (1, 3, 1), (2, 1, 1), (2, 5, 3);

SELECT * FROM order_items;

-- JOIN трёх таблиц: заказ, покупатель, товар (5 строк)
SELECT shop_orders.customer, products.name, order_items.quantity
FROM order_items
INNER JOIN shop_orders
ON order_items.order_id = shop_orders.id
INNER JOIN products
ON order_items.product_id = products.id
ORDER BY shop_orders.id, products.name;

-- Стоимость каждого заказа (customer не агрегат, значит в GROUP BY)
SELECT shop_orders.customer,
       SUM(order_items.quantity * products.price) AS total
FROM order_items
INNER JOIN shop_orders ON order_items.order_id = shop_orders.id
INNER JOIN products ON order_items.product_id = products.id
GROUP BY shop_orders.customer
ORDER BY total DESC;
-- Результат: Аня 155050.50, Борис 88860.00

-- Товары, которые ни разу не заказывали (4 строки: id 4, 6, 9, 10)
SELECT products.id, products.name
FROM products
LEFT JOIN order_items ON order_items.product_id = products.id
WHERE order_items.id IS NULL
ORDER BY products.id;

-- Сколько раз заказывали каждый товар, включая 0
-- Всё не агрегатное из SELECT (id и name) перечислено в GROUP BY
SELECT products.id, products.name,
       COUNT(order_items.id) AS times_ordered
FROM products
LEFT JOIN order_items ON order_items.product_id = products.id
GROUP BY products.id, products.name
ORDER BY products.id;
-- Вопрос: что даст COUNT(*) вместо COUNT(order_items.id)? Ответ: у Монитора 1 вместо 0.
