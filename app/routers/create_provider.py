from .. import models,schemas,oauth2,database
from fastapi import APIRouter,status,Depends,HTTPException
from sqlalchemy.orm import session

router = APIRouter()

@router.post("/create_provider",status_code=status.HTTP_201_CREATED)
def create_provider(provider : schemas.ProviderCreate ,db : session = Depends(database.get_db),current_user = Depends(oauth2.get_curent_user)):
  provider_id = current_user.id
  is_exist = db.query(models.ServiceProviders).filter(
        models.ServiceProviders.id == provider_id
    ).first()
  if is_exist:
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,detail="You are already regisetered")
  # Applying creates a pending provider application. The user role remains
  # customer until admin approves the fully verified application.
  new_provider = models.ServiceProviders(
    id=provider_id,
    verification_status="PENDING",
    documents_verified=False,
    **provider.model_dump()
  )
  db.add(new_provider)
  db.commit()
  db.refresh(new_provider)
  return new_provider
  
    
