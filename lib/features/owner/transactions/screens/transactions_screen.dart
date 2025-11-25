import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/transaction_service.dart';
import '../../../../core/models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredItems = [];
  bool _isLoading = true;

  final List<String> _filters = [
    'All',
    'Sales',
    'Expenses',
    'Salaries',
    'Debts',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (!mounted) return;

    try {
      final transactions = await _transactionService.getAllTransactions();

      if (mounted) {
        setState(() {
          _allTransactions = transactions;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    print(
      'Applying filter: $_selectedFilter from ${_allTransactions.length} transactions',
    );

    if (_selectedFilter == 'All') {
      _filteredItems = List.from(_allTransactions);
    } else {
      final filterType = _selectedFilter.toLowerCase();
      _filteredItems = _allTransactions.where((t) {
        final transactionType = t.type.toString().split('.').last.toLowerCase();
        final matches = transactionType == filterType;
        print(
          'Transaction: ${t.title}, Type: $transactionType, Filter: $filterType, Match: $matches',
        );
        return matches;
      }).toList();
    }

    // Sort by newest first
    _filteredItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    print('After filter: ${_filteredItems.length} items');
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _applyFilter();
      } else {
        _filteredItems = _allTransactions
            .where(
              (t) =>
                  t.title.toLowerCase().contains(query.toLowerCase()) ||
                      t.subtitle.toLowerCase().contains(query.toLowerCase()) ||
                      t.category!.toLowerCase().contains(query.toLowerCase()) ??
                  false,
            )
            .toList();
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _searchQuery = '';
      _applyFilter();
    });
  }

  void _editTransaction(TransactionModel transaction) async {
    // Navigate to edit screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
    if (result == true) {
      await _loadTransactions();
    }
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    try {
      await _transactionService.deleteTransaction(transaction.id);
      if (mounted) {
        setState(() {
          _allTransactions.removeWhere((t) => t.id == transaction.id);
          _applyFilter();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting transaction: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: _onSearchChanged,
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

          // Filter chips
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
                  onSelected: (_) => _onFilterChanged(label),
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

          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteTransaction(item);
                          },
                          child: GestureDetector(
                            onTap: () => _editTransaction(item),
                            child: _buildTransactionItem(item),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionTypeSelector,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final iconData = _getTransactionIcon(transaction.type);
    final iconColor = _getTransactionColor(transaction.type);
    final isIncome =
        transaction.type == TransactionType.sale ||
        transaction.type == TransactionType.debt;

    return Container(
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
                const SizedBox(height: 4),
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
                '${isIncome ? '+' : '-'}₵${transaction.amount.toStringAsFixed(2)}',
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

  void _showTransactionTypeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Transaction Type',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildTransactionTypeOption(
              icon: Icons.shopping_cart,
              label: 'Sales',
              type: TransactionType.sale,
            ),
            const SizedBox(height: 12),
            _buildTransactionTypeOption(
              icon: Icons.receipt,
              label: 'Expenses',
              type: TransactionType.expense,
            ),
            const SizedBox(height: 12),
            _buildTransactionTypeOption(
              icon: Icons.people,
              label: 'Salaries',
              type: TransactionType.salary,
            ),
            const SizedBox(height: 12),
            _buildTransactionTypeOption(
              icon: Icons.attach_money,
              label: 'Debts',
              type: TransactionType.debt,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeOption({
    required IconData icon,
    required String label,
    required TransactionType type,
  }) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTransactionScreen(transactionType: type),
          ),
        );
        // Refresh transactions if one was added
        if (result == true) {
          await _loadTransactions();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
