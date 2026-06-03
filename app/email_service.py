import smtplib
from email.message import EmailMessage

from .config import settings


def send_email(to_email: str, subject: str, html: str) -> None:
    """
    Sends an email using SMTP.
    """
    sender_email = (settings.smtp_email or "").strip()
    sender_name = (settings.from_name or "").strip() or "HomeEase"
    message = EmailMessage()
    message["From"] = f"{sender_name} <{sender_email}>"
    message["To"] = to_email
    message["Subject"] = subject
    message.set_content("This email requires an HTML-capable client.")
    message.add_alternative(html, subtype="html")

    smtp_server = settings.smtp_server.strip()
    smtp_port = int(settings.smtp_port)
    try:
        if smtp_port == 465:
            with smtplib.SMTP_SSL(smtp_server, smtp_port, timeout=15) as server:
                server.login(settings.smtp_email, settings.smtp_password)
                server.send_message(message)
        else:
            with smtplib.SMTP(smtp_server, smtp_port, timeout=15) as server:
                server.ehlo()
                server.starttls()
                server.ehlo()
                server.login(settings.smtp_email, settings.smtp_password)
                server.send_message(message)
        print(f"[email_service] Sent email to {to_email} via SMTP")
    except smtplib.SMTPAuthenticationError as e:
        raise RuntimeError(f"SMTP authentication failed: {e.smtp_error.decode('utf-8', errors='replace') if isinstance(e.smtp_error, bytes) else e.smtp_error}") from e
    except smtplib.SMTPException as e:
        raise RuntimeError(f"SMTP error: {e}") from e
    except OSError as e:
        raise RuntimeError(f"SMTP connection error: {e}") from e
