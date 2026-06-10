def signup_otp_email(otp: str) -> str:
    return f"""
    <div style="font-family:Arial,sans-serif">
      <h2>HomeEase Email Verification</h2>
      <p>Your OTP is:</p>
      <p style="font-size:28px;font-weight:700;letter-spacing:4px">{otp}</p>
      <p>This code expires in 10 minutes.</p>
    </div>
    """


def password_reset_email(link: str) -> str:
    return f"""
    <div style="font-family:Arial,sans-serif">
      <h2>Reset your HomeEase password</h2>
      <p>Click the link below to set a new password (expires in 30 minutes):</p>
      <p><a href="{link}">Reset Password</a></p>
      <p>If you didn't request this, you can ignore this email.</p>
    </div>
    """


def password_reset_page(token: str) -> str:
    safe_token = token.replace('"', "").replace("<", "").replace(">", "")
    return f"""
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
