from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = "sqlite:///./smartspend.db"#Kade se chuva datata,go kreira smart_spend.db

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})#Konekcijata so databazata 
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)

Base = declarative_base()#Parent class za site modeli,so ova go pravime modelot table
