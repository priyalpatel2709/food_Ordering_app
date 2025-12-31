import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/menu/presentation/views/menu_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/menu/presentation/widgets/custom_bottom_navigation_bar.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';

import 'navigation_provider.dart';

/// Main navigation page that uses IndexedStack for bottom navigation
class MainNavigationPage extends ConsumerWidget {
  const MainNavigationPage({super.key});

  // List of pages for IndexedStack
  final List<Widget> _pages = const [
    MenuPage(),
    CartPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        cartItemCount: cartItemCount,
      ),
    );
  }
}
