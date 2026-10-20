-- День 9: составной индекс, индекс на FK, UNIQUE, ALTER TABLE
-- База shop, DBeaver. Это журнал, целиком не запускать (есть команды, которые падают).

-- ===== 1. Составной индекс =====
CREATE TABLE idx_comp AS
SELECT g AS id,
       g % 1000 AS city_id,
       (g / 1000) % 10 AS status_id
FROM generate_series(1, 1000000) AS g;

ANALYZE idx_comp;  -- 0,083 s; Updated Rows 0 (ANALYZE строки не меняет)

-- Предсказание "более 100к" неверно: 1 000 000 / 10 000 комбинаций = 100 строк.
-- Без индекса: Parallel Seq Scan, 2 помощника,
-- Rows Removed by Filter: 333300 (на один процесс, всего ~1 000 000), 35.674 ms.
EXPLAIN ANALYZE
SELECT * FROM idx_comp
WHERE city_id = 500 AND status_id = 3;

CREATE INDEX idx_comp_city_status ON idx_comp (city_id, status_id);
-- Execute time этой команды не зафиксирован (скриншот не прислан).

-- С индексом: Bitmap Heap Scan + Bitmap Index Scan, Heap Blocks: exact=100,
-- 0.671 ms (~53 раза быстрее). Я предсказал Index Scan и "больше 1 мс": оба неверно.
-- Первый скриншот этого шага показал старый план (старый запрос), перезапустили.
EXPLAIN ANALYZE
SELECT * FROM idx_comp
WHERE city_id = 500 AND status_id = 3;

-- Только второй столбец индекса: 100 000 строк (10%). Я предсказал "индекс не будет
-- использован": неверно. Bitmap Index Scan по idx_comp_city_status проходит индекс
-- целиком (11 ms против 0.059 ms при поиске по обоим столбцам), Heap Blocks: exact=637,
-- 24.710 ms.
EXPLAIN ANALYZE
SELECT * FROM idx_comp
WHERE status_id = 3;

-- То же без индексов: Seq Scan, Rows Removed by Filter: 900000, 66.475 ms
-- (индекс быстрее в ~2,7 раза: низкая селективность, 10% таблицы).
SET enable_indexscan = off;
SET enable_bitmapscan = off;
EXPLAIN ANALYZE
SELECT * FROM idx_comp
WHERE status_id = 3;
RESET enable_indexscan;
RESET enable_bitmapscan;
SHOW enable_bitmapscan;  -- on

-- Размеры: таблица 42 MB, индекс 6712 kB (меньше в ~6,4 раза; я предсказал в 1,5).
SELECT pg_size_pretty(pg_relation_size('idx_comp')) AS table_size,
       pg_size_pretty(pg_relation_size('idx_comp_city_status')) AS index_size;

-- ===== 2. Индекс на FK-столбец =====
CREATE TABLE fk_parent (id integer PRIMARY KEY);
CREATE TABLE fk_child (
    id integer PRIMARY KEY,
    parent_id integer REFERENCES fk_parent(id)
);

-- Ошибка 23503: в скрипт не попала вставка родителей, fk_parent была пустой (вероятно),
-- поэтому первая же строка детей (parent_id = 2) нарушила FK.
-- Ключевое: Key (parent_id)=(2) is not present in table "fk_parent".
INSERT INTO fk_parent
SELECT g FROM generate_series(1, 100001) AS g;

INSERT INTO fk_child
SELECT g, (g % 100000) + 1 FROM generate_series(1, 1000000) AS g;
-- Проверка: 100 001 родитель и 1 000 000 детей.

ANALYZE fk_parent;
ANALYZE fk_child;

-- Автоиндексы: только fk_parent_pkey и fk_child_pkey (2 строки).
-- Индекса на fk_child.parent_id нет, хотя FK есть (ограничение fk_child_parent_id_fkey).
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE tablename IN ('fk_parent', 'fk_child');

