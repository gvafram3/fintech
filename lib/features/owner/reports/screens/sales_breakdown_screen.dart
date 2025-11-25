import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/models/transaction_model.dart';

class SalesBreakdownScreen extends StatefulWidget {
  const SalesBreakdownScreen({Key? key}) : super(key: key);

  @override
  State<SalesBreakdownScreen> createState() => _SalesBreakdownScreenState();
}

class _SalesBreakdownScreenState extends State<SalesBreakdownScreen> {
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _salesTransactions = [];
  bool _isLoading = true;
  double _totalSales = 0;

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    try {
      final sales = await _transactionService.getTransactionsByType(
        TransactionType.sale,
      );
      double total = 0;
      for (final sale in sales) {
        total += sale.amount;
      }

      if (mounted) {
        setState(() {
          _salesTransactions = sales;
          _totalSales = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading sales data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group sales by category
    Map<String, double> categoryTotals = {};
    for (final sale in _salesTransactions) {
      final category = sale.category ?? 'Uncategorized';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + sale.amount;
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
          'Sales Breakdown',
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
              onRefresh: _loadSalesData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Sales Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Sales',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₵${_totalSales.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
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
                              'Sales by Category',
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
                                          final amount = entry.value.value;
                                          final percentage =
                                              (amount / _totalSales) * 100;

                                          final colors = [
                                            AppColors.primary,
                                            AppColors.secondary,
                                            AppColors.success,
                                            AppColors.warning,
                                            AppColors.error,
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
                                        AppColors.primary,
                                        AppColors.secondary,
                                        AppColors.success,
                                        AppColors.warning,
                                        AppColors.error,
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

                    // All Sales List
                    const Text(
                      'All Sales',
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
                      itemCount: _salesTransactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sale = _salesTransactions[index];
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
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.shopping_cart,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sale.title,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sale.category ?? 'Uncategorized',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '+₵${sale.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
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
