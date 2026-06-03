import hashlib
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status

from . import models
from .config import settings


OTP_TTL_MINUTES = 10
RESET_TTL_MINUTES = 30


def _hash_with_pepper(value: str) -> str:
    # Pepper ties tokens to this app instance (SECRET_KEY). Prevents rainbow-table reuse.
    pepper = settings.secret_key
    return hashlib.sha256(f"{pepper}:{value}".encode("utf-8")).hexdigest()


def hash_otp(otp: str) -> str:
    return _hash_with_pepper(otp)


def generate_email_otp() -> str:
    # 6-digit numeric OTP.
    return f"{secrets.randbelow(1_000_000):06d}"


def create_signup_email_otp(db, email: str) -> str:
    otp = generate_email_otp()
    now = datetime.now(timezone.utc)
    row = models.EmailOtps(
        email=email.lower().strip(),
        purpose="SIGNUP_VERIFY",
        otp_hash=_hash_with_pepper(otp),
        expires_at=now + timedelta(minutes=OTP_TTL_MINUTES),
    )
    db.add(row)
    db.commit()
    return otp


def verify_signup_email_otp(db, email: str, otp: str) -> None:
    now = datetime.now(timezone.utc)
    email_norm = email.lower().strip()
    otp_hash = _hash_with_pepper(otp)

    row = (
        db.query(models.EmailOtps)
        .filter(
            models.EmailOtps.email == email_norm,
            models.EmailOtps.purpose == "SIGNUP_VERIFY",
            models.EmailOtps.consumed_at.is_(None),
            models.EmailOtps.expires_at > now,
        )
        .order_by(models.EmailOtps.created_at.desc())
        .first()
    )
    if not row or row.otp_hash != otp_hash:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired OTP",
        )

    row.consumed_at = now
    user = db.query(models.Users).filter(models.Users.email == email_norm).first()
    if user:
        user.email_verified = True
    db.commit()


def create_password_reset_token(db, user_id: int) -> str:
    token = secrets.token_urlsafe(32)
    now = datetime.now(timezone.utc)
    row = models.PasswordResetTokens(
        user_id=user_id,
        token_hash=_hash_with_pepper(token),
        expires_at=now + timedelta(minutes=RESET_TTL_MINUTES),
    )
    db.add(row)
    db.commit()
    return token


def consume_password_reset_token(db, token: str) -> int:
    now = datetime.now(timezone.utc)
    token_hash = _hash_with_pepper(token)
    row = (
        db.query(models.PasswordResetTokens)
        .filter(
            models.PasswordResetTokens.token_hash == token_hash,
            models.PasswordResetTokens.used_at.is_(None),
            models.PasswordResetTokens.expires_at > now,
        )
        .first()
    )
    if not row:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token",
        )
    row.used_at = now
    db.commit()
    return row.user_id
