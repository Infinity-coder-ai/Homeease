from fastapi import APIRouter,Depends,HTTPException,status
from .. import database,schemas,oauth2,models
from sqlalchemy.orm import session
from sqlalchemy.exc import IntegrityError

router = APIRouter()

@router.post("/providers/availability")
def create_availability(payload:schemas.ProviderAvailabilityBulkCreate ,db:session  =Depends(database.get_db),current_user = Depends(oauth2.get_curent_user)):
  provider_id = current_user.id
  rows=[]
  for s in payload.slots:
    rows.append(
      models.ProviderAvailability(
        provider_id =provider_id,
        **s.model_dump()
      )
    )
    
  db.add_all(rows)
  try:
      db.commit()
  except IntegrityError:  # happens if the same exact slot already exists (due to UniqueConstraint)
      db.rollback()
      raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="One or more availability slots already exist.",
    )
      
      
  return {"message": "slots added"}


# this will returned to the ui that when is a provider available
@router.get("/providers/availability", response_model=list[schemas.ProviderAvailabilityOut])
def list_availability(
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):
    return (
        db.query(models.ProviderAvailability)
        .filter(models.ProviderAvailability.provider_id == current_user.id)
        .all()
    )
    
    
    
# to delete the slots
@router.delete("/providers/availability/{slot_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_availability(
    slot_id: int,
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user),
):
    slot = (
        db.query(models.ProviderAvailability)
        .filter(
            models.ProviderAvailability.id == slot_id,
            models.ProviderAvailability.provider_id == current_user.id,
        )
        .first()
    )
    if not slot:
        raise HTTPException(status_code=404, detail="Slot not found")

    db.delete(slot)
    db.commit()
    return