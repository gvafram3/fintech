// import 'package:fintech/features/transactions/screens/transaction_items.dart';
import 'package:flutter/material.dart';
import '../../../../core/data/transaction_items.dart';
import '../../../../core/theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Sales',
    'Expenses',
    'Salaries',
    'Debts',
  ];

  List<Map<String, Object>> get _filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    return transactionItems.where((item) {
      final title = (item['title'] as String).toLowerCase();
      final subtitle = (item['subtitle'] as String).toLowerCase();

      // Filter by search query
      final matchesQuery =
          q.isEmpty || title.contains(q) || subtitle.contains(q);

      // Filter by selected filter - match keywords in title/subtitle
      bool matchesFilter = true;
      switch (_selectedFilter) {
        case 'Sales':
          matchesFilter =
              title.contains('sale') ||
              title.contains('sales') ||
              subtitle.contains('sale');
          break;
        case 'Expenses':
          matchesFilter =
              title.contains('expense') ||
              title.contains('expenses') ||
              subtitle.contains('expense');
          break;
        case 'Salaries':
          matchesFilter =
              title.contains('salary') || subtitle.contains('salary');
          break;
        case 'Debts':
          matchesFilter =
              title.contains('debt') ||
              title.contains('debts') ||
              subtitle.contains('debt');
          break;
        default:
          matchesFilter = true;
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search transactions',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filter chips (horizontal scroll)
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final label = _filters[i];
              final selected = label == _selectedFilter;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _selectedFilter = label),
                selectedColor: AppColors.primary.withOpacity(0.12),
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _filteredItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return _buildActivityItem(
                icon: item['icon'] as IconData,
                iconColor: item['iconColor'] as Color,
                iconBgColor: (item['iconColor'] as Color).withOpacity(0.1),
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                amount: item['amount'] as String,
                time: item['time'] as String,
                isPositive: item['isPositive'] as bool,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required bool isPositive,
  }) {
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
