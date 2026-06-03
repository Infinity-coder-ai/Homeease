import 'package:flutter_riverpod/flutter_riverpod.dart';

// Increment this after a rating submission to trigger UI refreshes.
final ratingRefreshProvider = StateProvider<int>((ref) => 0);
