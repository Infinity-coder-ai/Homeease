// Admin profile bottom sheet with logout.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import '../../login/login_screen.dart';

class AdminProfileSheet {
  AdminProfileSheet._();

  static Future<void> show({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final admin = ref.read(userProvider);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Admin Profile', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              admin.name.isNotEmpty ? admin.name : 'Administrator',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              admin.email.isNotEmpty ? admin.email : '-',
              style: AppTextStyles.hint,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(userProvider.notifier).logout();
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
