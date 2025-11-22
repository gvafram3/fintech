// import 'package:fintech/features/auth/screens/role_select_screen.dart';
import 'package:fintech/features/owner/transactions/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import '../../features/auth/screens/role_select_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/owner/main_layout_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String roleSelect = '/role-select';
  static const String mainLayout = '/main-layout';
  static const String transactions = '/transactions';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    roleSelect: (context) => const RoleSelectScreen(),
    mainLayout: (context) => const MainLayoutScreen(),
    transactions: (context) => const TransactionsScreen(),
  };
}
