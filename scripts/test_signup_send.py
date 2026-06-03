import json
import time
import urllib.request
import urllib.error

email = f'diag-smtp-{int(time.time())}@example.com'
payload = {
    'name': 'Diag',
    'email': email,
    'password': 'Pass1234',
    'phone': '000'
}
data = json.dumps(payload).encode('utf-8')
req = urllib.request.Request(
    'http://127.0.0.1:8000/auth/signup/start',
    data=data,
    headers={'Content-Type': 'application/json'}
)
try:
    with urllib.request.urlopen(req, timeout=20) as resp:
        print('STATUS', resp.status)
        print(resp.read().decode())
except urllib.error.HTTPError as e:
    print('HTTP ERROR', e.code)
    print(e.read().decode())
except Exception as e:
    print('ERROR', e)
