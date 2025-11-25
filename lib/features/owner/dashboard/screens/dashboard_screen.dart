import 'package:fintech/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/routes/app_routes.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/screens/transactions_screen.dart'; // << added
import '../../../../core/services/transaction_service.dart';
import '../../../../core/models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToTransactions;
  const DashboardScreen({super.key, this.onNavigateToTransactions});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String selectedPeriod = '7 Days';
  final TransactionService _transactionService = TransactionService();
  late AnimationController _animationController;

  double _totalRevenue = 0;
  double _totalProfit = 0;
  double _totalExpenses = 0;
  double _totalDebt = 0;
  int _totalSales = 0;
  List<TransactionModel> _recentTransactions = [];
  List<({DateTime date, double profit})> _dailyProfitData = [];
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Initialize sample data on first launch
    _initializeSampleData();
    _loadDashboardData();
  }

  Future<void> _initializeSampleData() async {
    // Only add sample data if user has no transactions
    final transactions = await _transactionService.getAllTransactions();
    if (transactions.isEmpty) {
      await _transactionService.addSampleData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    try {
      final days = _getPeriodDays();
      final revenue = await _transactionService.calculateRevenueForPeriod(days);
      final expenses = await _transactionService.calculateExpensesForPeriod(
        days,
      );
      final profit = await _transactionService.calculateProfitForPeriod(days);
      final debt = await _transactionService.calculateTotalDebt();
      final salesCount = await _transactionService.countTotalSales();
      final transactions = await _transactionService.getAllTransactions();
      final dailyData = await _transactionService.getDailyProfitData(days);

      print('Dashboard Data Loaded:');
      print('Revenue: $revenue');
      print('Expenses: $expenses');
      print('Profit: $profit');
      print('Debt: $debt');
      print('Sales Count: $salesCount');
      print('Transactions: ${transactions.length}');

      if (mounted) {
        setState(() {
          _totalRevenue = revenue;
          _totalExpenses = expenses;
          _totalProfit = profit;
          _totalDebt = debt;
          _totalSales = salesCount;
          _recentTransactions = transactions.take(4).toList();
          _dailyProfitData = dailyData;
          _isLoading = false;
          _hasLoaded = true;
        });
        // Restart animation
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    }
  }

  int _getPeriodDays() {
    switch (selectedPeriod) {
      case '7 Days':
        return 7;
      case '30 Days':
        return 30;
      case '1 Year':
        return 365;
      default:
        return 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _hasLoaded = false;
        });
        await _loadDashboardData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards Grid
            _buildSummaryCardsGrid(),

            const SizedBox(height: 24),

            // Period Selector - Standalone with Dropdown
            _buildPeriodSelectorDropdown(),

            const SizedBox(height: 24),

            // Profit Trend Chart with Animation
            _buildProfitChartWithAnimation(),

            const SizedBox(height: 24),

            // Quick Actions (No borders)
            _buildQuickActionsSimple(),

            const SizedBox(height: 24),

            // Recent Activities with View All Button
            _buildRecentActivitiesWithViewAll(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildGridCard(
          title: 'Total Revenue',
          amount: '₵${_totalRevenue.toStringAsFixed(0)}',
          icon: Icons.trending_up,
          color: AppColors.primary,
          isPositive: true,
        ),
        _buildGridCard(
          title: 'Total Expenditure',
          amount: '₵${_totalExpenses.toStringAsFixed(0)}',
          icon: Icons.trending_down,
          color: AppColors.error,
          isPositive: false,
        ),
        _buildGridCard(
          title: 'Net Profit',
          amount: '₵${_totalProfit.abs().toStringAsFixed(0)}',
          icon: _totalProfit >= 0 ? Icons.trending_up : Icons.trending_down,
          color: _totalProfit >= 0 ? AppColors.success : AppColors.error,
          isPositive: _totalProfit >= 0,
          showSign: true,
        ),
        _buildGridCard(
          title: 'Total Debt',
          amount: '₵${_totalDebt.toStringAsFixed(0)}',
          icon: Icons.payment,
          color: AppColors.warning,
          isPositive: false,
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isPositive,
    bool showSign = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelectorDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Period',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: selectedPeriod,
            underline: const SizedBox(),
            items: ['7 Days', '30 Days', '1 Year'].map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(
                  period,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedPeriod = value;
                  _hasLoaded = false;
                });
                _loadDashboardData();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfitChartWithAnimation() {
    if (_dailyProfitData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No data available for this period'),
          ),
        ),
      );
    }

    final maxProfit = _dailyProfitData.isEmpty
        ? 0.0
        : _dailyProfitData.fold<double>(
            0,
            (prev, curr) => curr.profit > prev ? curr.profit : prev,
          );
    final minProfit = _dailyProfitData.isEmpty
        ? 0.0
        : _dailyProfitData.fold<double>(
            0,
            (prev, curr) => curr.profit < prev ? curr.profit : prev,
          );
    final absMax = [
      maxProfit.abs(),
      minProfit.abs(),
    ].reduce((a, b) => a > b ? a : b);

    List<FlSpot> spots = [];
    for (int i = 0; i < _dailyProfitData.length; i++) {
      spots.add(FlSpot(i.toDouble(), _dailyProfitData[i].profit));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profit Trend',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                _totalProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                color: _totalProfit >= 0 ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: absMax > 0 ? absMax / 4 : 1000,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return _getXAxisLabel(value);
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: _totalProfit >= 0
                            ? AppColors.success
                            : AppColors.error,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              (_totalProfit >= 0
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withOpacity(0.2),
                        ),
                        isStrokeCapRound: true,
                      ),
                    ],
                    minX: 0,
                    maxX: _dailyProfitData.length > 1
                        ? _dailyProfitData.length - 1.0
                        : 1.0,
                    minY: minProfit - absMax * 0.1,
                    maxY: maxProfit + absMax * 0.1,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchSpot) {
                          final index = touchSpot.x.toInt();
                          if (index >= 0 && index < _dailyProfitData.length) {
                            final data = _dailyProfitData[index];
                            return data.profit >= 0
                                ? AppColors.success.withOpacity(0.9)
                                : AppColors.error.withOpacity(0.9);
                          }
                          return AppColors.textPrimary.withOpacity(0.9);
                        },
                        tooltipBorderRadius: BorderRadius.circular(8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((touch) {
                            final index = touch.x.toInt();
                            if (index >= 0 && index < _dailyProfitData.length) {
                              final data = _dailyProfitData[index];
                              final isPositive = data.profit >= 0;
                              return LineTooltipItem(
                                '${data.date.month}/${data.date.day}\n₵${data.profit.toStringAsFixed(2)}',
                                TextStyle(
                                  color: isPositive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getXAxisLabel(double value) {
    final index = value.toInt();
    if (index < 0 || index >= _dailyProfitData.length) {
      return const SizedBox();
    }

    final date = _dailyProfitData[index].date;
    String label = '';

    if (_getPeriodDays() == 7) {
      // M T W Th F S Su
      const days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
      label = days[date.weekday % 7];
    } else if (_getPeriodDays() == 30) {
      // Show every 5th day
      if (index % 5 == 0) {
        label = '${date.day}';
      }
    } else {
      // 365 days - show quarter starts
      if (date.month == 1 && date.day <= 7) {
        label = 'Q1';
      } else if (date.month == 4 && date.day <= 7) {
        label = 'Q2';
      } else if (date.month == 7 && date.day <= 7) {
        label = 'Q3';
      } else if (date.month == 10 && date.day <= 7) {
        label = 'Q4';
      }
    }

    return Text(
      label,
      style: const TextStyle(color: AppColors.textLight, fontSize: 10),
    );
  }

  Widget _buildQuickActionsSimple() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButtonSimple(
            icon: Icons.add_shopping_cart,
            label: 'Sale',
            color: AppColors.primary,
            onTap: () => _navigateToAddTransaction(TransactionType.sale),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButtonSimple(
            icon: Icons.receipt,
            label: 'Expense',
            color: AppColors.error,
            onTap: () => _navigateToAddTransaction(TransactionType.expense),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButtonSimple(
            icon: Icons.account_balance_wallet,
            label: 'Salary',
            color: AppColors.success,
            onTap: () => _navigateToAddTransaction(TransactionType.salary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButtonSimple(
            icon: Icons.assignment,
            label: 'Debt',
            color: AppColors.warning,
            onTap: () => _navigateToAddTransaction(TransactionType.debt),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonSimple({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesWithViewAll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                // Use callback to change index in MainLayoutScreen
                widget.onNavigateToTransactions?.call();
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentTransactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No recent transactions',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return Tooltip(
                message: 'Swipe left to delete',
                showDuration: const Duration(seconds: 2),
                child: _buildActivityItem(_recentTransactions[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildActivityItem(TransactionModel transaction) {
    final iconData = _getTransactionIcon(transaction.type);
    final iconColor = _getTransactionColor(transaction.type);
    final isPositive =
        transaction.type == TransactionType.sale ||
        transaction.type == TransactionType.debt;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}₵${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: iconColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTimeAgo(transaction.createdAt),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return Icons.shopping_cart;
      case TransactionType.expense:
        return Icons.receipt_long_outlined;
      case TransactionType.salary:
        return Icons.account_balance_wallet;
      case TransactionType.debt:
        return Icons.assignment_outlined;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return AppColors.primary;
      case TransactionType.expense:
        return AppColors.error;
      case TransactionType.salary:
        return AppColors.success;
      case TransactionType.debt:
        return AppColors.warning;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  Future<void> _navigateToAddTransaction(TransactionType type) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transactionType: type),
      ),
    );
    if (result == true) {
      setState(() {
        _hasLoaded = false;
      });
      await _loadDashboardData();
    }
  }
}
