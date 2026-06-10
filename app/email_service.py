from .email_providers.brevo import send_brevo_email


def send_email(to_email: str, subject: str, html: str) -> None:
    """Send transactional email through Brevo."""
    send_brevo_email(to_email, subject, html)
