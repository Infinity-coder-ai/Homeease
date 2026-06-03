import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/provider_documents_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/full_screen_image_viewer.dart';

class ProviderDocumentsScreen extends ConsumerStatefulWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  ConsumerState<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState
    extends ConsumerState<ProviderDocumentsScreen> {
  final _picker = ImagePicker();

  Future<void> _upload(String type) async {
    final token = ref.read(userProvider).token ?? '';
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final result = await ApiProviderService.uploadProviderDocument(
      token: token,
      documentType: type,
      filePath: file.path,
    );
    if (!mounted) return;
    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Unable to upload document.'),
        ),
      );
    }
    ref.read(providerDocumentsProvider.notifier).fetchDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(providerDocumentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Documents', style: AppTextStyles.heading3),
      ),
      body: SafeArea(
        child: documentsState.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : documentsState.errorMessage != null
                ? Center(
                    child: Text(
                      documentsState.errorMessage!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                : Builder(
                    builder: (context) {
            final documents = documentsState.documents;
            final profileDoc = _findDoc(documents, 'PROFILE_PHOTO');
            final idDoc = _findDoc(documents, 'AADHAAR');

            return RefreshIndicator(
              onRefresh: () async => ref
                  .read(providerDocumentsProvider.notifier)
                  .fetchDocuments(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  const _HeroBanner(
                    title: 'Keep your documents updated',
                    subtitle: 'Documents are reviewed by admin before your profile appears to customers.',
                  ),
                  const SizedBox(height: 18),
                  const Text('Your Documents', style: AppTextStyles.heading3),
                  const SizedBox(height: 10),
                  _DocumentRow(
                    title: 'Profile Photo',
                    subtitle: 'Provider identity',
                    icon: Icons.person_rounded,
                    status: profileDoc?['verification_status']?.toString(),
                    previewUrl: profileDoc?['file_url']?.toString(),
                    onUpload: () => _upload('PROFILE_PHOTO'),
                  ),
                  const SizedBox(height: 10),
                  _DocumentRow(
                    title: 'Aadhaar Card',
                    subtitle: 'Government ID',
                    icon: Icons.credit_card_rounded,
                    status: idDoc?['verification_status']?.toString(),
                    previewUrl: idDoc?['file_url']?.toString(),
                    onUpload: () => _upload('AADHAAR'),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, dynamic>? _findDoc(List<dynamic> docs, String type) {
    Map<String, dynamic>? fallback;
    for (final doc in docs) {
      final map = doc as Map<String, dynamic>;
      if (map['document_type']?.toString() != type) continue;
      if (map['verification_status']?.toString() == 'APPROVED') return map;
      fallback = map;
    }
    return fallback;
  }
}

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6F4DE8), Color(0xFF4E35C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.folder_copy_rounded, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? status;
  final String? previewUrl;
  final VoidCallback onUpload;

  const _DocumentRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.previewUrl,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final uploaded = previewUrl != null && previewUrl!.isNotEmpty;
    final statusText = uploaded ? (status ?? 'PENDING') : 'Not Uploaded';
    final statusColor = statusText == 'APPROVED'
        ? AppColors.success
        : statusText == 'REJECTED'
            ? AppColors.error
            : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.heading3),
                    const SizedBox(height: 3),
                    Text(subtitle, style: AppTextStyles.hint),
                  ],
                ),
              ),
              TextButton(
                onPressed: onUpload,
                child: Text(
                  uploaded ? 'Re-upload' : 'Upload',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          // Preview thumbnail — tappable to full screen
          if (uploaded) ...[
            const SizedBox(height: 10),
            TappableDocumentImage(
              imageUrl: previewUrl!,
              title: title,
              height: 140,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: const Color(0xFFEDEEF5)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
    ],
  );
}
