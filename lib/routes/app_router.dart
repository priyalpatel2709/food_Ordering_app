import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/authentication/presentation/pages/sign_up_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/dine_in/presentation/pages/dine_in_tables_page.dart';
import '../features/dine_in/presentation/pages/table_details_page.dart';
import '../features/dine_in/domain/entities/table_entity.dart';
import '../shared/navigation/main_navigation_page.dart';
import '../features/kds/presentation/pages/kds_page.dart';
import '../features/restaurant/presentation/pages/staff_home_page.dart';
import '../features/menu/presentation/views/menu_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';

class AppRouter {
  // Route paths and names are now centralized in RouteConstants
  // This class only handles the router configuration

  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: RouteConstants.splashName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.login,
        name: RouteConstants.loginName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.signin,
        name: RouteConstants.signInName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignInPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.home,
        name: RouteConstants.homeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainNavigationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.staffHome,
        name: RouteConstants.staffHomeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StaffHomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.dineInTables,
        name: RouteConstants.dineInTablesName,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DineInTablesPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.dineInTableDetails,
        name: RouteConstants.dineInTableDetailsName,
        pageBuilder: (context, state) {
          final table = state.extra as TableEntity?;
          // Fallback if accessed directly via URL without extra object
          if (table == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const Scaffold(
                body: Center(child: Text("Table data missing")),
              ),
              transitionsBuilder: (context, anim, sec, child) =>
                  FadeTransition(opacity: anim, child: child),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: TableDetailsPage(table: table),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: RouteConstants.kds,
        name: RouteConstants.kdsName,
        builder: (context, state) => const KdsPage(),
      ),
      GoRoute(
        path: RouteConstants.menu,
        name: RouteConstants.menuName,
        builder: (context, state) => const MenuPage(),
      ),
      GoRoute(
        path: RouteConstants.cart,
        name: RouteConstants.cartName,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: RouteConstants.orders,
        name: RouteConstants.ordersName,
        builder: (context, state) => const OrdersPage(),
      ),
    ],
  );
}
