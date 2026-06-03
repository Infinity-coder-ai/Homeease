from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security.oauth2 import OAuth2PasswordRequestForm
from .. import database, models, utils, schemas
from ..services.auth_sessions import (
  get_refresh_token_record,
  issue_token_pair,
  revoke_refresh_token,
  rotate_refresh_token,
)
from sqlalchemy.orm import session

router = APIRouter(tags=["Auth"])

@router.post("/login")
def login(user_credentials: OAuth2PasswordRequestForm = Depends(), db: session = Depends(database.get_db)):
  user = db.query(models.Users).filter(models.Users.email == user_credentials.username).first()
  if not user:
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,detail="Invalid-Credentials")
  
  if not utils.verify_password(user_credentials.password,user.password):
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,detail="Invalid-Credentials")
  
  if not user.is_active :
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,detail="User is disabled")

  # Email verification gate: users must verify email OTP before login is allowed.
  if not user.email_verified:
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,detail="Email not verified")

  # One login creates a short-lived access token and a revocable refresh token.
  access_token, refresh_token = issue_token_pair(db, user)
  db.commit()
  return schemas.AuthTokens(access_token=access_token, refresh_token=refresh_token)


@router.post("/auth/refresh", response_model=schemas.AuthTokens)
def refresh_token(payload: schemas.RefreshTokenRequest, db: session = Depends(database.get_db)):
  """Exchange a valid refresh token for a new access token.

  The refresh token is rotated on every successful refresh so a stolen token
  becomes useless after the next legitimate refresh.
  """
  record = get_refresh_token_record(db, payload.refresh_token)
  if not record:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

  user = db.query(models.Users).filter(models.Users.id == record.user_id).first()
  if not user or not user.is_active:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User is disabled")

  try:
    access_token, new_refresh_token = rotate_refresh_token(db, payload.refresh_token, user.id)
  except ValueError as exc:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc))

  db.commit()
  return schemas.AuthTokens(access_token=access_token, refresh_token=new_refresh_token)


@router.post("/auth/logout")
def logout(payload: schemas.RefreshTokenRequest, db: session = Depends(database.get_db)):
  """Invalidate the refresh token on the server so it cannot be used again."""
  revoke_refresh_token(db, payload.refresh_token)
  db.commit()
  return {"message": "Logged out"}

  
