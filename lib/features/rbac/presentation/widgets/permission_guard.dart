import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class PermissionGuard extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget fallback;

  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState is AuthAuthenticated) {
      if (authState.user.hasPermission(permission)) {
        return child;
      }
    }

    return fallback;
  }
}
