import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../transactions/screens/add_transaction_screen.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({Key? key}) : super(key: key);

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.surface,
      //   elevation: 0,
      //   title: const Text(
      //     'Debt Management',
      //     style: TextStyle(
      //       color: AppColors.textPrimary,
      //       fontSize: 20,
      //       fontWeight: FontWeight.w700,
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.trending_up,
                        iconColor: AppColors.warning,
                        label: 'Total Owed',
                        amount: '₵23,600',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.trending_down,
                        iconColor: AppColors.success,
                        label: 'Debt Collected',
                        amount: '₵12,400',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSummaryCard(
                  icon: Icons.error_outline,
                  iconColor: AppColors.error,
                  label: 'Outstanding',
                  amount: '₵18,800',
                  isFullWidth: true,
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Overdue'),
                Tab(text: 'Pending'),
                Tab(text: 'Paid'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDebtList(_overdueDebts, isOverdue: true),
                _buildDebtList(_pendingDebts),
                _buildDebtList(_paidDebts, isPaid: true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(
                transactionType: TransactionType.debt,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: isFullWidth
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        amount,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDebtList(
    List<DebtItem> debts, {
    bool isOverdue = false,
    bool isPaid = false,
  }) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              isOverdue
                  ? 'No overdue debts'
                  : isPaid
                  ? 'No paid debts'
                  : 'No pending debts',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        return _buildDebtCard(debt, isOverdue: isOverdue, isPaid: isPaid);
      },
    );
  }

  Widget _buildDebtCard(
    DebtItem debt, {
    bool isOverdue = false,
    bool isPaid = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withOpacity(0.3)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDebtDetails(debt),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOverdue
                    ? AppColors.error.withOpacity(0.1)
                    : isPaid
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_outline,
                color: isOverdue
                    ? AppColors.error
                    : isPaid
                    ? AppColors.success
                    : AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.debtorName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${debt.dueDate}',
                    style: TextStyle(
                      color: isOverdue
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  debt.amount,
                  style: TextStyle(
                    color: isOverdue
                        ? AppColors.error
                        : isPaid
                        ? AppColors.success
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AppColors.error.withOpacity(0.1)
                        : isPaid
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOverdue
                        ? 'Overdue'
                        : isPaid
                        ? 'Paid'
                        : 'Pending',
                    style: TextStyle(
                      color: isOverdue
                          ? AppColors.error
                          : isPaid
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDebtDetails(DebtItem debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Debt Details',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Debtor Name', debt.debtorName),
                _buildDetailRow('Amount', debt.amount),
                _buildDetailRow('Due Date', debt.dueDate),
                _buildDetailRow('Category', debt.category),
                _buildDetailRow('Payment Method', debt.paymentMethod),
                if (debt.notes != null && debt.notes!.isNotEmpty)
                  _buildDetailRow('Notes', debt.notes!),
                const SizedBox(height: 24),
                if (debt.status != 'Paid') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _markAsPaid(debt);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Mark as Paid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editDebt(debt);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Edit Debt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteDebt(debt);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Delete Debt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(DebtItem debt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${debt.debtorName}\'s debt marked as paid'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _editDebt(DebtItem debt) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteDebt(DebtItem debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Debt',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${debt.debtorName}\'s debt?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Debt deleted successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // Sample Data
  final List<DebtItem> _overdueDebts = [
    DebtItem(
      debtorName: 'XYZ Limited',
      amount: '₵3,200',
      dueDate: 'Dec 20, 2024',
      category: 'Customer Debt',
      paymentMethod: 'Bank Transfer',
      status: 'Overdue',
      notes: 'Payment overdue by 2 days',
    ),
  ];

  final List<DebtItem> _pendingDebts = [
    DebtItem(
      debtorName: 'ABC Corporation',
      amount: '₵5,000',
      dueDate: 'Dec 25, 2024',
      category: 'Customer Debt',
      paymentMethod: 'Mobile Money',
      status: 'Pending',
    ),
    DebtItem(
      debtorName: 'Tech Solutions Inc',
      amount: '₵8,500',
      dueDate: 'Jan 5, 2025',
      category: 'Supplier Debt',
      paymentMethod: 'Bank Transfer',
      status: 'Pending',
    ),
    DebtItem(
      debtorName: 'Smith & Co',
      amount: '₵4,800',
      dueDate: 'Dec 28, 2024',
      category: 'Customer Debt',
      paymentMethod: 'Cash',
      status: 'Pending',
    ),
  ];

  final List<DebtItem> _paidDebts = [
    DebtItem(
      debtorName: 'Global Traders',
      amount: '₵2,100',
      dueDate: 'Paid on: Dec 15, 2024',
      category: 'Customer Debt',
      paymentMethod: 'Bank Transfer',
      status: 'Paid',
    ),
  ];
}

class DebtItem {
  final String debtorName;
  final String amount;
  final String dueDate;
  final String category;
  final String paymentMethod;
  final String status;
  final String? notes;

  DebtItem({
    required this.debtorName,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.paymentMethod,
    required this.status,
    this.notes,
  });
}
