from fastapi import FastAPI, HTTPException
from os import getenv
from sqlalchemy import Column, BigInteger, Numeric, String, create_engine, inspect
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy_utils import database_exists, create_database

class StockEntity(declarative_base()):
    __tablename__ = "stocks1"
    company = Column(String, primary_key=True)
    timestamp = Column(BigInteger, primary_key=True)
    price = Column(Numeric(999, 99))

def add_entity(Session: sessionmaker, company: str, timestamp: int, price: float):
    with Session() as session:
        if session.get(StockEntity, (company, timestamp)) is None:
            session.add(StockEntity(company=company, timestamp=timestamp, price=price))
            session.commit()

def add_entities(Session: sessionmaker):
    add_entity(Session, "A", "1", 120.0)
    add_entity(Session, "B", "1", 120.0)
    add_entity(Session, "C", "1", 121.0)
    add_entity(Session, "D", "1", 200.0)
    add_entity(Session, "E", "1", 123.0)
    add_entity(Session, "F", "1", 124.0)
    add_entity(Session, "G", "1", 125.0)

def setup_db():
    user, pwd, host, name, port  = getenv("USERNAME"), getenv("PASSWORD"), getenv("ENDPOINT"), getenv("DATABASE_NAME"), getenv("PORT")
    db_url = f"postgresql://{user}:{pwd}@{host}:{port}/{name}"
    engine = create_engine(db_url)
    if not database_exists(engine.url): create_database(engine.url)
    if not inspect(engine).has_table(StockEntity.__tablename__): StockEntity.__table__.create(engine)
    Session = sessionmaker(bind=engine)
    add_entities(Session)
    return Session

Session = setup_db()
app = FastAPI()

@app.get("/stock")
async def get_stock_data(company: str, timestamp: str):
    with Session() as session:
        result = session.get(StockEntity, (company, timestamp))
        if result is None:
            raise HTTPException(status_code=404, detail="Stock data not found")
        return {"company": result.company, "timestamp": result.timestamp, "price": result.price}