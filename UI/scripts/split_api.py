import re
import os

ROOT = os.path.join(os.path.dirname(__file__), '..', 'lib', 'services')
API_DIR = os.path.join(ROOT, 'api')
os.makedirs(API_DIR, exist_ok=True)

METHOD_DOMAIN = {
    'signup': 'auth',
    'login': 'auth',
    'sendEmailOtp': 'auth',
    'resendSignupOtp': 'auth',
    'verifyEmailOtp': 'auth',
    'forgotPassword': 'auth',
    'resetPassword': 'auth',
    'getMe': 'auth',
    'submitSupportReport': 'support',
    'getSupportReports': 'admin',
    'searchProviders': 'catalog',
    'getServiceCatalog': 'catalog',
    'createBooking': 'booking',
    'getMyBookings': 'booking',
    'submitRating': 'booking',
    'cancelBooking': 'booking',
    'createProviderProfile': 'provider_onboarding',
    'createProviderService': 'provider_onboarding',
    'createProviderAvailability': 'provider_onboarding',
    'uploadProviderDocument': 'provider_onboarding',
    'getProviderServices': 'provider_ops',
    'deleteProviderService': 'provider_ops',
    'getProviderAvailability': 'provider_ops',
    'deleteProviderAvailability': 'provider_ops',
    'getProviderDocuments': 'provider_ops',
    'getProviderApplicationStatus': 'provider_ops',
    'getProviderStats': 'provider_ops',
    'getProviderBookings': 'provider_ops',
    'acceptBooking': 'provider_ops',
    'completeBooking': 'provider_ops',
    'getNotifications': 'notifications',
    'getUnreadNotificationsCount': 'notifications',
    'markNotificationRead': 'notifications',
    'markAllNotificationsRead': 'notifications',
    'getProviderRequests': 'admin',
    'approveProviderRequest': 'admin',
    'rejectProviderRequest': 'admin',
    'approveProviderDocument': 'admin',
    'rejectProviderDocument': 'admin',
    'getProviderRequestDocuments': 'admin',
    'getProviders': 'admin',
    'getProviderDetails': 'admin',
    'getProviderRatings': 'admin',
    'deactivateProvider': 'admin',
    'assignProviderRole': 'admin',
}

CLASS_NAMES = {
    'auth': 'AuthApi',
    'support': 'SupportApi',
    'catalog': 'CatalogApi',
    'booking': 'BookingApi',
    'provider_onboarding': 'ProviderOnboardingApi',
    'provider_ops': 'ProviderOpsApi',
    'notifications': 'NotificationApi',
    'admin': 'AdminApi',
}

CONN_CATCH = """    } on Exception catch (_) {
      return {
        'success': false,
        'message': 'Unable to reach the server. Check your connection and IP.',
      };
    }"""

CONN_CATCH_FIXED = """    } on Exception catch (_) {
      return ApiHttpHelpers.connectionError;
    }"""

with open(os.path.join(ROOT, 'api_service.dart'), encoding='utf-8') as f:
    content = f.read()

config = '''/// Base URL for the FastAPI backend.
/// Update [baseUrl] with your PC IP (`ipconfig`) for physical devices.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://10.148.53.172:8000';
  // Emulator: http://10.0.2.2:8000
}
'''
open(os.path.join(API_DIR, 'api_config.dart'), 'w', encoding='utf-8').write(config)

helpers = '''import 'dart:convert';
import 'package:http/http.dart' as http;

/// Shared response parsing for all API modules.
class ApiHttpHelpers {
  ApiHttpHelpers._();

  static const Map<String, dynamic> connectionError = {
    'success': false,
    'message': 'Unable to reach the server. Check your connection and IP.',
  };

  static Map<String, dynamic> failureFromResponse(
    http.Response response,
    String fallback,
  ) {
    final data = jsonDecode(response.body);
    final detail = data is Map ? (data['detail'] ?? fallback) : fallback;
    return {'success': false, 'message': detail};
  }
}
'''
open(os.path.join(API_DIR, 'api_http_helpers.dart'), 'w', encoding='utf-8').write(helpers)

m = re.search(r'class ApiService \{', content)
m2 = re.search(r'\nclass ApiAuthService', content)
api_body = content[m.end():m2.start() - 1]
api_body = re.sub(
    r'  // INTEGRATION STEP 1:.*?static const String baseUrl = [^\n]+\n[^\n]*\n',
    '',
    api_body,
    flags=re.S,
)

# Split on static Future method starts
pattern = re.compile(
    r'\n  // -{10,}(?:\n  // [^\n]+)*\n  static Future<Map<String, dynamic>> (\w+)\(',
)
parts = pattern.split(api_body)
# parts[0] empty, then alternating: method_name, body, method_name, body...
grouped = {k: [] for k in CLASS_NAMES}
i = 1
while i < len(parts) - 1:
    name = parts[i]
    body = parts[i + 1]
    domain = METHOD_DOMAIN.get(name, 'auth')
    if domain not in grouped:
        grouped[domain] = []
    header = parts[i - 1] if i > 0 else ''
    # recover comment block from previous split - use simpler approach
    i += 2

# Simpler: find all methods with regex
method_re = re.compile(
    r'(  // -{10,}(?:\n  // [^\n]+)*\n  static Future<Map<String, dynamic>> \w+\([^)]*\)[^{]*\{)',
    re.M,
)
# Actually split by method name
method_starts = list(
    re.finditer(
        r'\n  // -{10,}.*?\n  static Future<Map<String, dynamic>> (\w+)\(',
        api_body,
        re.S,
    )
)
grouped = {k: [] for k in CLASS_NAMES}
for idx, match in enumerate(method_starts):
    name = match.group(1)
    start = match.start()
    end = method_starts[idx + 1].start() if idx + 1 < len(method_starts) else len(api_body)
    block = api_body[start:end]
    domain = METHOD_DOMAIN.get(name, 'auth')
    grouped[domain].append(block)

for domain, blocks in grouped.items():
    if not blocks:
        continue
    body = ''.join(blocks)
    body = body.replace("'$baseUrl", "'${ApiConfig.baseUrl}")
    body = body.replace("'$ApiConfig.baseUrl", "'${ApiConfig.baseUrl}")
    body = body.replace(CONN_CATCH, CONN_CATCH_FIXED)
    fname = os.path.join(API_DIR, f'{domain}_api.dart')
    title = domain.replace('_', ' ').title()
    header = f"""import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_http_helpers.dart';

/// {title} API endpoints.
class {CLASS_NAMES[domain]} {{
"""
    with open(fname, 'w', encoding='utf-8') as out:
        out.write(header + body.strip() + '\n}\n')
    print(f'{fname}: {sum(1 for _ in open(fname))} lines')
