from sqlalchemy import create_engine, update
from .config import settings
from urllib.parse import quote_plus
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base


encoded_password = quote_plus(settings.database_password)

SQLALCHEMY_DATABASE_URL = (
    f"postgresql://{settings.database_username}:"
    f"{encoded_password}@"
    f"{settings.database_hostname}:"
    f"{settings.database_port}/"
    f"{settings.database_name}"
)

engine = create_engine(
  SQLALCHEMY_DATABASE_URL,
  pool_pre_ping=True,
  pool_recycle=300,
  connect_args={
    "sslmode": "require",
    "connect_timeout": 10,
    "keepalives": 1,
    "keepalives_idle": 30,
    "keepalives_interval": 10,
    "keepalives_count": 5,
  },
)

SessionLocal = sessionmaker(autocommit=False,autoflush=False,bind=engine)
Base = declarative_base()

def get_db():
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()


def init_db():
  """Initialize database schema and run migrations."""
  from . import models
  
  models.Base.metadata.create_all(bind=engine)
  
  with engine.begin() as conn:
    conn.execute(
      update(models.ProviderDocuments)
      .where(models.ProviderDocuments.document_type == 'ID_PROOF')
      .values(document_type='AADHAAR')
    )
