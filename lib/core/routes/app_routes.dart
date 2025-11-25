// // import 'package:fintech/features/auth/screens/role_select_screen.dart';
// import 'package:fintech/features/owner/transactions/screens/transactions_screen.dart';
// import 'package:flutter/material.dart';
// import '../../features/auth/screens/role_select_screen.dart';
// import '../../features/auth/screens/splash_screen.dart';
// import '../../features/auth/screens/onboarding_screen.dart';
// import '../../features/auth/screens/login_screen.dart';
// import '../../features/auth/screens/signup_screen.dart';
// import '../../features/owner/main_layout_screen.dart';

// class AppRoutes {
//   static const String splash = '/';
//   static const String onboarding = '/onboarding';
//   static const String login = '/login';
//   static const String signup = '/signup';
//   static const String roleSelect = '/role-select';
//   static const String mainLayout = '/main-layout';
//   static const String transactions = '/transactions';

//   static Map<String, WidgetBuilder> routes = {
//     splash: (context) => const SplashScreen(),
//     onboarding: (context) => const OnboardingScreen(),
//     login: (context) => const LoginScreen(),
//     signup: (context) => const SignupScreen(),
//     roleSelect: (context) => const RoleSelectScreen(),
//     mainLayout: (context) => const MainLayoutScreen(),
//     transactions: (context) => const TransactionsScreen(),
//   };
// }

import 'package:flutter/material.dart';
import '../../features/account_officer/dashboard/screens/account_officer_main_layout_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
// import '../../features/auth/screens/role_select_screen.dart';
import '../../features/owner/main_layout_screen.dart';
import '../../features/manager/dashboard/screens/manager_main_layout_screen.dart';
// import '../../features/owner/settings/screens/backup_screen.dart';
// import '../../features/owner/settings/screens/exportdata_screen.dart';
// import '../../features/owner/settings/screens/notifications_screen.dart';
import '../../features/owner/settings/screens/profile_screen.dart';
// import '../../features/owner/settings/screens/settings_screen.dart';
// import '../../features/owner/notifications/screens/notifications_screen.dart';
// import '../../features/owner/data/screens/backup_screen.dart';
// import '../../features/owner/data/screens/export_data_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String roleSelect = '/role-select';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String backup = '/backup';
  static const String export = '/export';

  // Role-specific main layouts
  static const String ownerMainLayout = '/owner-main-layout';
  static const String managerMainLayout = '/manager-main-layout';
  static const String accountantMainLayout = '/accountant-main-layout';

  // Route mappings
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    profile: (context) => const ProfileScreen(),
    // roleSelect: (context) => const RoleSelectScreen(),
    // forgotPassword: (context) => const ForgotPasswordScreen(),

    // Role-specific layouts
    ownerMainLayout: (context) =>
        const MainLayoutScreen(), // Owner layout (existing)
    managerMainLayout: (context) =>
        const ManagerMainLayoutScreen(), // Manager layout
    accountantMainLayout: (context) =>
        const AccountantMainLayoutScreen(), // Accountant layout
  };

  // Helper method to get main layout route
  static String getMainLayoutRoute(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return ownerMainLayout;
      case 'manager':
        return managerMainLayout;
      case 'accountant':
        return accountantMainLayout;
      default:
        return ownerMainLayout;
    }
  }
}
