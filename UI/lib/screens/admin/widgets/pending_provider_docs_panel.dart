// Expandable document review panel (step 1) on a pending provider card.
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import 'admin_doc_review_tile.dart';
import 'admin_shared_widgets.dart';

class PendingProviderDocsPanel extends StatefulWidget {
  final Map<String, dynamic> request;
  final String token;
  final bool docsVerifiedFromServer;
  final bool canApproveBackground;
  final ValueChanged<bool> onDocsStateChanged;

  const PendingProviderDocsPanel({
    super.key,
    required this.request,
    required this.token,
    required this.docsVerifiedFromServer,
    required this.canApproveBackground,
    required this.onDocsStateChanged,
  });

  @override
  State<PendingProviderDocsPanel> createState() =>
      _PendingProviderDocsPanelState();
}

class _PendingProviderDocsPanelState extends State<PendingProviderDocsPanel> {
  bool _docsExpanded = false;
  bool _docsLoading = false;
  List<dynamic> _docs = [];
  final Map<int, bool> _docBusy = {};

  Future<void> _loadDocs() async {
    final providerId = widget.request['id'] as int;
    setState(() => _docsLoading = true);
    final result = await ApiService.getProviderRequestDocuments(
      token: widget.token,
      providerId: providerId,
    );
    if (mounted) {
      setState(() {
        _docsLoading = false;
        _docs = result['success'] == true
            ? (result['data'] as List<dynamic>? ?? [])
            : [];
      });
      _notifyParent();
    }
  }

  void _notifyParent() {
    final allApproved = _docs.isNotEmpty &&
        _docs.every(
          (d) =>
              (d as Map<String, dynamic>)['verification_status'] == 'APPROVED',
        );
    widget.onDocsStateChanged(
      allApproved || widget.docsVerifiedFromServer,
    );
  }

  Future<void> _reviewDoc(int documentId, bool approve) async {
    final providerId = widget.request['id'] as int;
    setState(() => _docBusy[documentId] = true);

    final result = approve
        ? await ApiService.approveProviderDocument(
            token: widget.token,
            providerId: providerId,
            documentId: documentId,
          )
        : await ApiService.rejectProviderDocument(
            token: widget.token,
            providerId: providerId,
            documentId: documentId,
          );

    if (!mounted) return;

    if (result['success'] == true) {
      final updated = await ApiService.getProviderRequestDocuments(
        token: widget.token,
        providerId: providerId,
      );
      if (mounted) {
        setState(() {
          _docBusy[documentId] = false;
          if (updated['success'] == true) {
            _docs = updated['data'] as List<dynamic>? ?? [];
          }
        });
        _notifyParent();
      }
    } else {
      if (mounted) setState(() => _docBusy[documentId] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                (approve ? 'Failed to approve' : 'Failed to reject'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          icon: Icons.folder_copy_rounded,
          label: 'Step 1 — Document Verification',
          trailingWidget: widget.canApproveBackground
              ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18)
              : null,
        ),
        const SizedBox(height: 8),
        if (!_docsExpanded) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.docsVerifiedFromServer
                      ? 'All documents approved ✅'
                      : 'Tap to review documents',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.docsVerifiedFromServer
                        ? AppColors.success
                        : AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _docsExpanded = true);
                  _loadDocs();
                },
                icon: const Icon(Icons.expand_more_rounded, size: 18),
                label: const Text('Review'),
              ),
            ],
          ),
        ] else ...[
          if (_docsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_docs.isEmpty)
            const Text('No documents found.', style: AppTextStyles.bodyMedium)
          else
            ..._docs.map((docRaw) {
              final doc = docRaw as Map<String, dynamic>;
              final docId = doc['id'] as int?;
              final type = doc['document_type']?.toString() ?? 'Document';
              final status =
                  doc['verification_status']?.toString() ?? 'PENDING';
              final url = doc['file_url']?.toString() ?? '';
              final busy = docId != null && (_docBusy[docId] == true);

              return AdminDocReviewTile(
                type: type,
                status: status,
                imageUrl: url,
                isLoading: busy,
                onApprove: (status == 'APPROVED' || docId == null || busy)
                    ? null
                    : () => _reviewDoc(docId, true),
                onReject: (status == 'REJECTED' || docId == null || busy)
                    ? null
                    : () => _reviewDoc(docId, false),
              );
            }),
          if (!_docsLoading)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _docsExpanded = false),
                icon: const Icon(Icons.expand_less_rounded, size: 18),
                label: const Text('Collapse'),
              ),
            ),
        ],
      ],
    );
  }
}