-- DELETE без индекса на parent_id: Trigger for constraint fk_child_parent_id_fkey:
-- 52.201 ms, Execution Time 55.330 ms (само удаление ~0.17 ms).
-- EXPLAIN ANALYZE выполняет DELETE по-настоящему, поэтому строку вернули.
EXPLAIN ANALYZE
DELETE FROM fk_parent WHERE id = 100001;
INSERT INTO fk_parent VALUES (100001);

-- Индекс на FK-столбец: CREATE INDEX 0,205 s.
CREATE INDEX fk_child_parent_id_idx ON fk_child (parent_id);
ANALYZE fk_child;

-- Тот же DELETE: Trigger 0.907 ms, Execution Time 1.113 ms (проверка детей в ~58 раз быстрее).
EXPLAIN ANALYZE
DELETE FROM fk_parent WHERE id = 100001;
INSERT INTO fk_parent VALUES (100001);

-- JOIN: rows=10 (я ответил "1 строка": неверно, parent_id не уникален, 1:N,
-- 1 000 000 / 100 000 = 10 детей на родителя).
-- С индексом: Bitmap Heap Scan, Heap Blocks: exact=10, 0.313 ms.
EXPLAIN ANALYZE
SELECT p.id, c.id
FROM fk_parent p
JOIN fk_child c ON c.parent_id = p.id
WHERE p.id = 500;

-- Размеры: fk_child 35 MB, индекс 9256 kB.
SELECT pg_size_pretty(pg_relation_size('fk_child')) AS table_size,
       pg_size_pretty(pg_relation_size('fk_child_parent_id_idx')) AS index_size;

DROP INDEX fk_child_parent_id_idx;

-- Без индекса: Parallel Seq Scan, Rows Removed by Filter: 333330 (на процесс),
-- 33.540 ms (в ~107 раз медленнее, чем с индексом).
EXPLAIN ANALYZE
SELECT p.id, c.id
FROM fk_parent p
JOIN fk_child c ON c.parent_id = p.id
WHERE p.id = 500;

-- ===== 3. UNIQUE-индекс =====
CREATE TABLE uq_test (id integer, email text);
CREATE UNIQUE INDEX uq_test_email_idx ON uq_test (email);
INSERT INTO uq_test VALUES (1, 'a@x.com');
-- Ошибка 23505: duplicate key value violates unique constraint "uq_test_email_idx".
INSERT INTO uq_test VALUES (2, 'a@x.com');
-- NULL не равен NULL, поэтому обе вставки проходят (UNIQUE допускает много NULL).
INSERT INTO uq_test VALUES (3, NULL);
INSERT INTO uq_test VALUES (4, NULL);
SELECT * FROM uq_test ORDER BY id;  -- 3 строки: id 1, 3, 4

-- ===== 4. ALTER TABLE =====
CREATE TABLE alter_test (id integer PRIMARY KEY, name text);
INSERT INTO alter_test VALUES (1, 'Аня'), (2, 'Борис');
ALTER TABLE alter_test ADD COLUMN age integer;  -- у старых строк age = NULL
ALTER TABLE alter_test RENAME COLUMN name TO full_name;
-- Ошибка 23502: column "age" of relation "alter_test" contains null values.
ALTER TABLE alter_test ALTER COLUMN age SET NOT NULL;
UPDATE alter_test SET age = 0;
ALTER TABLE alter_test ALTER COLUMN age SET NOT NULL;  -- по косвенным признакам прошла
-- Ошибка 23502: null value in column "age" ... violates not-null constraint
-- (у age нет DEFAULT, подставился NULL).
INSERT INTO alter_test (id, full_name) VALUES (3, 'Вера');
ALTER TABLE alter_test DROP COLUMN age;

-- ===== 5. Уборка =====
DROP TABLE idx_comp, fk_child, fk_parent, uq_test, alter_test;
-- В public shop снова 4 таблицы: customers, order_items, products, shop_orders.
-- Структура не менялась, pg_dump не переделывался.