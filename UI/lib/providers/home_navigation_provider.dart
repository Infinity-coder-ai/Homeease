import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active tab index inside [HomeScreen] bottom navigation (0 = Home, 1 = Bookings, 2 = Profile).
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
