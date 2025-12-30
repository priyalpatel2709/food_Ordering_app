import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the active tab index of the main navigation
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
