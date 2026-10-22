-- День 11. Уровни изоляции, блокировки и дедлоки
-- База: learn_sql. Инструмент: два терминала psql.
-- Терминал 1 и терминал 2 — два разных подключения к одной базе.
-- =#  : нет открытой транзакции
-- =*# : открыта транзакция
-- =!# : транзакция сломана; нужен ROLLBACK

-- Теория прочитана: SQL Academy «Блокировки в СУБД» и PostgreSQL 15
-- «Transaction Isolation» (описание READ COMMITTED, REPEATABLE READ,
-- SERIALIZABLE).
-- Уровень изоляции определяет, какие зафиксированные данные видит
-- транзакция. Блокировка строки определяет, кто может изменить
-- конфликтующую строку и когда.

------------------------------------------------------------
-- Подготовка
------------------------------------------------------------
-- Сначала по ошибке была создана TEMP TABLE isolation_demo.
-- Она видна только текущей сессии, поэтому для опыта с двумя терминалами
-- её удалили и создали обычную таблицу.
CREATE TABLE isolation_demo (
    id integer PRIMARY KEY,
    balance integer NOT NULL
);

INSERT INTO isolation_demo (id, balance)
VALUES (1, 100);

SELECT * FROM isolation_demo;
-- Результат: id = 1, balance = 100.

------------------------------------------------------------
-- Шаг 1. READ COMMITTED — уровень по умолчанию
------------------------------------------------------------
-- Предсказание для терминала 2 до COMMIT: 100. Верно.
-- Терминал 1:
BEGIN;
UPDATE isolation_demo
SET balance = 200
WHERE id = 1;
-- Изменение не закоммичено.

-- Терминал 2:
SELECT * FROM isolation_demo;
-- Результат: balance = 100.
-- Чужое неподтверждённое изменение не видно.

-- Предсказание после COMMIT: 200. Верно.
-- Терминал 1:
COMMIT;

-- Терминал 2:
SELECT * FROM isolation_demo;
-- Результат: balance = 200.
-- READ COMMITTED: каждый отдельный запрос получает новый снимок
-- зафиксированных данных на начало этого запроса.

------------------------------------------------------------
-- Шаг 2. REPEATABLE READ — один снимок на всю транзакцию
------------------------------------------------------------
-- Терминал 1 вне явного BEGIN: UPDATE сам является короткой
-- транзакцией и фиксируется автоматически.
UPDATE isolation_demo
SET balance = 100
WHERE id = 1;

-- Терминал 2:
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM isolation_demo;
-- Предсказание: 200. Неверно.
-- Результат: balance = 100 — это значение уже было зафиксировано
-- к началу данной транзакции.

-- Терминал 1:
UPDATE isolation_demo
SET balance = 200
WHERE id = 1;
-- UPDATE 1: новое значение зафиксировано автокоммитом.

-- Терминал 2, всё ещё в той же REPEATABLE READ-транзакции:
SELECT * FROM isolation_demo;
-- Результат: balance = 100.
-- Транзакция продолжает читать первоначальный снимок.

COMMIT;

-- Терминал 2, уже после завершения транзакции:
SELECT * FROM isolation_demo;
-- Предсказание: 200. Верно.
-- Результат: balance = 200.

------------------------------------------------------------
-- Шаг 3. SERIALIZABLE — несовместимые решения
------------------------------------------------------------
-- Бизнес-правило только для сценария, не ограничение таблицы:
-- хотя бы один врач должен остаться дежурным.
-- CHECK не годится: он проверяет одну строку, а правило зависит
-- от нескольких строк.
CREATE TABLE on_call_demo (
    doctor text PRIMARY KEY,
    on_call boolean NOT NULL
);

INSERT INTO on_call_demo (doctor, on_call)
VALUES
    ('Анна', true),
    ('Борис', true);

-- Терминал 1:
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) AS on_call_count
FROM on_call_demo
WHERE on_call = true;
-- Предсказание: 2. Верно. Результат: 2.

