from fastapi import APIRouter, Depends, HTTPException, status, Request, Form
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import session

from .. import database, models, utils
from ..email_service import send_email
from datetime import datetime, timedelta, timezone

from ..email_tokens import (
    create_password_reset_token,
    consume_password_reset_token,
    generate_email_otp,
    hash_otp,
)


router = APIRouter(tags=["Email Auth"])

OTP_TTL_MINUTES = 10


@router.post("/auth/signup/start", status_code=status.HTTP_200_OK)
def signup_start(payload: dict, db: session = Depends(database.get_db)):
    """
    Starts signup by creating/updating a signup intent and emailing an OTP.
    No row is created in users table until /auth/signup/verify succeeds.
    """
    name = (payload.get("name") or "").strip()
    email = (payload.get("email") or "").lower().strip()
    phone = (payload.get("phone") or "").strip()
    password = (payload.get("password") or "").strip()

    if not name or not email or not phone or not password:
        raise HTTPException(status_code=400, detail="name, email, phone, password are required")

    existing_user = db.query(models.Users).filter(models.Users.email == email).first()
    if existing_user:
        raise HTTPException(status_code=409, detail="Email already registered")

    now = datetime.now(timezone.utc)
    otp = generate_email_otp()
    otp_hash = hash_otp(otp)

    intent = db.query(models.SignupIntents).filter(models.SignupIntents.email == email).first()
    if not intent:
        intent = models.SignupIntents(
            email=email,
            name=name,
            phone=phone,
            password_hash=utils.hash_pass(password),
            otp_hash=otp_hash,
            expires_at=now + timedelta(minutes=OTP_TTL_MINUTES),
        )
        db.add(intent)
    else:
        # Update intent data and overwrite OTP/expiry on start (treat as resend).
        intent.name = name
        intent.phone = phone
        intent.password_hash = utils.hash_pass(password)
        intent.otp_hash = otp_hash
        intent.expires_at = now + timedelta(minutes=OTP_TTL_MINUTES)
        intent.verified_at = None

    html = f"""
    <div style="font-family:Arial,sans-serif">
      <h2>HomeEase Email Verification</h2>
      <p>Your OTP is:</p>
      <p style="font-size:28px;font-weight:700;letter-spacing:4px">{otp}</p>
      <p>This code expires in 10 minutes.</p>
    </div>
    """
    try:
        send_email(email, "Verify your HomeEase email", html)
    except Exception as e:
        # IMPORTANT:
        # We intentionally DO NOT commit the signup intent if email sending fails.
        # This prevents "signup data stored in DB even though verification not done"
        # when the OTP couldn't be delivered.
        db.rollback()
        # Return exact failure so we can fix Resend config/delivery issues.
        raise HTTPException(status_code=500, detail=f"Failed to send email: {e}")

    # Email successfully sent; now we persist the intent + OTP hash.
    db.commit()
    return {"message": "OTP sent", "sent": True}


@router.post("/auth/signup/verify", status_code=status.HTTP_201_CREATED)
def signup_verify(payload: dict, db: session = Depends(database.get_db)):
    """
    Verifies OTP for a signup intent and creates the real user row.
    """
    email = (payload.get("email") or "").lower().strip()
    otp = (payload.get("otp") or "").strip()
    if not email or not otp:
        raise HTTPException(status_code=400, detail="Email and OTP are required")

    now = datetime.now(timezone.utc)
    intent = (
        db.query(models.SignupIntents)
        .filter(
            models.SignupIntents.email == email,
            models.SignupIntents.verified_at.is_(None),
            models.SignupIntents.expires_at > now,
        )
        .first()
    )
    if not intent or intent.otp_hash != hash_otp(otp):
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")

    # Create user only after OTP passes.
    user = models.Users(
        name=intent.name,
        email=intent.email,
        phone=intent.phone,
        password=intent.password_hash,
        email_verified=True,
    )
    db.add(user)
    intent.verified_at = now
    db.commit()
    db.refresh(user)
    return {"message": "Signup verified. Account created."}


@router.post("/auth/signup/resend", status_code=status.HTTP_200_OK)
def signup_resend(payload: dict, db: session = Depends(database.get_db)):
    """
    Resends OTP for an existing (unverified) signup intent.
    This is used by the Verify Email screen's resend button.
    """
    email = (payload.get("email") or "").lower().strip()
    if not email:
        raise HTTPException(status_code=400, detail="Email is required")

    now = datetime.now(timezone.utc)
    intent = (
        db.query(models.SignupIntents)
        .filter(models.SignupIntents.email == email, models.SignupIntents.verified_at.is_(None))
        .first()
    )
    if not intent:
        return {"message": "Signup not started for this email", "sent": False}

    otp = generate_email_otp()
    intent.otp_hash = hash_otp(otp)
    intent.expires_at = now + timedelta(minutes=OTP_TTL_MINUTES)

    html = f"""
    <div style="font-family:Arial,sans-serif">
      <h2>HomeEase Email Verification</h2>
      <p>Your OTP is:</p>
      <p style="font-size:28px;font-weight:700;letter-spacing:4px">{otp}</p>
      <p>This code expires in 10 minutes.</p>
    </div>
    """
    try:
        send_email(email, "Verify your HomeEase email", html)
    except Exception as e:
        # Same rule as signup_start: don't persist changes if we couldn't deliver the OTP.
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to send email: {e}")

    db.commit()
    return {"message": "OTP resent", "sent": True}


