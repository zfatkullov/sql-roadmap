from getpass import getpass
from decimal import Decimal

from sqlalchemy.orm import DeclarativeBase, mapped_column, Mapped, Session
from sqlalchemy import String, Numeric, Boolean, create_engine, select

class Base(DeclarativeBase):
    pass


class Product(Base):
    __tablename__ = 'products'
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String)
    price: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    in_stock: Mapped[bool] = mapped_column(Boolean)


password = getpass('пароль от shop_user')
database_url = f'postgresql+psycopg://shop_user:{password}@localhost:5432/shop'
engine = create_engine(database_url, echo=True)


with Session(engine) as session:
    stmt = select(Product).where(Product.in_stock.is_(True), Product.price < 5000).order_by(Product.price)

    products = session.scalars(stmt).all()

    for product in products:
        print(f'name={product.name}, price={product.price}')
