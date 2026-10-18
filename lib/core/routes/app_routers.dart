// For future url based screens

import 'package:go_router/go_router.dart';
import 'package:omnix/core/routes/app_routes.dart';
import 'package:omnix/features/dashboard/screens/dashboard_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
