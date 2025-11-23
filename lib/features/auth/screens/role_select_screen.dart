// import 'package:fintech/core/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import '../../../core/theme/app_theme.dart';

// class RoleSelectScreen extends StatefulWidget {
//   const RoleSelectScreen({Key? key}) : super(key: key);

//   @override
//   State<RoleSelectScreen> createState() => _RoleSelectScreenState();
// }

// class _RoleSelectScreenState extends State<RoleSelectScreen> {
//   String? _selectedRole;

//   final List<RoleItem> _roles = [
//     RoleItem(
//       id: 'owner',
//       title: 'Owner',
//       description: 'Full access to all features and settings',
//       permissions: [
//         'Manage all transactions',
//         'View all reports',
//         'Manage users',
//         'Edit settings',
//       ],
//       icon: Icons.admin_panel_settings_rounded,
//     ),
//     RoleItem(
//       id: 'manager',
//       title: 'Manager',
//       description: 'Manage sales, expenses and reports',
//       permissions: [
//         'Add/edit sales',
//         'Add/edit expenses',
//         'View reports',
//         'Manage salaries',
//       ],
//       icon: Icons.manage_accounts_rounded,
//     ),
//     RoleItem(
//       id: 'account_officer',
//       title: 'Account Officer',
//       description: 'View reports and manage transactions',
//       permissions: [
//         'View all transactions',
//         'View reports',
//         'Export data',
//         'Add transactions',
//       ],
//       icon: Icons.account_circle_rounded,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 32),

//                     // Header
//                     Text(
//                       'Select Your Role',
//                       style: Theme.of(context).textTheme.displayLarge,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Choose the role that best describes your position',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     const SizedBox(height: 48),

//                     // Role Cards
//                     ...List.generate(_roles.length, (index) {
//                       final role = _roles[index];
//                       final isSelected = _selectedRole == role.id;

