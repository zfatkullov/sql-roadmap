from datetime import datetime
from getpass import getpass
from decimal import Decimal

from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship, Session, selectinload, join
from sqlalchemy import DateTime, ForeignKey, create_engine, select, Boolean, String, Numeric, func


class Base(DeclarativeBase):
    pass


class Customer(Base):
    __tablename__ = 'customers'

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    orders: Mapped[list['ShopOrder']] = relationship(back_populates='customer')


class ShopOrder(Base):
    __tablename__ = 'shop_orders'

    id: Mapped[int] = mapped_column(primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime)
    customer_id: Mapped[int] = mapped_column(ForeignKey('customers.id'))
    customer: Mapped['Customer'] = relationship(back_populates='orders')
    items: Mapped[list['OrderItem']] = relationship(back_populates='order')


class Product(Base):
    __tablename__ = 'products'

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String)
    price: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    in_stock: Mapped[bool] = mapped_column(Boolean)
    created_at: Mapped[datetime] = mapped_column(DateTime)
    items: Mapped[list['OrderItem']] = relationship(back_populates='product')


class OrderItem(Base):
    __tablename__ = 'order_items'

    id: Mapped[int] = mapped_column(primary_key=True)
    order_id: Mapped[int] = mapped_column(ForeignKey('shop_orders.id'))
    product_id: Mapped[int] = mapped_column(ForeignKey('products.id'))
    quantity: Mapped[int]
    unit_price: Mapped[Decimal] = mapped_column(Numeric(10, 2))
    order: Mapped['ShopOrder'] = relationship(back_populates='items')
    product: Mapped['Product'] = relationship(back_populates='items')

password = getpass('Введите пароль от shop_user ')
database_url = f'postgresql+psycopg://shop_user:{password}@localhost:5432/shop'
engine = create_engine(database_url, echo=True)


# with Session(engine) as session:
#     stmt = select(Customer.name, Product.name, OrderItem.quantity, OrderItem.unit_price).join(Customer.orders).join(ShopOrder.items).join(OrderItem.product).order_by(OrderItem.id)

#     orders = session.execute(stmt).all()

#     for row in orders:
#         print(row)

with Session(engine) as session:
    stmt = select(Customer.name, func.sum(OrderItem.quantity * OrderItem.unit_price).label('total')).join(Customer.orders).join(ShopOrder.items).group_by(Customer.id, Customer.name).order_by(Customer.id)

    orders = session.execute(stmt).all()

    for row in orders:
        print(row)
