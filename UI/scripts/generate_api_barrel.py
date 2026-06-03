import os
import re

ROOT = os.path.join(os.path.dirname(__file__), '..', 'lib', 'services')
API_DIR = os.path.join(ROOT, 'api')

METHOD_CLASS = {
    'signup': 'AuthApi', 'login': 'AuthApi', 'sendEmailOtp': 'AuthApi',
    'resendSignupOtp': 'AuthApi', 'verifyEmailOtp': 'AuthApi',
    'forgotPassword': 'AuthApi', 'resetPassword': 'AuthApi', 'getMe': 'AuthApi',
    'submitSupportReport': 'SupportApi',
    'searchProviders': 'CatalogApi', 'getServiceCatalog': 'CatalogApi',
    'createBooking': 'BookingApi', 'getMyBookings': 'BookingApi',
    'submitRating': 'BookingApi', 'cancelBooking': 'BookingApi',
    'createProviderProfile': 'ProviderOnboardingApi',
    'createProviderService': 'ProviderOnboardingApi',
    'createProviderAvailability': 'ProviderOnboardingApi',
    'uploadProviderDocument': 'ProviderOnboardingApi',
    'getProviderServices': 'ProviderOpsApi', 'deleteProviderService': 'ProviderOpsApi',
    'getProviderAvailability': 'ProviderOpsApi',
    'deleteProviderAvailability': 'ProviderOpsApi',
    'getProviderDocuments': 'ProviderOpsApi',
    'getProviderApplicationStatus': 'ProviderOpsApi', 'getProviderStats': 'ProviderOpsApi',
    'getProviderBookings': 'ProviderBookingApi', 'acceptBooking': 'ProviderBookingApi',
    'completeBooking': 'ProviderBookingApi',
    'getNotifications': 'NotificationApi', 'getUnreadNotificationsCount': 'NotificationApi',
    'markNotificationRead': 'NotificationApi', 'markAllNotificationsRead': 'NotificationApi',
    'getProviderRequests': 'AdminRequestsApi', 'getSupportReports': 'AdminRequestsApi',
    'approveProviderRequest': 'AdminRequestsApi', 'rejectProviderRequest': 'AdminRequestsApi',
    'approveProviderDocument': 'AdminRequestsApi', 'rejectProviderDocument': 'AdminRequestsApi',
    'getProviderRequestDocuments': 'AdminRequestsApi',
    'getProviders': 'AdminProvidersApi', 'getProviderDetails': 'AdminProvidersApi',
    'getProviderRatings': 'AdminProvidersApi', 'deactivateProvider': 'AdminProvidersApi',
    'assignProviderRole': 'AdminProvidersApi',
}


def parse_params(params_block: str) -> list[str]:
    inner = params_block.strip()
    if inner.startswith('{') and inner.endswith('}'):
        inner = inner[1:-1]
    names = []
    for line in inner.split('\n'):
        line = line.strip().rstrip(',')
        if not line or line.startswith('//'):
            continue
        if '=' in line:
            names.append(line.split('=')[0].strip().split()[-1])
        else:
            names.append(line.split()[-1])
    return names


def make_delegate(name: str, params_block: str, cls: str) -> str:
    names = parse_params(params_block)
    call_args = ', '.join(f'{n}: {n}' for n in names)
    return (
        f'  static Future<Map<String, dynamic>> {name}({params_block}) async =>\n'
        f'      {cls}.{name}({call_args});'
    )


delegates = []
for fname in sorted(os.listdir(API_DIR)):
    if not fname.endswith('_api.dart') or fname.startswith('api_'):
        continue
    text = open(os.path.join(API_DIR, fname), encoding='utf-8').read()
    for m in re.finditer(
        r'static Future<Map<String, dynamic>> (\w+)\((\{[\s\S]*?\})\)\s*async',
        text,
    ):
        name = m.group(1)
        params = m.group(2)
        cls = METHOD_CLASS[name]
        delegates.append(make_delegate(name, params, cls))

AUTH = [m for m, c in METHOD_CLASS.items() if c == 'AuthApi']
CATALOG = ['getServiceCatalog', 'searchProviders']
BOOKING = ['createBooking', 'getMyBookings', 'submitRating', 'cancelBooking']
PROVIDER = [
    'createProviderProfile', 'createProviderService', 'createProviderAvailability',
    'uploadProviderDocument', 'getProviderDocuments', 'getProviderApplicationStatus',
    'getProviderServices', 'deleteProviderService', 'getProviderAvailability',
    'deleteProviderAvailability', 'getProviderStats', 'getProviderBookings',
    'acceptBooking', 'cancelBooking', 'completeBooking',
]


def facade(name: str, methods: list[str]) -> str:
    lines = [f'class {name} {{', f'  {name}._();', '']
    for d in delegates:
        for mn in methods:
            if f' {mn}(' in d:
                lines.append(d.replace(' async =>', ' =>'))
                break
    lines.append('}')
    return '\n'.join(lines)

content = '''/// Central API exports and legacy [ApiService] facade.
///
/// HTTP implementations live under [api/] (one file per domain).
library;

import 'api/api_config.dart';
import 'api/auth_api.dart';
import 'api/support_api.dart';
import 'api/catalog_api.dart';
import 'api/booking_api.dart';
import 'api/provider_onboarding_api.dart';
import 'api/provider_ops_api.dart';
import 'api/provider_booking_api.dart';
import 'api/notifications_api.dart';
import 'api/admin_requests_api.dart';
import 'api/admin_providers_api.dart';

/// Legacy static entry point — delegates to domain API classes.
class ApiService {
  ApiService._();

  static const String baseUrl = ApiConfig.baseUrl;

''' + '\n\n'.join(delegates) + '''

}

''' + facade('ApiAuthService', AUTH) + '\n\n' + facade('ApiCatalogService', CATALOG) + '\n\n' + facade('ApiBookingService', BOOKING) + '\n\n' + facade('ApiProviderService', PROVIDER)

open(os.path.join(ROOT, 'api_service.dart'), 'w', encoding='utf-8').write(content)
print('delegates', len(delegates), 'lines', sum(1 for _ in open(os.path.join(ROOT, 'api_service.dart'))))
