from ... import models,database,oauth2,schemas
from sqlalchemy.orm import session
from fastapi import APIRouter,Depends,status,HTTPException

router= APIRouter()
@router.get("/bookings/my", status_code=status.HTTP_200_OK, response_model=list[schemas.BookingHistory])
def customer_bookings(
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):
  bookings = (
    db.query(
        models.Bookings.id,
        models.Bookings.provider_id,
        models.Users.name.label("provider_name"),
        models.Bookings.service_id,
        models.Services.name.label("service_name"),
        models.Bookings.booking_date,
        models.Bookings.start_time,
        models.Bookings.end_time,
        models.Bookings.price,
        models.Bookings.status,
        models.Bookings.canceled_by,
        models.Ratings.rating.label("rating"),
        models.Ratings.review.label("review"),
    )
    .join(models.Users, models.Users.id == models.Bookings.provider_id)
    .join(models.Services, models.Services.id == models.Bookings.service_id)
    .outerjoin(models.Ratings, models.Ratings.booking_id == models.Bookings.id)
    .filter(models.Bookings.customer_id == current_user.id)
    .all()
)

  return bookings