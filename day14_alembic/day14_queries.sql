-- День 14. Alembic и миграции.
-- База: shop. Выполнены реальные проверки и одна ручная миграция.
-- Секреты и строка подключения из .env намеренно не хранятся в этом файле.

-- До миграции: у products было 5 столбцов; description отсутствовал.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
ORDER BY ordinal_position;

-- Инициализация выполнена в терминале из day14_alembic:
-- ../day12_sqlalchemy/.venv/bin/alembic init alembic
-- Созданы alembic.ini, alembic/env.py, alembic/versions/.

-- Создание ревизии (эта команда создаёт файл, но ещё не меняет базу):
-- ../day12_sqlalchemy/.venv/bin/alembic revision -m "add description to products"
-- Создана ревизия: 719344075c89_add_description_to_products.py.

-- Содержимое upgrade() в миграции:
-- op.add_column(
--     "products",
--     sa.Column("description", sa.Text(), nullable=True),
-- )

-- Содержимое downgrade() в миграции:
-- op.drop_column("products", "description")

-- Первая попытка применения:
-- ../day12_sqlalchemy/.venv/bin/alembic upgrade head
-- Alembic отметил ревизию как head, но столбец не появился:
-- во время запуска файл миграции ещё содержал исходный pass.
-- Проверка текущего статуса показала: 719344075c89 (head).

-- Исправление рассинхронизации: команда меняет только отметку Alembic,
-- не выполняя DDL. downgrade -1 применять было нельзя: description не существовал.
-- ../day12_sqlalchemy/.venv/bin/alembic stamp base

-- Повторное применение сохранённого файла миграции:
-- ../day12_sqlalchemy/.venv/bin/alembic upgrade head

-- После upgrade: 6 столбцов, description имеет тип text и допускает NULL.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
ORDER BY ordinal_position;

-- Alembic хранит применённую ревизию в служебной таблице.
SELECT version_num
FROM alembic_version;

-- Проверка отката:
-- ../day12_sqlalchemy/.venv/bin/alembic downgrade -1
-- После отката description исчез; products снова содержал 5 столбцов.

-- Финальное состояние дня: миграция применена повторно.
-- ../day12_sqlalchemy/.venv/bin/alembic upgrade head
-- ../day12_sqlalchemy/.venv/bin/alembic current
-- Результат current: 719344075c89 (head).

-- Финальная проверка: в products снова 6 столбцов,
-- description | text | YES.
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'products'
ORDER BY ordinal_position;
