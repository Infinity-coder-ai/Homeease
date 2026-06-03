from ... import models,database,oauth2,schemas
from sqlalchemy.orm import session
from fastapi import APIRouter,Depends,status,HTTPException

router = APIRouter()
@router.get("/providers/bookings", response_model=list[schemas.ProviderBookingOut])
def provider_bookings(
  db: session = Depends(database.get_db),
  current_user = Depends(oauth2.get_curent_user)
):
  bookings = (
      db.query(
          models.Bookings.id,
          models.Bookings.customer_id,
          models.Users.name.label("customer_name"),
          models.Users.phone.label("customer_phone"),
          models.Bookings.service_id,
          models.Bookings.booking_date,
          models.Bookings.start_time,
          models.Bookings.end_time,
          models.Bookings.price,
          models.Bookings.status,
          models.Bookings.canceled_by,
          models.Bookings.address,
          models.Bookings.city,
          models.Bookings.pincode,
          models.Bookings.landmark,
      )
      .join(models.Users, models.Users.id == models.Bookings.customer_id)
      .filter(models.Bookings.provider_id == current_user.id)
      .all()
  )
  return bookings
  # if current_user.role != "provider":
  #   raise HTTPException(status_code=403, detail="Only providers allowed")