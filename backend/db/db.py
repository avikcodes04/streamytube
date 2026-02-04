from sqlalchemy import create_engine
from secret_keys import SecretKeys
from sqlalchemy.orm import sessionmaker


secret_keys = SecretKeys()
engine = create_engine(secret_keys.POSTGRES_DB_URL)
sessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = sessionLocal()
    try:
        yield db
    finally:
        db.close()