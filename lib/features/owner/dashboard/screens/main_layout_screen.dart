import 'package:fintech/features/owner/dashboard/screens/dashboard_screen.dart';
import 'package:fintech/features/owner/debts/screens/debts_screen.dart';
import 'package:fintech/features/owner/reports/screens/reports_screen.dart';
import 'package:fintech/features/owner/settings/screens/settings_screen.dart';
import 'package:fintech/features/owner/transactions/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_theme.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  String _userFirstName = '';

  List<Widget> get _screens => [
    DashboardScreen(
      onNavigateToTransactions: () {
        setState(() {
          _currentIndex = 1;
        });
      },
    ),
    TransactionsScreen(),
    ReportsScreen(),
    DebtManagementScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserFirstName();
  }

  Future<void> _loadUserFirstName() async {
    final authService = AuthService();
    final userData = await authService.getUserData();
    if (userData != null && userData['fullName'] != null) {
      final fullName = userData['fullName'] as String;
      final firstName = fullName.split(' ').first;
      setState(() {
        _userFirstName = firstName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentIndex == 0
                  ? 'Dashboard'
                  : _currentIndex == 1
                  ? 'Transactions'
                  : _currentIndex == 2
                  ? 'Reports'
                  : _currentIndex == 3
                  ? 'Debts'
                  : 'Settings',

              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_currentIndex == 0)
              Text(
                'Welcome back, $_userFirstName',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),

        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {},
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ]
            : _currentIndex == 2
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.file_download_outlined,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _showExportDialog();
                  },
                ),
              ]
            : null,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.dashboard_outlined,
                Icons.dashboard,
                'Dashboard',
                0,
              ),
              _buildNavItem(
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                'Transactions',
                1,
              ),
              _buildNavItem(
                Icons.bar_chart_outlined,
                Icons.bar_chart,
                'Reports',
                2,
              ),
              _buildNavItem(
                Icons.assignment_outlined,
                Icons.assignment,
                'Debts',
                3,
              ),
              _buildNavItem(
                Icons.settings_outlined,
                Icons.settings,
                'Settings',
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Export Report',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption(
              'Export as PDF',
              Icons.picture_as_pdf,
              AppColors.error,
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              'Export as Excel',
              Icons.table_chart,
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              'Export as CSV',
              Icons.insert_drive_file,
              AppColors.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting $title...'),
            backgroundColor: AppColors.success,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
