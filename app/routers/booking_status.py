from .. import models,database,schemas,oauth2,utils
from ..services.notifications import (
    notify_booking_accepted,
    notify_booking_canceled,
    notify_booking_completed,
)
from sqlalchemy.orm import session
from fastapi import APIRouter,Depends,status,HTTPException
from datetime import datetime

router = APIRouter()

@router.patch("/bookings/{booking_id}/accept",status_code=status.HTTP_200_OK)
def accept_booking(
    booking_id: int,
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):

    booking = db.query(models.Bookings).filter(
        models.Bookings.id == booking_id
    ).first()

    if not booking:
        raise HTTPException(
            status_code=404,
            detail="Booking not found"
        )

    # only provider can accept
    if booking.provider_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Only provider can accept this booking"
        )

    # status validation
    if booking.status != "REQUESTED":
        raise HTTPException(
            status_code=400,
            detail="Booking cannot be accepted"
        )

    booking.status = "ACCEPTED"

    # Notify the customer immediately so the app inbox reflects the state change.
    notify_booking_accepted(db, booking)

    db.commit()
    db.refresh(booking)

    return {"message": "Booking accepted successfully"}
  
  
  

@router.patch("/bookings/{booking_id}/complete",status_code=status.HTTP_200_OK)
def complete_booking(
    booking_id: int,
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):

    booking = db.query(models.Bookings).filter(
        models.Bookings.id == booking_id
    ).first()

    if not booking:
        raise HTTPException(
            status_code=404,
            detail="Booking not found"
        )

    # only provider can accept
    if booking.provider_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Only provider can complete this booking"
        )

    # status validation
    if booking.status != "ACCEPTED":
        raise HTTPException(
            status_code=400,
            detail="Booking cannot be Completed"
        )
        
    # this is for chekc only after time finish provider can complete booking
    current_datetime = datetime.now()
    today = current_datetime.date()
    now_time = current_datetime.time()

    if booking.booking_date > today:
        raise HTTPException(
            status_code=400,
            detail="Booking time has not finished yet"
        )

    if booking.booking_date == today and booking.end_time > now_time:
        raise HTTPException(
            status_code=400,
            detail="Booking time has not finished yet"
        )

    booking.status = "COMPLETED"
    
    provider  = db.query(models.ServiceProviders).filter(models.ServiceProviders.id==booking.provider_id).first()
    provider.total_jobs_completed += 1
    utils.recalculate_trust_score(db, booking.provider_id)

    # Completed jobs should be visible in the customer inbox as a closing update.
    notify_booking_completed(db, booking)

    
    

    db.commit()
    db.refresh(booking)

    return {"message": "Booking completed successfully"}
  
  
    

@router.patch("/bookings/{booking_id}/cancel",status_code=status.HTTP_200_OK)
def cancel_booking(
    booking_id: int,
    db: session = Depends(database.get_db),
    current_user = Depends(oauth2.get_curent_user)
):

    booking = db.query(models.Bookings).filter(
        models.Bookings.id == booking_id
    ).first()

    if not booking:
        raise HTTPException(
            status_code=404,
            detail="Booking not found"
        )

    # Either side can cancel, but only for their own booking.
    if current_user.id == booking.provider_id:
        canceled_by = "PROVIDER"
    elif current_user.id == booking.customer_id:
        canceled_by = "CUSTOMER"
    else:
        raise HTTPException(
            status_code=403,
            detail="Only the customer or provider can cancel this booking"
        )

    # status validation
    if booking.status not in  ["REQUESTED","ACCEPTED"] :
        raise HTTPException(
            status_code=400,
            detail="Booking cannot be canceled"
        )

    booking.status = "CANCELED"
    booking.canceled_by = canceled_by

    # Provider cancellations count toward trust stats.
    if canceled_by == "PROVIDER":
        provider  = db.query(models.ServiceProviders).filter(models.ServiceProviders.id==booking.provider_id).first()
        provider.total_cancellations += 1
        utils.recalculate_trust_score(db, booking.provider_id)

    # Write a notification for the opposite side so both inboxes stay in sync.
    notify_booking_canceled(db, booking, canceled_by=canceled_by)

    db.commit()
    db.refresh(booking)

    return {"message": "Booking canceled successfully"}
