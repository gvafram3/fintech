import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/models/transaction_model.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({Key? key}) : super(key: key);

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final TransactionService _transactionService = TransactionService();
  double _revenue = 0;
  double _expenses = 0;
  double _salaries = 0;
  double _profit = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPLData();
  }

  Future<void> _loadPLData() async {
    try {
      final sales = await _transactionService.getTransactionsByType(
        TransactionType.sale,
      );
      final expenses = await _transactionService.getTransactionsByType(
        TransactionType.expense,
      );
      final salaries = await _transactionService.getTransactionsByType(
        TransactionType.salary,
      );

      double revenue = 0;
      double totalExpenses = 0;
      double totalSalaries = 0;

      for (final sale in sales) {
        revenue += sale.amount;
      }

      for (final expense in expenses) {
        totalExpenses += expense.amount;
      }

      for (final salary in salaries) {
        totalSalaries += salary.amount;
      }

      final profit = revenue - totalExpenses - totalSalaries;

      if (mounted) {
        setState(() {
          _revenue = revenue;
          _expenses = totalExpenses;
          _salaries = totalSalaries;
          _profit = profit;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading P&L data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Profit & Loss Statement',
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
              onRefresh: _loadPLData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // P&L Statement
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Income Statement',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Revenue
                          _buildPLRow(
                            label: 'Total Revenue',
                            amount: _revenue,
                            color: AppColors.primary,
                            bold: true,
                          ),
                          const SizedBox(height: 16),
                          // Expenses Section
                          _buildPLRow(
                            label: 'Operating Expenses',
                            amount: _expenses,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          _buildPLRow(
                            label: 'Salaries & Wages',
                            amount: _salaries,
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.border, thickness: 2),
                          const SizedBox(height: 16),
                          // Total Expenses
                          _buildPLRow(
                            label: 'Total Expenses',
                            amount: _expenses + _salaries,
                            color: AppColors.error,
                            bold: true,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: AppColors.border, thickness: 3),
                          const SizedBox(height: 20),
                          // Net Profit
                          _buildPLRow(
                            label: 'Net Profit',
                            amount: _profit,
                            color: _profit >= 0
                                ? AppColors.success
                                : AppColors.error,
                            bold: true,
                            large: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Summary Cards
                    const Text(
                      'Summary',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'Revenue',
                      amount: _revenue,
                      color: AppColors.primary,
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'Total Expenses',
                      amount: _expenses + _salaries,
                      color: AppColors.error,
                      icon: Icons.trending_down,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'Net Profit',
                      amount: _profit,
                      color: _profit >= 0 ? AppColors.success : AppColors.error,
                      icon: _profit >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPLRow({
    required String label,
    required double amount,
    required Color color,
    bool bold = false,
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: large ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          '₵${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: large ? 18 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₵${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
