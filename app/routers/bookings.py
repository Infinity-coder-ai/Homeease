from .. import models,schemas,oauth2,database
from ..services.notifications import notify_booking_created
from fastapi import APIRouter,status,Depends,HTTPException
from sqlalchemy.orm import session

router  = APIRouter()

@router.post("/bookings")
def create_booking(payload : schemas.BookingCreate,db:session = Depends(database.get_db),current_user = Depends(oauth2.get_curent_user)):
  customer_id = current_user.id
  provider_id = payload.provider_id
  is_avail = db.query(models.ProviderServices).filter(models.ProviderServices.provider_id==provider_id,
                                                   models.ProviderServices.service_id == payload.service_id,
                                                   models.ProviderServices.is_available==True,).first()
  
  # if not avail
  if not is_avail:
    raise HTTPException(
      status_code=status.HTTP_400_BAD_REQUEST,
      detail="Provider is not currently available"
    ) 
    
  if(payload.provider_id == customer_id):
    raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST
                        ,detail="provider cannot book himself")
    
  
  overlapping_booking = db.query(models.Bookings).filter(
    models.Bookings.provider_id == payload.provider_id,
    models.Bookings.booking_date == payload.booking_date,
    models.Bookings.status.in_(["REQUESTED", "ACCEPTED", "IN_PROGRESS"]),
    models.Bookings.start_time < payload.end_time,
    models.Bookings.end_time > payload.start_time 
    ).first()

  if overlapping_booking:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail="Provider is already booked for this time slot"
    )
    
  
  new_booking = models.Bookings(customer_id = customer_id,
                                price = is_avail.price,
                                **payload.model_dump())
  db.add(new_booking)
  # Flush first so the booking gets an id before we write related notifications.
  db.flush()
  notify_booking_created(db, new_booking)
  db.commit()
  db.refresh(new_booking)
  return {"message":"new booking created"}


