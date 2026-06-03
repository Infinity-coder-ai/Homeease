from fastapi import APIRouter,HTTPException,Depends,status
from psycopg2 import IntegrityError
from sqlalchemy.orm import session
from .. import database, models,schemas ,oauth2

router = APIRouter()

@router.post("/create_services")
def create_services(
    payload: schemas.ProviderServiceCreate,
    db: session = Depends(database.get_db),current_user = Depends(oauth2.get_curent_user)):
    provider_id = current_user.id 
    service_id = payload.service_id
    
    #check if provider exist or not for thiwh service is creating 
    
    #check if already exist pair 
    provider = (
        db.query(models.ServiceProviders)
        .filter(models.ServiceProviders.id == provider_id)
        .first()
        )
    if not provider:
        raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Create provider profile before adding services",
    )
    exists = (
        db.query(models.ProviderServices)
        .filter(
            models.ProviderServices.provider_id == provider_id,
            models.ProviderServices.service_id == service_id,
        )
        .first()
    )
    if exists:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="you are already registered for this service",
        )

    new_row = models.ProviderServices(
        provider_id=provider_id,
        service_id=service_id,
        price=payload.price,
        estimated_duration_minutes=payload.estimated_duration_minutes,
    )

    db.add(new_row)

    #  also catch DB-level UniqueConstraint (race-condition safe)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="you are already registered for this service",
        )

    db.refresh(new_row)
    return new_row


# Use a DB UniqueConstraint(provider_id, service_id) plus try: db.commit() except IntegrityError to handle race conditions: one insert succeeds, the duplicate gets 409 Conflict.
# Call db.rollback() after a failed commit to reset the session/transaction, otherwise the session stays aborted and later DB operations can fail.
   
  