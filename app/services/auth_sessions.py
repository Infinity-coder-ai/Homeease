"""Authentication session helpers.

This module keeps the auth router thin by handling refresh-token creation,
hashing, lookup, revocation, and rotation in one place.
Access tokens remain JWTs; refresh tokens are opaque random strings stored
hashed in the database.
"""

from __future__ import annotations

import hashlib
import secrets
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from .. import models, oauth2


ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 30


def hash_refresh_token(refresh_token: str) -> str:
    """Store only a hash of the refresh token so the raw value is never persisted."""
    return hashlib.sha256(refresh_token.encode("utf-8")).hexdigest()


def create_refresh_token_value() -> str:
    """Generate a high-entropy opaque refresh token for mobile clients."""
    return secrets.token_urlsafe(64)


def create_refresh_token_record(db: Session, user_id: int) -> tuple[str, models.RefreshTokens]:
    """Create and stage a new refresh-token row for a user."""
    refresh_token = create_refresh_token_value()
    refresh_token_row = models.RefreshTokens(
        user_id=user_id,
        token_hash=hash_refresh_token(refresh_token),
        expires_at=datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS),
    )
    db.add(refresh_token_row)
    db.flush()
    return refresh_token, refresh_token_row


def issue_token_pair(db: Session, user: models.Users) -> tuple[str, str]:
    """Issue a fresh JWT access token and a server-tracked refresh token."""
    access_token = oauth2.create_access_token({"user_id": user.id})
    refresh_token, _ = create_refresh_token_record(db, user.id)
    return access_token, refresh_token


def get_refresh_token_record(db: Session, refresh_token: str):
    """Lookup a stored refresh token row by its raw value."""
    token_hash = hash_refresh_token(refresh_token)
    return db.query(models.RefreshTokens).filter(models.RefreshTokens.token_hash == token_hash).first()


def revoke_refresh_token(db: Session, refresh_token: str) -> bool:
    """Revoke a refresh token if it exists. Returns True when a row was touched."""
    record = get_refresh_token_record(db, refresh_token)
    if not record:
        return False

    if record.revoked_at is None:
        record.revoked_at = datetime.now(timezone.utc)
    return True


def rotate_refresh_token(db: Session, refresh_token: str, user_id: int) -> tuple[str, str]:
    """Revoke the current refresh token and replace it with a new one.

    This is the standard mobile pattern: one refresh token is active at a time
    per session, so leaked tokens become unusable after the next refresh.
    """
    current_record = get_refresh_token_record(db, refresh_token)
    if current_record is None:
      raise ValueError("Invalid refresh token")

    now = datetime.now(timezone.utc)
    if current_record.revoked_at is not None:
        raise ValueError("Refresh token has been revoked")
    if current_record.expires_at <= now:
        raise ValueError("Refresh token has expired")
    if current_record.user_id != user_id:
        raise ValueError("Refresh token does not belong to this user")

    current_record.revoked_at = now
    new_refresh_token, _ = create_refresh_token_record(db, user_id)
    current_record.last_used_at = now
    current_record.replaced_by_token_hash = hash_refresh_token(new_refresh_token)

    access_token = oauth2.create_access_token({"user_id": user_id})
    return access_token, new_refresh_token
