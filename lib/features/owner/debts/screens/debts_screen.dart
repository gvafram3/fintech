import 'package:fintech/core/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/transaction_service.dart';
import '../../transactions/screens/add_transaction_screen.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({Key? key}) : super(key: key);

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransactionService _transactionService = TransactionService();

  List<TransactionModel> _allDebts = [];
  List<TransactionModel> _pendingDebts = [];
  List<TransactionModel> _overdueDebts = [];
  List<TransactionModel> _paidDebts = [];
  double _totalOwed = 0;
  double _debtCollected = 0;
  double _outstanding = 0;
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDebtData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDebtData() async {
    if (!mounted) return;

    try {
      print('Loading debts...');
      final debts = await _transactionService.getTransactionsByType(
        TransactionType.debt,
      );

      print('Loaded ${debts.length} debts');

      final now = DateTime.now();
      final pending = <TransactionModel>[];
      final overdue = <TransactionModel>[];
      final paid = <TransactionModel>[];
      double totalOwed = 0;
      double outstanding = 0;

      for (final debt in debts) {
        totalOwed += debt.amount;

        if (debt.dueDate != null) {
          if (debt.dueDate!.isBefore(now)) {
            overdue.add(debt);
            outstanding += debt.amount;
          } else {
            pending.add(debt);
            outstanding += debt.amount;
          }
        } else {
          pending.add(debt);
          outstanding += debt.amount;
        }
      }

      if (mounted) {
        setState(() {
          _allDebts = debts;
          _pendingDebts = pending;
          _overdueDebts = overdue;
          _paidDebts = paid;
          _totalOwed = totalOwed;
          _outstanding = outstanding;
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading debts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    }
  }

  void _showDebtDetails(TransactionModel debt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDebtDetailsSheet(debt),
    );
  }

  Widget _buildDebtDetailsSheet(TransactionModel debt) {
    final isOverdue =
        debt.dueDate != null && debt.dueDate!.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.debtorName ?? debt.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        debt.subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₵${debt.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (debt.dueDate != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverdue ? 'Overdue' : 'Due Date',
                      style: TextStyle(
                        color: isOverdue ? AppColors.error : AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      debt.dueDate!.toString().split(' ')[0],
                      style: TextStyle(
                        color: isOverdue
                            ? AppColors.error
                            : AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (debt.description != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    debt.description!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _markDebtAsPaid(debt);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Mark as Paid',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await _deleteDebt(debt);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Delete',
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
      ),
    );
  }

  Future<void> _markDebtAsPaid(TransactionModel debt) async {
    try {
      await _transactionService.deleteTransaction(debt.id);
      await _loadDebtData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debt marked as paid'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _deleteDebt(TransactionModel debt) async {
    try {
      await _transactionService.deleteTransaction(debt.id);
      await _loadDebtData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debt deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadDebtData,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards - 2 in one row, 1 full width
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            label: 'Total Owed',
                            amount: _totalOwed,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            label: 'Collected',
                            amount: _debtCollected,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'Outstanding',
                      amount: _outstanding,
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: Column(
            children: [
              // Tab Bar
              Container(
                color: AppColors.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Overdue'),
                    Tab(text: 'Paid'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDebtList(_allDebts, 'No debts recorded', null),
                          _buildDebtList(
                            _pendingDebts,
                            'No pending debts',
                            AppColors.warning,
                          ),
                          _buildDebtList(
                            _overdueDebts,
                            'No overdue debts',
                            AppColors.error,
                          ),
                          _buildDebtList(
                            _paidDebts,
                            'No paid debts',
                            AppColors.success,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(
                transactionType: TransactionType.debt,
              ),
            ),
          );
          if (result == true) {
            await _loadDebtData();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIconForLabel(label), color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₵${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Total Owed':
        return Icons.trending_down;
      case 'Outstanding':
        return Icons.hourglass_bottom;
      case 'Collected':
        return Icons.check_circle;
      default:
        return Icons.payment;
    }
  }

  Widget _buildDebtList(
    List<TransactionModel> debts,
    String emptyMessage,
    Color? borderColor,
  ) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final debt = debts[index];

        return InkWell(
          onTap: () => _showDebtDetails(debt),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor ?? AppColors.border,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (borderColor ?? AppColors.warning).withOpacity(
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: borderColor ?? AppColors.warning,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.debtorName ?? debt.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            debt.description ?? 'No description',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (debt.dueDate != null)
                      Text(
                        'Due: ${debt.dueDate!.toString().split(' ')[0]}',
                        style: TextStyle(
                          color: borderColor ?? AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const Text(
                        'No due date',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    Text(
                      '₵${debt.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: borderColor ?? AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
