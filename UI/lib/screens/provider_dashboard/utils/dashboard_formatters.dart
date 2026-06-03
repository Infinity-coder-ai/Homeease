/// Small formatting helpers for the provider dashboard.
String formatDashboardNumber(dynamic value, {required String fallback}) {
  if (value is num) return value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
  return value?.toString() ?? fallback;
}
