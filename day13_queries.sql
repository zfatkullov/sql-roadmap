-- День 13. SQLAlchemy ORM: связи и запросы.
-- ORM-код находится в day13_sqlalchemy/app.py и mini_product_report.py.
-- Этот файл фиксирует SQL, которому соответствовали выполненные ORM-запросы.

-- Модели и связи:
-- customers 1:N shop_orders 1:N order_items N:1 products.
-- ForeignKey отвечает за правило в PostgreSQL.
-- relationship() и back_populates дают переходы между объектами в Python.

-- Практика 1. Ленивая загрузка.
-- Предсказание для покупателя id = 2: номера его заказов = [1].
-- Факт: [1].
-- Первый запрос загрузил покупателя; второй появился при обращении к customer.orders.
SELECT id, name
FROM customers
WHERE id = 2;

SELECT id, created_at, customer_id
FROM shop_orders
WHERE customer_id = 2;

-- Практика 2. N+1.
-- Предсказание: 3 рабочих SELECT для двух покупателей.
-- Факт: 1 запрос покупателей и по 1 запросу заказов для Бориса и Ани.
SELECT id, name
FROM customers;

SELECT id, created_at, customer_id
FROM shop_orders
WHERE customer_id = 1;

SELECT id, created_at, customer_id
FROM shop_orders
WHERE customer_id = 2;

-- Практика 3. selectinload(Customer.orders).
-- Предсказание: 2 рабочих SELECT.
-- Факт: покупатели и один общий запрос заказов через IN.
SELECT id, name
FROM customers;

SELECT id, created_at, customer_id
FROM shop_orders
WHERE customer_id IN (1, 2);

-- Практика 4. JOIN: заказы покупателя по имени.
-- Предсказание: для Ани вернётся заказ [1]. Факт: [1].
SELECT shop_orders.id, shop_orders.created_at, shop_orders.customer_id
FROM shop_orders
JOIN customers ON customers.id = shop_orders.customer_id
WHERE customers.name = 'Аня';

-- Практика 5. Отчёт по позициям заказов.
-- Предсказание: 5 строк, по одной на позицию заказа. Факт: 5 строк.
-- Для суммы заказа нужна цена на момент покупки: order_items.unit_price,
-- а не текущая products.price.
SELECT
    customers.name,
    products.name,
    order_items.quantity,
    order_items.unit_price
FROM customers
JOIN shop_orders ON customers.id = shop_orders.customer_id
JOIN order_items ON shop_orders.id = order_items.order_id
JOIN products ON products.id = order_items.product_id
ORDER BY order_items.id;

-- Практика 6. Сумма покупок каждого клиента.
-- Предсказание и факт:
-- Борис = 88860.00; Аня = 155050.50.
SELECT
    customers.name,
    SUM(order_items.quantity * order_items.unit_price) AS total
FROM customers
JOIN shop_orders ON customers.id = shop_orders.customer_id
JOIN order_items ON shop_orders.id = order_items.order_id
GROUP BY customers.id, customers.name
ORDER BY customers.id;

-- Мини-практика: товары в наличии дешевле 5000, сортировка по цене.
-- Факт: a (777.00), Мышь (1200.50).
SELECT id, name, price, in_stock
FROM products
WHERE in_stock IS TRUE
  AND price < 5000
ORDER BY price;
