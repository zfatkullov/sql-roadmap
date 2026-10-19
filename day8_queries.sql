-- День 8. Индексы и EXPLAIN ANALYZE (база shop, DBeaver)

-- Типичная ошибка: синтаксис 42601. Пропущена запятая после "g AS id"
-- и лишняя запятая перед FROM. Запятая ставится между столбцами SELECT,
-- но не после последнего.

-- Шаг 1. Тестовая таблица на миллион строк
CREATE TABLE idx_test AS
SELECT
    g AS id,
    'user_' || g AS username,
    (random() * 1000)::int AS score
FROM generate_series(1, 1000000) AS g;

SELECT count(*) FROM idx_test;  -- 1 000 000

-- Шаг 2. Индексов нет (CREATE TABLE AS не создаёт PK): 0 строк
SELECT indexname FROM pg_indexes WHERE tablename = 'idx_test';

-- Без индекса: Parallel Seq Scan, 2 помощника, Rows Removed by Filter: 333333
-- (на один процесс, всего ~1 000 000 строк просмотрено), Execution Time: 41.102 ms
EXPLAIN ANALYZE
SELECT * FROM idx_test WHERE username = 'user_500000';

-- Шаг 3. Индекс по username
CREATE INDEX idx_test_username ON idx_test (username);

-- С индексом: Index Scan, Index Cond, Execution Time: 0.158 ms (~260 раз быстрее)
EXPLAIN ANALYZE
SELECT * FROM idx_test WHERE username = 'user_500000';

-- Шаг 4. Низкая селективность: score = 500 даёт 996 строк
-- Без индекса: Parallel Seq Scan, 38.281 ms
EXPLAIN ANALYZE
SELECT * FROM idx_test WHERE score = 500;

CREATE INDEX idx_test_score ON idx_test (score);  -- 0,278 s

-- С индексом: Bitmap Heap Scan (Bitmap Index Scan + Recheck Cond),
-- 8.797 ms (~4,4 раза быстрее, селективность ниже)
EXPLAIN ANALYZE
SELECT * FROM idx_test WHERE score = 500;

-- Шаг 5. Индексы, созданные автоматически: по одному *_pkey на таблицу.
-- На столбцах FK (order_items.order_id, order_items.product_id,
-- shop_orders.customer_id) индексов нет.
SELECT tablename, indexname FROM pg_indexes
WHERE schemaname = 'public' ORDER BY tablename;

-- Шаг 6. Цена индекса при вставке (1,152 s без индексов, 5,808 s с двумя
-- индексами, ~5 раз; порядок уточнить)
CREATE TABLE ins_plain (id int, username text, score int);
CREATE TABLE ins_idx   (id int, username text, score int);
CREATE INDEX ins_idx_username ON ins_idx (username);
CREATE INDEX ins_idx_score    ON ins_idx (score);

INSERT INTO ins_plain
SELECT g, 'user_' || g, (random() * 1000)::int FROM generate_series(1, 1000000) AS g;

INSERT INTO ins_idx
SELECT g, 'user_' || g, (random() * 1000)::int FROM generate_series(1, 1000000) AS g;

-- Шаг 7. Размеры: таблица 50 MB, idx_username 30 MB, idx_score 7104 kB
-- (дедупликация повторов в B-дереве)
SELECT pg_size_pretty(pg_relation_size('idx_test'))          AS table_size,
       pg_size_pretty(pg_relation_size('idx_test_username')) AS idx_username,
       pg_size_pretty(pg_relation_size('idx_test_score'))    AS idx_score;

-- Уборка: индексы удаляются вместе с таблицами
DROP TABLE idx_test, ins_plain, ins_idx;

SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
-- результат: customers, order_items, products, shop_orders