import 'package:go_router/go_router.dart';
import '../features/login/login_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/members/members_page.dart';
import '../features/plans/plans_page.dart';
import '../features/subscriptions/subscriptions_page.dart';
import '../features/payments/payments_page.dart';
import '../features/attendance/attendance_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/members',
      name: 'members',
      builder: (context, state) => const MembersPage(),
    ),
    GoRoute(
      path: '/plans',
      name: 'plans',
      builder: (context, state) => const PlansPage(),
    ),
    GoRoute(
      path: '/subscriptions',
      name: 'subscriptions',
      builder: (context, state) => const SubscriptionsPage(),
    ),
    GoRoute(
      path: '/payments',
      name: 'payments',
      builder: (context, state) => const PaymentsPage(),
    ),
    GoRoute(
      path: '/attendance',
      name: 'attendance',
      builder: (context, state) => const AttendancePage(),
    ),
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const ReportsPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