-- Терминал 2:
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT COUNT(*) AS on_call_count
FROM on_call_demo
WHERE on_call = true;
-- Результат: 2.

-- Терминал 1:
UPDATE on_call_demo
SET on_call = false
WHERE doctor = 'Анна';

-- Терминал 2:
UPDATE on_call_demo
SET on_call = false
WHERE doctor = 'Борис';

-- Терминал 1:
COMMIT;
-- Успешно.

-- Терминал 2:
COMMIT;
-- ERROR: could not serialize access due to read/write dependencies among transactions
-- DETAIL: Reason code: Canceled on identification as a pivot, during commit attempt.
-- HINT: The transaction might succeed if retried.
-- Предсказание «COMMIT пройдёт» — неверно.
-- Причина: обе транзакции прочитали Анну и Бориса, затем каждая
-- изменила строку, которую читала другая. Получился цикл зависимостей.
-- SERIALIZABLE сохраняет результат, как если бы транзакции шли
-- последовательно; отменённую транзакцию приложение повторяет целиком.

------------------------------------------------------------
-- Шаг 4. Блокировки строк и дедлок
------------------------------------------------------------
INSERT INTO isolation_demo (id, balance)
VALUES (2, 100);

-- Терминал 1:
BEGIN;
UPDATE isolation_demo
SET balance = balance + 10
WHERE id = 1;
-- Строка id = 1 заблокирована до конца транзакции.

-- Терминал 2:
BEGIN;
UPDATE isolation_demo
SET balance = balance + 10
WHERE id = 2;
-- Строка id = 2 заблокирована до конца транзакции.

-- Терминал 1:
UPDATE isolation_demo
SET balance = balance + 10
WHERE id = 2;
-- Предсказание: будет ждать. Верно.
-- Команда ждала, потому что id = 2 удерживал терминал 2.

-- Терминал 2:
UPDATE isolation_demo
SET balance = balance + 10
WHERE id = 1;
-- ERROR: deadlock detected
-- DETAIL: Process 6873 waits for ShareLock on transaction 982; blocked by process 5408.
--         Process 5408 waits for ShareLock on transaction 983; blocked by process 6873.
-- HINT: See server log for query details.
-- CONTEXT: while updating tuple (0,5) in relation "isolation_demo"
-- Приглашение терминала 2 стало =!#.
-- PostgreSQL выбрал терминал 2 жертвой; терминал 1 продолжил и вернул UPDATE 1.

-- Терминал 1:
COMMIT;

-- Терминал 2:
ROLLBACK;

-- Терминал 1:
SELECT id, balance
FROM isolation_demo
ORDER BY id;
-- Предсказание: начальные балансы + 10. Верно.
-- Результат: id = 1, balance = 210; id = 2, balance = 110.
-- Изменения терминала 2 откатились целиком.

------------------------------------------------------------
-- Уборка
------------------------------------------------------------
DROP TABLE on_call_demo;
DROP TABLE isolation_demo;

------------------------------------------------------------
-- Итоги
------------------------------------------------------------
-- READ COMMITTED: новый SELECT после чужого COMMIT видит новое
-- зафиксированное значение, потому что получает новый снимок.
-- REPEATABLE READ: все SELECT внутри одной транзакции используют
-- один снимок, даже после чужого COMMIT.
-- SERIALIZABLE: при цикле read/write-зависимостей PostgreSQL отменяет
-- одну транзакцию; её нужно повторить целиком.
-- Обычная блокировка: одна транзакция ждёт другую.
-- Дедлок: A ждёт ресурс у B, а B ждёт ресурс у A. PostgreSQL отменяет
-- одну транзакцию; жертву нельзя предсказать и на выбор нельзя полагаться.
-- Защита от дедлоков: захватывать несколько строк всегда в одном порядке,
-- держать транзакции короткими и обрабатывать повтор операции после ошибки.
