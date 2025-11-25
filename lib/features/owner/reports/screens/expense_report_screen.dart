import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/models/transaction_model.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _expenseTransactions = [];
  bool _isLoading = true;
  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenseData();
  }

  Future<void> _loadExpenseData() async {
    try {
      final expenses = await _transactionService.getTransactionsByType(
        TransactionType.expense,
      );
      double total = 0;
      for (final expense in expenses) {
        total += expense.amount;
      }

      if (mounted) {
        setState(() {
          _expenseTransactions = expenses;
          _totalExpenses = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading expense data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group expenses by category
    Map<String, double> categoryTotals = {};
    for (final expense in _expenseTransactions) {
      final category = expense.category ?? 'Uncategorized';
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + expense.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Expense Report',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Shimmer.fromColors(
                baseColor: AppColors.border.withOpacity(0.3),
                highlightColor: AppColors.border.withOpacity(0.6),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadExpenseData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Expenses Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₵${_totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pie Chart
                    if (categoryTotals.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expenses by Category',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    ...categoryTotals.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final index = entry.key;
                                          final category = entry.value.key;
                                          final amount = entry.value.value;
                                          final percentage =
                                              (amount / _totalExpenses) * 100;

                                          final colors = [
                                            AppColors.error,
                                            AppColors.warning,
                                            AppColors.secondary,
                                            AppColors.primary,
                                            AppColors.success,
                                          ];

                                          return PieChartSectionData(
                                            color:
                                                colors[index % colors.length],
                                            value: amount,
                                            title:
                                                '${percentage.toStringAsFixed(1)}%',
                                            radius: 60,
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ],
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Legend
                            Column(
                              children: [
                                ...categoryTotals.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final category = entry.value.key;
                                      final amount = entry.value.value;

                                      final colors = [
                                        AppColors.error,
                                        AppColors.warning,
                                        AppColors.secondary,
                                        AppColors.primary,
                                        AppColors.success,
                                      ];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color:
                                                    colors[index %
                                                        colors.length],
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                category,
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '₵${amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // All Expenses List
                    const Text(
                      'All Expenses',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _expenseTransactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final expense = _expenseTransactions[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.receipt,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expense.category ?? 'Uncategorized',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '-₵${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
