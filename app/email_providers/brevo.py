import json
import smtplib
from email.message import EmailMessage
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from ..config import settings


BREVO_SEND_EMAIL_URL = "https://api.brevo.com/v3/smtp/email"


def _sender_email() -> str:
    sender_email = (settings.brevo_sender_email or "").strip()
    if not sender_email:
        raise RuntimeError("BREVO_SENDER_EMAIL is not configured")
    return sender_email


def _send_brevo_api_email(to_email: str, subject: str, html: str) -> None:
    payload = json.dumps(
        {
            "sender": {
                "name": settings.brevo_sender_name or settings.from_name,
                "email": _sender_email(),
            },
            "to": [{"email": to_email}],
            "subject": subject,
            "htmlContent": html,
        }
    ).encode("utf-8")

    request = Request(
        BREVO_SEND_EMAIL_URL,
        data=payload,
        headers={
            "api-key": settings.brevo_api_key,
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urlopen(request, timeout=20) as response:
            if response.status >= 400:
                body = response.read().decode("utf-8", errors="replace")
                raise RuntimeError(f"Brevo error {response.status}: {body}")
        print(f"[email_service] Sent email to {to_email} via Brevo")
    except HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Brevo error {e.code}: {body}") from e
    except URLError as e:
        raise RuntimeError(f"Brevo connection error: {e.reason}") from e


def _send_brevo_smtp_email(to_email: str, subject: str, html: str) -> None:
    if not settings.brevo_smtp_login or not settings.brevo_smtp_key:
        raise RuntimeError("Brevo email is not configured. Set BREVO_API_KEY or Brevo SMTP credentials.")

    sender_name = settings.brevo_sender_name or settings.from_name
    message = EmailMessage()
    message["From"] = f"{sender_name} <{_sender_email()}>"
    message["To"] = to_email
    message["Subject"] = subject
    message.set_content("This email requires an HTML-capable client.")
    message.add_alternative(html, subtype="html")

    try:
        with smtplib.SMTP(settings.brevo_smtp_server, settings.brevo_smtp_port, timeout=20) as server:
            server.ehlo()
            server.starttls()
            server.ehlo()
            server.login(settings.brevo_smtp_login, settings.brevo_smtp_key)
            server.send_message(message)
        print(f"[email_service] Sent email to {to_email} via Brevo SMTP")
    except smtplib.SMTPAuthenticationError as e:
        detail = e.smtp_error.decode("utf-8", errors="replace") if isinstance(e.smtp_error, bytes) else e.smtp_error
        raise RuntimeError(f"Brevo SMTP authentication failed: {detail}") from e
    except smtplib.SMTPException as e:
        raise RuntimeError(f"Brevo SMTP error: {e}") from e
    except OSError as e:
        raise RuntimeError(f"Brevo SMTP connection error: {e}") from e


def send_brevo_email(to_email: str, subject: str, html: str) -> None:
    if (settings.brevo_api_key or "").strip():
        _send_brevo_api_email(to_email, subject, html)
        return
    _send_brevo_smtp_email(to_email, subject, html)
