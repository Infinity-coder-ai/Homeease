from .config import settings
from fastapi import Depends, status, HTTPException
from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from . import schemas, database, models
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import session


oauth2_scheme = OAuth2PasswordBearer(tokenUrl = 'login')

SECRET_KEY  = settings.secret_key
ALGORITHM = settings.algorithm
# Access tokens should stay short-lived on mobile apps.
ACCESS_TOKEN_EXPIRE_MINUTES = 30
 

def create_access_token(data: dict):
  to_encode = data.copy()  # dict payload copied before adding exp
  expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
  to_encode.update({"exp": expire})
  encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
  return encoded_jwt
  
  
def verify_access_token(token: str, credentials_exception):
  try:
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    
    id: str = payload.get("user_id")
    if id is None:
      raise credentials_exception
    token_data = schemas.TokenData(id=id)
    
  except JWTError:
    raise credentials_exception

  return token_data


def get_curent_user(token: str = Depends(oauth2_scheme), db: session = Depends(database.get_db)):
  credentials_exception = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="not validate credentails",
    headers={"WWW-Authenticate": "Bearer"}
  )
  token = verify_access_token(token, credentials_exception)  # pydantic token payload
  user = db.query(models.Users).filter(models.Users.id == token.id).first()
  return user # orm model
