import smtplib
from email.message import EmailMessage
from pathlib import Path

# Minimal .env reader
values = {}
for line in Path('.env').read_text(encoding='utf-8').splitlines():
    line = line.strip()
    if not line or line.startswith('#') or '=' not in line:
        continue
    key, value = line.split('=', 1)
    values[key.strip()] = value.strip().strip('"')

server = values['SMTP_SERVER']
port = int(values['SMTP_PORT'])
email = values['SMTP_EMAIL']
password = values['SMTP_PASSWORD']
from_name = values.get('FROM_NAME', 'HomeEase')

msg = EmailMessage()
msg['From'] = f'{from_name} <{email}>'
msg['To'] = email
msg['Subject'] = 'HomeEase SMTP test'
msg.set_content('SMTP test email from HomeEase backend.')
msg.add_alternative('<p>SMTP test email from <strong>HomeEase</strong> backend.</p>', subtype='html')

with smtplib.SMTP(server, port, timeout=15) as smtp:
    smtp.ehlo()
    smtp.starttls()
    smtp.ehlo()
    smtp.login(email, password)
    smtp.send_message(msg)

print('SMTP test sent to', email)
