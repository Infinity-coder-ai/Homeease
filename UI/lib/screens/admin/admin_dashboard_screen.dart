// Admin home: provider approval workflow + support requests (bottom tabs).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/rating_refresh_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import 'dialogs/admin_profile_sheet.dart';
import 'dialogs/admin_provider_details_dialog.dart';
import 'support_requests_screen.dart';
import 'tabs/admin_provider_requests_tab.dart';
import 'widgets/admin_nav_item.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _requests = [];
  List<dynamic> _approved = [];
  List<dynamic> _rejected = [];
  int _providerTabIndex = 0;
  int _adminTabIndex = 0;
  final _cityFilterCtrl = TextEditingController();
  final _ratingFilterCtrl = TextEditingController();
  ProviderSubscription<int>? _ratingSub;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _ratingSub = ref.listenManual<int>(ratingRefreshProvider, (_, __) {
      _loadAll();
    });
  }

  @override
  void dispose() {
    _ratingSub?.close();
    _cityFilterCtrl.dispose();
    _ratingFilterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final token = ref.read(userProvider).token ?? '';
    final city = _cityFilterCtrl.text.trim();
    final ratingText = _ratingFilterCtrl.text.trim();
    final minRating = ratingText.isEmpty ? null : double.tryParse(ratingText);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final pendingResult = await ApiService.getProviderRequests(token: token);
    final approvedResult = await ApiService.getProviders(
      token: token,
      status: 'APPROVED',
      city: city.isEmpty ? null : city,
      minRating: minRating,
    );
    final rejectedResult = await ApiService.getProviders(
      token: token,
      status: 'REJECTED',
      city: city.isEmpty ? null : city,
      minRating: minRating,
    );

    if (!mounted) return;
    if (pendingResult['success'] == true &&
        approvedResult['success'] == true &&
        rejectedResult['success'] == true) {
      setState(() {
        _requests = pendingResult['data'] as List<dynamic>;
        _approved = approvedResult['data'] as List<dynamic>;
        _rejected = rejectedResult['data'] as List<dynamic>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = pendingResult['message']?.toString() ??
            approvedResult['message']?.toString() ??
            rejectedResult['message']?.toString() ??
            'Unable to load admin data.';
        _isLoading = false;
      });
    }
  }

  Future<void> _reject(int providerId, int index) async {
    final token = ref.read(userProvider).token ?? '';
    final result = await ApiService.rejectProviderRequest(
      token: token,
      providerId: providerId,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _requests.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider rejected.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Unable to reject.'),
        ),
      );
    }
  }

  Future<void> _approveBackground(int providerId, int index) async {
    final token = ref.read(userProvider).token ?? '';
    final r = await ApiService.approveProviderRequest(
      token: token,
      providerId: providerId,
    );
    if (!mounted) return;
    if (r['success'] == true) {
      setState(() => _requests.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Background verification approved — provider moves to Approved tab.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            r['message']?.toString() ??
                'Cannot approve yet — ensure all documents are verified.',
          ),
        ),
      );
    }
  }

  Future<void> _deactivate(int providerId, int index) async {
    final token = ref.read(userProvider).token ?? '';
    final result = await ApiService.deactivateProvider(
      token: token,
      providerId: providerId,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _approved.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider deactivated.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message']?.toString() ?? 'Unable to deactivate.'),
        ),
      );
    }
  }

  Future<void> _assignRole(int providerId, int index) async {
    final token = ref.read(userProvider).token ?? '';
    final result = await ApiService.assignProviderRole(
      token: token,
      providerId: providerId,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      await _loadAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Provider role assigned — dashboard unlocked.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message']?.toString() ?? 'Unable to assign role.'),
        ),
      );
    }
  }

  Future<void> _showDetails(int providerId) async {
    final token = ref.read(userProvider).token ?? '';
    await AdminProviderDetailsDialog.show(
      context: context,
      token: token,
      providerId: providerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: IndexedStack(
        index: _adminTabIndex,
        children: [
          AdminProviderRequestsTab(
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            requests: _requests,
            approved: _approved,
            rejected: _rejected,
            providerTabIndex: _providerTabIndex,
            cityFilterCtrl: _cityFilterCtrl,
            ratingFilterCtrl: _ratingFilterCtrl,
            onRefresh: _loadAll,
            onProviderTabChanged: (i) => setState(() => _providerTabIndex = i),
            onCityOrRatingChanged: _loadAll,
            onOpenProfile: () => AdminProfileSheet.show(context: context, ref: ref),
            onReject: _reject,
            onApproveBackground: _approveBackground,
            onAssignRole: _assignRole,
            onDeactivate: _deactivate,
            onViewDetails: _showDetails,
          ),
          const AdminSupportRequestsScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AdminNavItem(
                icon: Icons.verified_user_rounded,
                label: 'Provider Requests',
                isActive: _adminTabIndex == 0,
                onTap: () => setState(() => _adminTabIndex = 0),
              ),
              AdminNavItem(
                icon: Icons.support_agent_rounded,
                label: 'Support Requests',
                isActive: _adminTabIndex == 1,
                onTap: () => setState(() => _adminTabIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
