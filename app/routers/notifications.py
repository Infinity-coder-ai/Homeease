"""Notification API endpoints.

This router is intentionally small: it only exposes inbox reads and read-state
updates. All business logic lives in app.services.notifications.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import session

from .. import database, oauth2, schemas
from ..services.notifications import (
    list_notifications,
    mark_all_notifications_read,
    mark_notification_read,
    unread_notification_count,
)


router = APIRouter(tags=["Notifications"])


@router.get("/notifications/me", response_model=list[schemas.NotificationOut])
def get_my_notifications(
    unread_only: bool = False,
    limit: int = 50,
    offset: int = 0,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    # The inbox is always scoped to the authenticated user.
    return list_notifications(
        db,
        current_user.id,
        unread_only=unread_only,
        limit=limit,
        offset=offset,
    )


@router.get("/notifications/me/unread-count")
def get_my_unread_count(
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    return {"unread_count": unread_notification_count(db, current_user.id)}


@router.patch("/notifications/{notification_id}/read")
def mark_notification_as_read(
    notification_id: int,
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    notification = mark_notification_read(db, notification_id, current_user.id)
    if not notification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")

    db.commit()
    return {"message": "Notification marked as read"}


@router.patch("/notifications/me/read-all")
def mark_all_my_notifications_as_read(
    db: session = Depends(database.get_db),
    current_user=Depends(oauth2.get_curent_user),
):
    affected = mark_all_notifications_read(db, current_user.id)
    db.commit()
    return {"message": "All notifications marked as read", "updated": affected}