@router.post("/auth/email/otp/send")
def send_signup_email_otp(payload: dict, db: session = Depends(database.get_db)):
    """
    Sends an OTP to the given email.
    Used for signup verification and resend flows.
    """
    email = (payload.get("email") or "").lower().strip()
    if not email:
        raise HTTPException(status_code=400, detail="Email is required")

    # Legacy resend endpoint for already-created users. Keep for "resend OTP" after signup
    # in case the UI calls it, but prefer /auth/signup/start for new signups.
    user = db.query(models.Users).filter(models.Users.email == email).first()
    if not user:
        return {"message": "If the account exists, an OTP has been sent.", "sent": False}

    if user.email_verified:
        return {"message": "Email already verified", "sent": False}

    otp = generate_email_otp()
    otp_hash = hash_otp(otp)
    now = datetime.now(timezone.utc)
    row = models.EmailOtps(
        email=email,
        purpose="SIGNUP_VERIFY",
        otp_hash=otp_hash,
        expires_at=now + timedelta(minutes=OTP_TTL_MINUTES),
    )
    db.add(row)
    db.commit()
    html = f"""
    <div style="font-family:Arial,sans-serif">
      <h2>HomeEase Email Verification</h2>
      <p>Your OTP is:</p>
      <p style="font-size:28px;font-weight:700;letter-spacing:4px">{otp}</p>
      <p>This code expires in 10 minutes.</p>
    </div>
    """
    try:
        send_email(email, "Verify your HomeEase email", html)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {e}")

    return {"message": "OTP sent", "sent": True}


@router.post("/auth/email/otp/verify")
def verify_email_otp(payload: dict, db: session = Depends(database.get_db)):
    """
    Verifies a signup OTP and marks users.email_verified = true.
    """
    email = (payload.get("email") or "").lower().strip()
    otp = (payload.get("otp") or "").strip()
    if not email or not otp:
        raise HTTPException(status_code=400, detail="Email and OTP are required")

    # Legacy verify endpoint for already-created users.
    from ..email_tokens import verify_signup_email_otp
    verify_signup_email_otp(db, email, otp)
    return {"message": "Email verified"}


@router.post("/auth/password/forgot")
def forgot_password(
    payload: dict,
    request: Request,
    db: session = Depends(database.get_db),
):
    """
    Generates a secure reset token and emails a reset link.
    Always returns success to avoid leaking whether an email exists.
    """
    email = (payload.get("email") or "").lower().strip()
    if not email:
        raise HTTPException(status_code=400, detail="Email is required")

    user = db.query(models.Users).filter(models.Users.email == email).first()
    if not user:
        return {"message": "If the account exists, a reset link has been sent."}

    # We create a reset token row first, but if email sending fails,
    # we should not leave a valid token in DB. So we clean it up on failure below.
    token = create_password_reset_token(db, user.id)
    base = str(request.base_url).rstrip("/")
    link = f"{base}/auth/password/reset-page?token={token}"

    html = f"""
    <div style="font-family:Arial,sans-serif">
      <h2>Reset your HomeEase password</h2>
      <p>Click the link below to set a new password (expires in 30 minutes):</p>
      <p><a href="{link}">Reset Password</a></p>
      <p>If you didn't request this, you can ignore this email.</p>
    </div>
    """
    try:
        send_email(email, "Reset your HomeEase password", html)
    except Exception as e:
        # Clean up the token if we couldn't email it (avoid lingering valid tokens).
        try:
            token_hash = hash_otp(token)  # same peppered SHA256 helper as OTPs
            (
                db.query(models.PasswordResetTokens)
                .filter(models.PasswordResetTokens.token_hash == token_hash)
                .delete(synchronize_session=False)
            )
            db.commit()
        except Exception:
            # If cleanup fails, we still raise the original email error.
            db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to send email: {e}")

    return {"message": "If the account exists, a reset link has been sent."}


@router.get("/auth/password/reset-page", response_class=HTMLResponse)
def reset_page(token: str):
    """
    Minimal HTML page to complete password reset in a browser.
    This keeps the reset-link flow functional even without deep links.
    """
    safe_token = token.replace('"', "").replace("<", "").replace(">", "")
    html = f"""
    <html>
      <head><meta name="viewport" content="width=device-width, initial-scale=1"/></head>
      <body style="font-family:Arial,sans-serif;max-width:420px;margin:40px auto;padding:12px">
        <h2>Reset Password</h2>
        <form method="post" action="/auth/password/reset/confirm-form">
          <input type="hidden" name="token" value="{safe_token}"/>
          <label>New password</label><br/>
          <input name="password" type="password" style="width:100%;padding:10px;margin:8px 0" /><br/>
          <button type="submit" style="width:100%;padding:12px">Set Password</button>
        </form>
      </body>
    </html>
    """
    return html


@router.post("/auth/password/reset/confirm")
def reset_password_confirm(payload: dict, db: session = Depends(database.get_db)):
    """
    Consumes a reset token and updates the user's password.
    """
    token = (payload.get("token") or "").strip()
    password = (payload.get("password") or "").strip()
    if not token or not password:
        raise HTTPException(status_code=400, detail="Token and password are required")

    user_id = consume_password_reset_token(db, token)
    user = db.query(models.Users).filter(models.Users.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password = utils.hash_pass(password)
    db.commit()
    return {"message": "Password updated"}


@router.post("/auth/password/reset/confirm-form")
def reset_password_confirm_form(
    token: str = Form(...),
    password: str = Form(...),
    db: session = Depends(database.get_db),
):
    """
    Same as /auth/password/reset/confirm but accepts HTML form post.
    Used by the reset link page for users who open the email in a browser.
    """
    user_id = consume_password_reset_token(db, token)
    user = db.query(models.Users).filter(models.Users.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password = utils.hash_pass(password)
    db.commit()
    return {"message": "Password updated"}