//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selectedRole = role.id;
//                           });
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           margin: const EdgeInsets.only(bottom: 16),
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: AppColors.surface,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: isSelected
//                                   ? AppColors.primary
//                                   : AppColors.border,
//                               width: isSelected ? 2 : 1,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: isSelected
//                                     ? AppColors.primary.withOpacity(0.1)
//                                     : Colors.black.withOpacity(0.03),
//                                 blurRadius: isSelected ? 12 : 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Header Row
//                               Row(
//                                 children: [
//                                   // Icon
//                                   Container(
//                                     width: 48,
//                                     height: 48,
//                                     decoration: BoxDecoration(
//                                       color: isSelected
//                                           ? AppColors.primary.withOpacity(0.1)
//                                           : AppColors.background,
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: Icon(
//                                       role.icon,
//                                       color: isSelected
//                                           ? AppColors.primary
//                                           : AppColors.textSecondary,
//                                       size: 28,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),

//                                   // Title and Description
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           role.title,
//                                           style: Theme.of(
//                                             context,
//                                           ).textTheme.titleLarge,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           role.description,
//                                           style: Theme.of(
//                                             context,
//                                           ).textTheme.bodyMedium,
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                   // Check Icon
//                                   if (isSelected)
//                                     Container(
//                                       width: 28,
//                                       height: 28,
//                                       decoration: const BoxDecoration(
//                                         color: AppColors.primary,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: const Icon(
//                                         Icons.check_rounded,
//                                         color: Colors.white,
//                                         size: 18,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),

//                               // Divider
//                               const Divider(),
//                               const SizedBox(height: 12),

//                               // Permissions List
//                               ...List.generate(role.permissions.length, (i) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 8),
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         width: 6,
//                                         height: 6,
//                                         decoration: BoxDecoration(
//                                           color: isSelected
//                                               ? AppColors.primary
//                                               : AppColors.textLight,
//                                           shape: BoxShape.circle,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Text(
//                                           role.permissions[i],
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             color: AppColors.textSecondary,
//                                             fontWeight: isSelected
//                                                 ? FontWeight.w500
//                                                 : FontWeight.w400,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),

//             // Continue Button
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _selectedRole != null
//                       ? () {
//                           // TODO: Navigate to Dashboard
//                           // ScaffoldMessenger.of(context).showSnackBar(
//                           //   SnackBar(
//                           //     content: Text('Role selected: $_selectedRole'),
//                           //     backgroundColor: AppColors.success,
//                           //   ),
//                           // );

//                           Navigator.pushReplacementNamed(
//                             context,
//                             AppRoutes.login,
//                           );
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _selectedRole != null
//                         ? AppColors.primary
//                         : AppColors.border,
//                     disabledBackgroundColor: AppColors.border,
//                   ),
//                   child: const Text('Continue'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RoleItem {
//   final String id;
//   final String title;
//   final String description;
//   final List<String> permissions;
//   final IconData icon;

//   RoleItem({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.permissions,
//     required this.icon,
//   });
// }






/////////////////////////////////////////////////////////////////////



// import 'package:flutter/material.dart';
// import '../../../core/theme/app_theme.dart';
// import '../../../core/routes/app_routes.dart';
// import '../../../core/services/auth_service.dart';

// class RoleSelectScreen extends StatefulWidget {
//   const RoleSelectScreen({Key? key}) : super(key: key);

//   @override
//   State<RoleSelectScreen> createState() => _RoleSelectScreenState();
// }

// class _RoleSelectScreenState extends State<RoleSelectScreen> {
//   String? _selectedRole;
//   final _authService = AuthService();
//   bool _isLoading = false;

//   final List<Map<String, dynamic>> _roles = [
//     {
//       'id': 'owner',
//       'title': 'Owner',
//       'icon': Icons.business_center,
//       'description': 'Full access to all features and settings',
//     },
//     {
//       'id': 'manager',
//       'title': 'Manager',
//       'icon': Icons.manage_accounts,
//       'description': 'Manage operations and view reports',
//     },
//     {
//       'id': 'accountant',
//       'title': 'Account Officer',
//       'icon': Icons.account_balance,
//       'description': 'Handle financial transactions and records',
//     },
//   ];

//   Future<void> _handleContinue() async {
//     if (_selectedRole == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     // Save role to Firestore
//     await _authService.updateUserRole(_selectedRole!);

//     setState(() {
//       _isLoading = false;
//     });

//     if (!mounted) return;

//     // Sign out the user after role selection
//     await _authService.signOut();

//     if (!mounted) return;

//     // Navigate to login screen for proper authentication
//     Navigator.pushReplacementNamed(context, AppRoutes.login);

//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Role saved successfully! Please login to continue.'),
//         backgroundColor: AppColors.success,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 'Select Your Role',
//                 style: TextStyle(
//                   color: AppColors.textPrimary,
//                   fontSize: 32,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Choose the role that best describes you',
//                 style: TextStyle(
//                   color: AppColors.textSecondary,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               const SizedBox(height: 40),

//               // Role Cards
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _roles.length,
//                   itemBuilder: (context, index) {
//                     final role = _roles[index];
//                     final isSelected = _selectedRole == role['id'];

//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedRole = role['id'];
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         margin: const EdgeInsets.only(bottom: 16),
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: AppColors.surface,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: isSelected
//                                 ? AppColors.primary
//                                 : AppColors.border,
//                             width: isSelected ? 2 : 1,
//                           ),
//                           boxShadow: [
//                             if (isSelected)
//                               BoxShadow(
//                                 color: AppColors.primary.withOpacity(0.1),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? AppColors.primary.withOpacity(0.1)
//                                     : AppColors.background,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Icon(
//                                 role['icon'],
//                                 color: isSelected
//                                     ? AppColors.primary
//                                     : AppColors.textSecondary,
//                                 size: 32,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     role['title'],
//                                     style: TextStyle(
//                                       color: AppColors.textPrimary,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     role['description'],
//                                     style: const TextStyle(
//                                       color: AppColors.textSecondary,
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if (isSelected)
//                               Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: const BoxDecoration(
//                                   color: AppColors.primary,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.check,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               // Continue Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _selectedRole != null && !_isLoading
//                       ? _handleContinue
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _selectedRole != null
//                         ? AppColors.primary
//                         : AppColors.border,
//                     disabledBackgroundColor: AppColors.border,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text(
//                           'Continue',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
