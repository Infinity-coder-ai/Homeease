from ... import models,database,oauth2,schemas,utils
from sqlalchemy.orm import session
from fastapi import APIRouter,Depends,status,HTTPException

router = APIRouter()

@router.post("/rating/{booking_id}")
def provider_rating(
  payload :schemas.Rating,
  booking_id : int,
  db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):
  
  # if rating already exist for this booking
  existing = db.query(models.Ratings).filter(
    models.Ratings.booking_id == booking_id
    ).first()
  if existing:
    raise HTTPException(status_code=400, detail="Booking already rated")
  
  booking = db.query(models.Bookings).filter(models.Bookings.id == booking_id).first()
  if not booking:
    raise HTTPException(status_code=404, detail="Booking not found")
  
  new_rating = models.Ratings(
    booking_id = booking.id,
    customer_id = booking.customer_id,
    provider_id = booking.provider_id,
    service_id = booking.service_id,
    rating = payload.rating,
    review = payload.review
  )
  
  db.add(new_rating)
  db.flush()
  utils.recalculate_trust_score(db, booking.provider_id)
  db.commit()
  db.refresh(new_rating)
  return {"message":"new rating added successfuly"}
