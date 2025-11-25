import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/models/transaction_model.dart';
import '../screens/sales_breakdown_screen.dart';
import '../screens/expense_report_screen.dart';
import '../screens/profit_loss_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedPeriod = '7 Days';
  final TransactionService _transactionService = TransactionService();

  double _revenue = 0;
  double _expenses = 0;
  double _profit = 0;
  double _totalDebt = 0;
  double _totalRevenue = 0;
  double _totalExpenses = 0;
  List<TransactionModel> _allTransactions = [];
  List<({DateTime date, double profit})> _dailyProfitData = [];
  bool _isLoading = true;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    if (!mounted) return;

    try {
      final days = _getPeriodDays();
      final revenue = await _transactionService.calculateRevenueForPeriod(days);
      final expenses = await _transactionService.calculateExpensesForPeriod(
        days,
      );
      final profit = await _transactionService.calculateProfitForPeriod(days);
      final debt = await _transactionService.calculateTotalDebt();
      final transactions = await _transactionService.getAllTransactions();
      final dailyData = await _transactionService.getDailyProfitData(days);

      if (mounted) {
        setState(() {
          _revenue = revenue;
          _expenses = expenses;
          _profit = profit;
          _totalDebt = debt;
          _allTransactions = transactions;
          _dailyProfitData = dailyData;
          _totalRevenue = revenue;
          _totalExpenses = expenses;
          _isLoading = false;
          _hasLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading report data: $e');
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
        await _loadReportData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Period',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                            fontSize: 13,
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
                        _loadReportData();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Cards (Smaller)
            if (_isLoading) _buildShimmerCards() else _buildSummaryCardsSmall(),

            const SizedBox(height: 24),

            // Revenue vs Expenses Chart
            if (_isLoading)
              _buildShimmerChart()
            else
              _buildRevenueVsExpensesChart(),

            const SizedBox(height: 24),

            // Profit Trend
            if (_isLoading) _buildShimmerChart() else _buildProfitTrendChart(),

            const SizedBox(height: 24),

            // Quick Reports
            _buildQuickReports(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: List.generate(
        4,
        (index) => Shimmer.fromColors(
          baseColor: AppColors.border.withOpacity(0.3),
          highlightColor: AppColors.border.withOpacity(0.6),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerChart() {
    return Shimmer.fromColors(
      baseColor: AppColors.border.withOpacity(0.3),
      highlightColor: AppColors.border.withOpacity(0.6),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSummaryCardsSmall() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildSmallCard(
          title: 'Revenue',
          amount: '₵${_revenue.toStringAsFixed(0)}',
          icon: Icons.trending_up,
          color: AppColors.primary,
        ),
        _buildSmallCard(
          title: 'Expenses',
          amount: '₵${_expenses.toStringAsFixed(0)}',
          icon: Icons.trending_down,
          color: AppColors.error,
        ),
        _buildSmallCard(
          title: 'Profit',
          amount: '₵${_profit.abs().toStringAsFixed(0)}',
          icon: _profit >= 0 ? Icons.trending_up : Icons.trending_down,
          color: _profit >= 0 ? AppColors.success : AppColors.error,
        ),
        _buildSmallCard(
          title: 'Debt',
          amount: '₵${_totalDebt.toStringAsFixed(0)}',
          icon: Icons.payment,
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueVsExpensesChart() {
    return Container(
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
            'Revenue vs Expenses',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxChartValue(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,

                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '₵${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        _getChartLabel(value.toInt()),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '₵${(value / 1000).toStringAsFixed(0)}K',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: [_buildBarGroup(0, _totalRevenue, _totalExpenses)],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Revenue',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 24),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Expenses',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double revenue, double expenses) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: revenue,
          color: AppColors.success,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expenses,
          color: AppColors.error,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      barsSpace: 12,
    );
  }

  double _getMaxChartValue() {
    final max = [_totalRevenue, _totalExpenses].reduce((a, b) => a > b ? a : b);
    return max * 1.2; // Add 20% padding
  }

  String _getChartLabel(int index) {
    final days = _getPeriodDays();
    if (days == 7) {
      const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return index < labels.length ? labels[index] : '';
    } else if (days == 30) {
      return index == 0 ? 'Week 1' : '';
    } else {
      const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
      return index < labels.length ? labels[index] : '';
    }
  }

  Widget _buildProfitTrendChart() {
    if (_dailyProfitData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No data available')),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profit Trend',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
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
                    color: _profit >= 0 ? AppColors.success : AppColors.error,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color:
                          (_profit >= 0 ? AppColors.success : AppColors.error)
                              .withOpacity(0.1),
                    ),
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
      const days = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su'];
      label = days[date.weekday % 7];
    } else if (_getPeriodDays() == 30) {
      if (index % 5 == 0) {
        label = '${date.day}';
      }
    } else {
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

  Widget _buildQuickReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Reports',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            // Sales Breakdown Card
            _buildQuickReportCard(
              icon: Icons.shopping_cart,
              title: 'Sales Breakdown',
              subtitle: 'Revenue by category',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesBreakdownScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Expense Report Card
            _buildQuickReportCard(
              icon: Icons.receipt,
              title: 'Expense Report',
              subtitle: 'Expenses by category',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseReportScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Profit & Loss Card
            _buildQuickReportCard(
              icon: Icons.assessment,
              title: 'Profit & Loss',
              subtitle: 'Income statement',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfitLossScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
