// Full provider details dialog (services, availability, documents, ratings).
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/full_screen_image_viewer.dart';

class AdminProviderDetailsDialog {
  AdminProviderDetailsDialog._();

  static Future<void> show({
    required BuildContext context,
    required String token,
    required int providerId,
  }) async {
    final result = await ApiService.getProviderDetails(
      token: token,
      providerId: providerId,
    );
    final ratingsResult = await ApiService.getProviderRatings(
      token: token,
      providerId: providerId,
    );
    if (!context.mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Unable to load details.',
          ),
        ),
      );
      return;
    }

    final data = result['data'] as Map<String, dynamic>;
    final prov = data['provider'] as Map<String, dynamic>? ?? {};
    final services = data['services'] as List<dynamic>? ?? [];
    final availability = data['availability'] as List<dynamic>? ?? [];
    final documents = data['documents'] as List<dynamic>? ?? [];
    final ratings = ratingsResult['success'] == true
        ? ratingsResult['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Provider Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _detailRow(
                'Location',
                '${prov['city'] ?? '-'}, ${prov['area'] ?? '-'} (${prov['pincode'] ?? '-'})',
              ),
              _detailRow(
                'Experience',
                '${prov['experience_years'] ?? '-'} years',
              ),
              _detailRow(
                'Avg Rating',
                ratings['average_rating']?.toString() ?? 'N/A',
              ),
              _detailRow(
                'Reviews',
                ratings['total_reviews']?.toString() ?? '0',
              ),
              const SizedBox(height: 12),
              const Text('Services', style: AppTextStyles.heading3),
              if (services.isEmpty)
                const Text('No services listed.',
                    style: AppTextStyles.bodyMedium),
              ...services.map((s) {
                final m = s as Map<String, dynamic>;
                return Text(
                  '• ${m['service_name'] ?? '-'} — Rs ${m['price'] ?? '-'}',
                  style: AppTextStyles.bodyMedium,
                );
              }),
              const SizedBox(height: 12),
              const Text('Availability', style: AppTextStyles.heading3),
              if (availability.isEmpty)
                const Text('No availability set.',
                    style: AppTextStyles.bodyMedium),
              ...availability.map((sl) {
                final m = sl as Map<String, dynamic>;
                return Text(
                  '• Day ${m['day_of_week'] ?? '-'}: ${m['start_time'] ?? '-'} – ${m['end_time'] ?? '-'}',
                  style: AppTextStyles.bodyMedium,
                );
              }),
              if (documents.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Documents', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                ...documents.map((docRaw) {
                  final doc = docRaw as Map<String, dynamic>;
                  final type = doc['document_type']?.toString() ?? 'Document';
                  final status =
                      doc['verification_status']?.toString() ?? 'PENDING';
                  final url = doc['file_url']?.toString() ?? '';
                  final statusColor = status == 'APPROVED'
                      ? AppColors.success
                      : status == 'REJECTED'
                          ? AppColors.error
                          : AppColors.warning;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                type.replaceAll('_', ' '),
                                style: AppTextStyles.heading3,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (url.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TappableDocumentImage(
                            imageUrl: url,
                            title: type.replaceAll('_', ' '),
                            height: 160,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
          ],
        ),
      );
}
