-- День 7: нормализация 1NF-3NF (база shop, экспериментальные таблицы, в конце удалены)

-- Плоская таблица, нарушение 1NF: несколько товаров в одной ячейке
CREATE TABLE flat_orders (
    id SERIAL PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_city TEXT NOT NULL,
    products TEXT NOT NULL
);

INSERT INTO flat_orders (customer_name, customer_city, products) VALUES
('Аня', 'Москва', 'Ноутбук, Мышь'),
('Борис', 'Казань', 'Мышь'),
('Аня', 'Москва', 'Клавиатура, Мышь, Монитор');

-- Равенство сравнивает весь текст ячейки: 1 строка вместо 3
SELECT * FROM flat_orders WHERE products = 'Мышь';

-- Костыль: 3 строки, но нашёл бы и «Мышь игровая»
SELECT * FROM flat_orders WHERE products LIKE '%Мышь%';

-- 1NF: одна позиция = одна строка
CREATE TABLE flat_orders_1nf (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    customer_name TEXT NOT NULL,
    customer_city TEXT NOT NULL,
    product TEXT NOT NULL
);

INSERT INTO flat_orders_1nf (order_id, customer_name, customer_city, product) VALUES
(1, 'Аня', 'Москва', 'Ноутбук'),
(1, 'Аня', 'Москва', 'Мышь'),
(2, 'Борис', 'Казань', 'Мышь'),
(3, 'Аня', 'Москва', 'Клавиатура'),
(3, 'Аня', 'Москва', 'Мышь'),
(3, 'Аня', 'Москва', 'Монитор');

SELECT * FROM flat_orders_1nf WHERE product = 'Мышь'; -- 3 строки, поиск точный

-- Аномалия обновления: обновили 1 строку из 5, у Ани два города
UPDATE flat_orders_1nf SET customer_city = 'Санкт-Петербург' WHERE id = 2;
SELECT order_id, customer_name, customer_city, product FROM flat_orders_1nf ORDER BY id;

-- 3NF: покупатель, заказ, позиция отдельно
CREATE TABLE n_customers (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL
);
CREATE TABLE n_orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES n_customers(id)
);
CREATE TABLE n_order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES n_orders(id),
    product TEXT NOT NULL
);

INSERT INTO n_customers (name, city) VALUES ('Аня', 'Москва'), ('Борис', 'Казань');
INSERT INTO n_orders (id, customer_id) VALUES (1, 1), (2, 2), (3, 1);
INSERT INTO n_order_items (order_id, product) VALUES
(1, 'Ноутбук'), (1, 'Мышь'), (2, 'Мышь'),
(3, 'Клавиатура'), (3, 'Мышь'), (3, 'Монитор');

-- Сборка обратно через JOIN: 6 строк
SELECT o.id AS order_id, c.name, c.city, i.product
FROM n_order_items i
JOIN n_orders o ON o.id = i.order_id
JOIN n_customers c ON c.id = o.customer_id
ORDER BY i.id;

-- Город Ани хранится в одной строке: меняем 1 строку, все 5 строк результата обновились
UPDATE n_customers SET city = 'Санкт-Петербург' WHERE id = 1;

-- Аномалия вставки невозможна: покупатель без заказа
INSERT INTO n_customers (name, city) VALUES ('Вера', 'Тверь');

-- Аномалия удаления невозможна: Борис остался после удаления своей позиции
DELETE FROM n_order_items WHERE order_id = 2;
SELECT * FROM n_customers;

-- Ошибка 23503: родителя с заказами удалить нельзя (NO ACTION по умолчанию)
DELETE FROM n_customers WHERE id = 1;

-- Уборка: сначала дочерние таблицы, потом родительские
DROP TABLE n_order_items;
DROP TABLE n_orders;
DROP TABLE n_customers;
DROP TABLE flat_orders_1nf;
DROP TABLE flat_orders;

SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' ORDER BY table_name; -- остались 4: customers, order_items, products, shop_orders