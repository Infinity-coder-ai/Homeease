import os

API = os.path.join(os.path.dirname(__file__), '..', 'lib', 'services', 'api')

HEADER = """import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

"""


def split_file(src, out1, out2, class1, class2, title1, title2, split_line):
    path = os.path.join(API, src)
    lines = open(path, encoding='utf-8').readlines()
    idx = split_line - 1
    part1 = ''.join(lines[7:idx])
    part2 = ''.join(lines[idx:]).rstrip()
    if part2.endswith('}'):
        part2 = part2[:-1].rstrip()
    open(os.path.join(API, out1), 'w', encoding='utf-8').write(
        f'{HEADER}/// {title1}\nclass {class1} {{\n{part1}\n}}\n'
    )
    open(os.path.join(API, out2), 'w', encoding='utf-8').write(
        f'{HEADER}/// {title2}\nclass {class2} {{\n{part2}\n}}\n'
    )
    os.remove(path)
    for name in (out1, out2):
        n = sum(1 for _ in open(os.path.join(API, name), encoding='utf-8'))
        print(f'{name}: {n} lines')


split_file(
    'admin_api.dart',
    'admin_requests_api.dart',
    'admin_providers_api.dart',
    'AdminRequestsApi',
    'AdminProvidersApi',
    'Admin — provider applications & documents',
    'Admin — approved provider directory',
    236,
)

# provider_ops: read file, split at booking section
path = os.path.join(API, 'provider_ops_api.dart')
lines = open(path, encoding='utf-8').readlines()
split_line = next(i for i, l in enumerate(lines) if 'PROVIDER BOOKINGS' in l) - 2
part1 = ''.join(lines[7:split_line])
part2 = ''.join(lines[split_line:]).rstrip()
if part2.endswith('}'):
    part2 = part2[:-1].rstrip()
open(os.path.join(API, 'provider_ops_api.dart'), 'w', encoding='utf-8').write(
    f'{HEADER}/// Provider profile, services, availability, documents.\nclass ProviderOpsApi {{\n{part1}\n}}\n'
)
open(os.path.join(API, 'provider_booking_api.dart'), 'w', encoding='utf-8').write(
    f'{HEADER}/// Provider-side booking list and status updates.\nclass ProviderBookingApi {{\n{part2}\n}}\n'
)
for name in ('provider_ops_api.dart', 'provider_booking_api.dart'):
    n = sum(1 for _ in open(os.path.join(API, name), encoding='utf-8'))
    print(f'{name}: {n} lines')
