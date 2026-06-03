from fastapi import APIRouter,status,Depends
from .. import models,schemas,utils,oauth2
from sqlalchemy.orm import session

from ..database import get_db,engine
router = APIRouter()

@router.post("/users",status_code=status.HTTP_201_CREATED,response_model=schemas.UserOut)
def create_user(user:schemas.UserCreate,db:session = Depends(get_db)):
  hashed_password = utils.hash_pass(user.password)
  user.password = hashed_password
  #pydantic to orm 
  new_user = models.Users(**user.model_dump()) # pydantic to dictonar then into orm
  # New accounts start unverified until OTP verification succeeds.
  new_user.email_verified = False
  db.add(new_user)
  db.commit()
  db.refresh(new_user)
  return new_user


@router.get("/users/me", response_model=schemas.UserMe)
def get_me(current_user=Depends(oauth2.get_curent_user)):
  return current_user
