import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import 'providers/notification_provider.dart';
import 'providers/user_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    // ProviderScope MUST wrap the entire app.
    // It is the container that stores all provider states.
    // Without this, ref.watch / ref.read will not work anywhere.
    const ProviderScope(
      child: HomeEaseApp(),
    ),
  );
}

class HomeEaseApp extends ConsumerStatefulWidget {
  const HomeEaseApp({super.key});

  @override
  ConsumerState<HomeEaseApp> createState() => _HomeEaseAppState();
}

class _HomeEaseAppState extends ConsumerState<HomeEaseApp> with WidgetsBindingObserver {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh on resume so a user who returns after a while stays signed in.
      ref.read(userProvider.notifier).ensureValidAccessToken();
    }
  }

  Future<void> _init() async {
    await ref.read(userProvider.notifier).loadFromPrefs();
    await ref.read(userProvider.notifier).ensureValidAccessToken();
    await ref.read(userProvider.notifier).fetchMe();
    // Load inbox state after the session is ready so badges and inbox use backend data.
    await ref.read(notificationProvider.notifier).fetchNotifications();
    await ref.read(notificationProvider.notifier).fetchUnreadCount();
    if (mounted) {
      FlutterNativeSplash.remove();
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return MaterialApp(
      title: 'HomeEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: _ready
          ? (user.isLoggedIn ? const HomeScreen() : const OnboardingScreen())
          : const SizedBox.shrink(),
    );
  }
}
