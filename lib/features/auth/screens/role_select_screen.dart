import 'package:fintech/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;

  final List<RoleItem> _roles = [
    RoleItem(
      id: 'owner',
      title: 'Owner',
      description: 'Full access to all features and settings',
      permissions: [
        'Manage all transactions',
        'View all reports',
        'Manage users',
        'Edit settings',
      ],
      icon: Icons.admin_panel_settings_rounded,
    ),
    RoleItem(
      id: 'manager',
      title: 'Manager',
      description: 'Manage sales, expenses and reports',
      permissions: [
        'Add/edit sales',
        'Add/edit expenses',
        'View reports',
        'Manage salaries',
      ],
      icon: Icons.manage_accounts_rounded,
    ),
    RoleItem(
      id: 'account_officer',
      title: 'Account Officer',
      description: 'View reports and manage transactions',
      permissions: [
        'View all transactions',
        'View reports',
        'Export data',
        'Add transactions',
      ],
      icon: Icons.account_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Header
                    Text(
                      'Select Your Role',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the role that best describes your position',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 48),

                    // Role Cards
                    ...List.generate(_roles.length, (index) {
                      final role = _roles[index];
                      final isSelected = _selectedRole == role.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRole = role.id;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.03),
                                blurRadius: isSelected ? 12 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      role.icon,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Title and Description
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          role.description,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Check Icon
                                  if (isSelected)
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Divider
                              const Divider(),
                              const SizedBox(height: 12),

                              // Permissions List
                              ...List.generate(role.permissions.length, (i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textLight,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          role.permissions[i],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRole != null
                      ? () {
                          // TODO: Navigate to Dashboard
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text('Role selected: $_selectedRole'),
                          //     backgroundColor: AppColors.success,
                          //   ),
                          // );

                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRole != null
                        ? AppColors.primary
                        : AppColors.border,
                    disabledBackgroundColor: AppColors.border,
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleItem {
  final String id;
  final String title;
  final String description;
  final List<String> permissions;
  final IconData icon;

  RoleItem({
    required this.id,
    required this.title,
    required this.description,
    required this.permissions,
    required this.icon,
  });
}
