from datetime import datetime
from decimal import Decimal
from getpass import getpass

from sqlalchemy import Boolean, DateTime, Numeric, String, create_engine, select
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column

class Base(DeclarativeBase):
    ...


class Product(Base):
    __tablename__ = 'products'

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String)
    price: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    in_stock: Mapped[bool] = mapped_column(Boolean)
    created_at: Mapped[datetime] = mapped_column(DateTime)

    def __repr__(self) -> str:
        return (
            f'Product(id={self.id}, name={self.name!r} ,'
            f'price={self.price}, in_stock={self.in_stock})'
        )


password = getpass('Пароль shop_user ')
database_url = f'postgresql+psycopg://shop_user:{password}@localhost:5432/shop'
engine = create_engine(database_url, echo=True)


with Session(engine) as session:
    statement = select(Product).where(Product.in_stock.is_(True)).order_by(Product.price.desc())

    result = session.scalars(statement)

    for row in result:
        print(f'{row.name}: {row.price}')