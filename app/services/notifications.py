"""Notification service layer.

This module owns the notification business rules:
- create notifications for one or more recipients
- mark notifications as read
- build readable notification text for booking and provider events

Routers call these helpers instead of writing notification logic inline.
"""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Iterable

from sqlalchemy.orm import Session

from .. import models


def _format_date(value) -> str:
    return value.strftime("%d %b %Y")


def _format_time(value) -> str:
    return value.strftime("%I:%M %p").lstrip("0")


def _get_user_name(db: Session, user_id: int) -> str:
    user = db.query(models.Users).filter(models.Users.id == user_id).first()
    return user.name if user else "User"


def _get_service_name(db: Session, service_id: int) -> str:
    service = db.query(models.Services).filter(models.Services.id == service_id).first()
    return service.name if service else "service"


def create_notification(
    db: Session,
    *,
    recipient_user_id: int,
    title: str,
    message: str,
    category: str,
    related_type: str | None = None,
    related_id: int | None = None,
) -> models.Notifications:
    # Keep notification creation in one place so every event writes the same shape.
    notification = models.Notifications(
        recipient_user_id=recipient_user_id,
        title=title,
        message=message,
        category=category,
        related_type=related_type,
        related_id=related_id,
        is_read=False,
    )
    db.add(notification)
    return notification


def create_notifications(
    db: Session,
    recipients: Iterable[int],
    *,
    title: str,
    message: str,
    category: str,
    related_type: str | None = None,
    related_id: int | None = None,
) -> list[models.Notifications]:
    created: list[models.Notifications] = []
    for recipient_user_id in recipients:
        created.append(
            create_notification(
                db,
                recipient_user_id=recipient_user_id,
                title=title,
                message=message,
                category=category,
                related_type=related_type,
                related_id=related_id,
            )
        )
    return created


def list_notifications(
    db: Session,
    user_id: int,
    *,
    unread_only: bool = False,
    limit: int = 50,
    offset: int = 0,
) -> list[models.Notifications]:
    query = db.query(models.Notifications).filter(models.Notifications.recipient_user_id == user_id)
    if unread_only:
        query = query.filter(models.Notifications.is_read.is_(False))
    return (
        query.order_by(models.Notifications.created_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )


def unread_notification_count(db: Session, user_id: int) -> int:
    return (
        db.query(models.Notifications)
        .filter(
            models.Notifications.recipient_user_id == user_id,
            models.Notifications.is_read.is_(False),
        )
        .count()
    )


def mark_notification_read(db: Session, notification_id: int, user_id: int) -> models.Notifications | None:
    notification = (
        db.query(models.Notifications)
        .filter(
            models.Notifications.id == notification_id,
            models.Notifications.recipient_user_id == user_id,
        )
        .first()
    )
    if not notification:
        return None

    # We keep the read timestamp so the inbox can show when the item was handled.
    notification.is_read = True
    notification.read_at = datetime.now(timezone.utc)
    return notification


def mark_all_notifications_read(db: Session, user_id: int) -> int:
    # Bulk update is simpler and faster than loading every unread notification.
    affected = (
        db.query(models.Notifications)
        .filter(
            models.Notifications.recipient_user_id == user_id,
            models.Notifications.is_read.is_(False),
        )
        .update(
            {
                models.Notifications.is_read: True,
                models.Notifications.read_at: datetime.now(timezone.utc),
            },
            synchronize_session=False,
        )
    )
    return affected


def notify_booking_created(db: Session, booking: models.Bookings) -> None:
    # Notify both sides so the customer and provider see the same booking event.
    service_name = _get_service_name(db, booking.service_id)
    customer_name = _get_user_name(db, booking.customer_id)
    booking_date = _format_date(booking.booking_date)
    slot = f"{_format_time(booking.start_time)} - {_format_time(booking.end_time)}"

    create_notification(
        db,
        recipient_user_id=booking.provider_id,
        title="New booking request",
        message=f"{customer_name} requested {service_name} for {booking_date} at {slot}.",
        category="BOOKING",
        related_type="booking",
        related_id=booking.id,
    )
    create_notification(
        db,
        recipient_user_id=booking.customer_id,
        title="Booking request sent",
        message=f"Your {service_name} request for {booking_date} at {slot} has been sent to the provider.",
        category="BOOKING",
        related_type="booking",
        related_id=booking.id,
    )


def notify_booking_accepted(db: Session, booking: models.Bookings) -> None:
    service_name = _get_service_name(db, booking.service_id)
    booking_date = _format_date(booking.booking_date)
    slot = f"{_format_time(booking.start_time)} - {_format_time(booking.end_time)}"

    create_notification(
        db,
        recipient_user_id=booking.customer_id,
        title="Booking accepted",
        message=f"Your {service_name} booking for {booking_date} at {slot} was accepted.",
        category="BOOKING",
        related_type="booking",
        related_id=booking.id,
    )


def notify_booking_completed(db: Session, booking: models.Bookings) -> None:
    service_name = _get_service_name(db, booking.service_id)
    booking_date = _format_date(booking.booking_date)

    create_notification(
        db,
        recipient_user_id=booking.customer_id,
        title="Booking completed",
        message=f"Your {service_name} booking on {booking_date} has been marked completed.",
        category="BOOKING",
        related_type="booking",
        related_id=booking.id,
    )


def notify_booking_canceled(
    db: Session,
    booking: models.Bookings,
    *,
    canceled_by: str,
) -> None:
    # The recipient depends on who canceled the booking.
    # Customer cancel -> notify provider. Provider cancel -> notify customer.
    service_name = _get_service_name(db, booking.service_id)
    booking_date = _format_date(booking.booking_date)

    if canceled_by == "CUSTOMER":
        customer_name = _get_user_name(db, booking.customer_id)
        create_notification(
            db,
            recipient_user_id=booking.provider_id,
            title="Booking canceled by customer",
            message=f"{customer_name} canceled the {service_name} booking on {booking_date}.",
            category="BOOKING",
            related_type="booking",
            related_id=booking.id,
        )
        return

    create_notification(
        db,
        recipient_user_id=booking.customer_id,
        title="Booking canceled",
        message=f"Your {service_name} booking on {booking_date} was canceled by the provider.",
        category="BOOKING",
        related_type="booking",
        related_id=booking.id,
    )


def notify_provider_document_decision(
    db: Session,
    *,
    provider_id: int,
    document_type: str,
    approved: bool,
) -> None:
    title = "Document approved" if approved else "Document rejected"
    message = (
        f"Your {document_type} document was approved and your verification can continue."
        if approved
        else f"Your {document_type} document was rejected. Please upload a clearer or corrected copy."
    )
    create_notification(
        db,
        recipient_user_id=provider_id,
        title=title,
        message=message,
        category="PROVIDER",
    )


def notify_provider_application_approved(db: Session, provider_id: int) -> None:
    create_notification(
        db,
        recipient_user_id=provider_id,
        title="Provider application approved",
        message="Your background verification is approved. You can now complete the provider workflow.",
        category="PROVIDER",
    )


def notify_provider_application_rejected(db: Session, provider_id: int) -> None:
    create_notification(
        db,
        recipient_user_id=provider_id,
        title="Provider application rejected",
        message="Your provider application was rejected. You can review the application details and try again.",
        category="PROVIDER",
    )


def notify_provider_role_assigned(db: Session, provider_id: int) -> None:
    create_notification(
        db,
        recipient_user_id=provider_id,
        title="Provider access enabled",
        message="Your account now has provider access. The provider dashboard is ready to use.",
        category="PROVIDER",
    )
