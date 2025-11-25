import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  String get _transactionsCollection => 'users/$_userId/transactions';

  // Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      print('=== getAllTransactions START ===');
      print('Collection path: $_transactionsCollection');

      final querySnapshot = await _firestore
          .collection(_transactionsCollection)
          .get(); // REMOVED: .orderBy('createdAt', descending: true)

      print('Query returned ${querySnapshot.docs.length} documents');

      final transactions = <TransactionModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          final transaction = TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          transactions.add(transaction);
          print('✓ Parsed: ${transaction.title}');
        } catch (e) {
          print('✗ Error parsing transaction: $e');
          continue;
        }
      }

      // SORT IN CODE
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('Successfully loaded ${transactions.length} transactions');
      print('=== getAllTransactions END ===\n');

      return transactions;
    } catch (e) {
      print('Error getting all transactions: $e');
      return [];
    }
  }

  // Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(
    TransactionType type,
  ) async {
    try {
      print('=== getTransactionsByType START (type: $type) ===');

      final typeString = type.toString().split('.').last;
      print('Querying for type: $typeString');

      final querySnapshot = await _firestore
          .collection(_transactionsCollection)
          .where('type', isEqualTo: typeString)
          .get(); // REMOVED: .orderBy('createdAt', descending: true)

      print('Query returned ${querySnapshot.docs.length} documents');

      final transactions = <TransactionModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          final transaction = TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          transactions.add(transaction);
          print('✓ Parsed: ${transaction.title}');
        } catch (e) {
          print('✗ Error parsing transaction: $e');
          continue;
        }
      }

      // SORT IN CODE INSTEAD (faster than Firebase for small/medium datasets)
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('Sorted ${transactions.length} transactions');
      print('=== getTransactionsByType END ===\n');

      return transactions;
    } catch (e) {
      print('ERROR in getTransactionsByType: $e');
      return [];
    }
  }

  // Get daily profit data
  Future<List<({DateTime date, double profit})>> getDailyProfitData(
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final transactions = await _firestore
          .collection(_transactionsCollection)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .orderBy('createdAt')
          .get();

      // Group by date
      Map<DateTime, double> dailyProfits = {};

      for (final doc in transactions.docs) {
        try {
          final transaction = TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
          final dateKey = DateTime(
            transaction.createdAt.year,
            transaction.createdAt.month,
            transaction.createdAt.day,
          );

          if (!dailyProfits.containsKey(dateKey)) {
            dailyProfits[dateKey] = 0;
          }

          // Add or subtract based on type
          if (transaction.type == TransactionType.sale ||
              transaction.type == TransactionType.debt) {
            dailyProfits[dateKey] = dailyProfits[dateKey]! + transaction.amount;
          } else if (transaction.type == TransactionType.expense ||
              transaction.type == TransactionType.salary) {
            dailyProfits[dateKey] = dailyProfits[dateKey]! - transaction.amount;
          }
        } catch (e) {
          print('Error processing transaction in getDailyProfitData: $e');
          continue;
        }
      }

      // Create list with all dates in range
      List<({DateTime date, double profit})> result = [];
      for (int i = days - 1; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        final profit = dailyProfits[date] ?? 0.0;
        result.add((date: date, profit: profit));
      }

      return result;
    } catch (e) {
      print('Error getting daily profit data: $e');
      return [];
    }
  }

  // Replace all calculation methods with enhanced debugging:

  Future<double> calculateRevenueForPeriod(int days) async {
    try {
      print('=== calculateRevenueForPeriod START (days: $days) ===');
      print('User ID: $_userId');
      print('Collection path: $_transactionsCollection');

      final sales = await getTransactionsByType(TransactionType.sale);
      print('Total sales fetched: ${sales.length}');
      for (var sale in sales) {
        print('  Sale: ${sale.title} - ₵${sale.amount} on ${sale.createdAt}');
      }

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      print('Period: $startDate to $now');

      final filteredSales = sales.where((s) {
        final isInPeriod = s.createdAt.isAfter(startDate);
        print('  Checking ${s.title}: ${s.createdAt} - InPeriod: $isInPeriod');
        return isInPeriod;
      }).toList();

      final total = filteredSales.fold<double>(0.0, (sum, t) => sum + t.amount);

      print('Filtered sales: ${filteredSales.length}');
      print('Total Revenue: ₵$total');
      print('=== calculateRevenueForPeriod END ===\n');

      return total;
    } catch (e) {
      print('ERROR in calculateRevenueForPeriod: $e');
      return 0.0;
    }
  }

  Future<double> calculateExpensesForPeriod(int days) async {
    try {
      print('=== calculateExpensesForPeriod START (days: $days) ===');

      final expenses = await getTransactionsByType(TransactionType.expense);
      print('Total expenses fetched: ${expenses.length}');
      for (var expense in expenses) {
        print(
          '  Expense: ${expense.title} - ₵${expense.amount} on ${expense.createdAt}',
        );
      }

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      print('Period: $startDate to $now');

      final filteredExpenses = expenses.where((e) {
        final isInPeriod = e.createdAt.isAfter(startDate);
        print('  Checking ${e.title}: ${e.createdAt} - InPeriod: $isInPeriod');
        return isInPeriod;
      }).toList();

      final total = filteredExpenses.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      print('Filtered expenses: ${filteredExpenses.length}');
      print('Total Expenses: ₵$total');
      print('=== calculateExpensesForPeriod END ===\n');

      return total;
    } catch (e) {
      print('ERROR in calculateExpensesForPeriod: $e');
      return 0.0;
    }
  }

  Future<double> _calculateSalariesForPeriod(int days) async {
    try {
      print('=== _calculateSalariesForPeriod START (days: $days) ===');

      final salaries = await getTransactionsByType(TransactionType.salary);
      print('Total salaries fetched: ${salaries.length}');
      for (var salary in salaries) {
        print(
          '  Salary: ${salary.title} - ₵${salary.amount} on ${salary.createdAt}',
        );
      }

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final filteredSalaries = salaries
          .where((s) => s.createdAt.isAfter(startDate))
          .toList();

      final total = filteredSalaries.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      print('Filtered salaries: ${filteredSalaries.length}');
      print('Total Salaries: ₵$total');
      print('=== _calculateSalariesForPeriod END ===\n');

      return total;
    } catch (e) {
      print('ERROR in _calculateSalariesForPeriod: $e');
      return 0.0;
    }
  }

  Future<double> calculateProfitForPeriod(int days) async {
    try {
      print('=== calculateProfitForPeriod START (days: $days) ===');

      final revenue = await calculateRevenueForPeriod(days);
      final expenses = await calculateExpensesForPeriod(days);
      final salaries = await _calculateSalariesForPeriod(days);

      final profit = revenue - expenses - salaries;

      print('Profit Calculation:');
      print('  Revenue: ₵$revenue');
      print('  Expenses: ₵$expenses');
      print('  Salaries: ₵$salaries');
      print('  Profit: ₵$profit');
      print('=== calculateProfitForPeriod END ===\n');

      return profit;
    } catch (e) {
      print('ERROR in calculateProfitForPeriod: $e');
      return 0.0;
    }
  }

  // Calculate total debt
  Future<double> calculateTotalDebt() async {
    try {
      print('=== calculateTotalDebt START ===');
      print('User ID: $_userId');
      print('Collection path: $_transactionsCollection');

      final debts = await getTransactionsByType(TransactionType.debt);
      print('Total debts fetched: ${debts.length}');
      for (var debt in debts) {
        print('  Debt: ${debt.debtorName ?? debt.title} - ₵${debt.amount}');
      }

      final total = debts.fold<double>(0.0, (sum, t) => sum + t.amount);

      print('Total Debt: ₵$total');
      print('=== calculateTotalDebt END ===\n');

      return total;
    } catch (e) {
      print('ERROR in calculateTotalDebt: $e');
      return 0.0;
    }
  }

  // Count total sales
  Future<int> countTotalSales() async {
    try {
      print('=== countTotalSales START ===');

      final transactions = await getTransactionsByType(TransactionType.sale);
      print('Total Sales Count: ${transactions.length}');

      print('=== countTotalSales END ===\n');

      return transactions.length;
    } catch (e) {
      print('ERROR in countTotalSales: $e');
      return 0;
    }
  }

  // Add transaction
  Future<void> addTransaction({
    required String title,
    required String subtitle,
    required double amount,
    required TransactionType type,
    String? category,
    String? description,
    String? paymentMethod,
    DateTime? dueDate,
    String? debtorName,
  }) async {
    try {
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        title: title,
        subtitle: subtitle,
        amount: amount,
        type: type,
        category: category,
        description: description,
        paymentMethod: paymentMethod,
        dueDate: dueDate,
        debtorName: debtorName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_transactionsCollection)
          .doc(transaction.id)
          .set(transaction.toMap());

      print('Transaction added: ${transaction.id}');
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Update transaction
  Future<void> updateTransaction(
    String transactionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .update({...updates, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .delete();

      print('Transaction deleted: $transactionId');
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Add sample data (call this on first launch)
  Future<void> addSampleData() async {
    try {
      // Check if data already exists
      final existing = await getAllTransactions();
      if (existing.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      final now = DateTime.now();
      final sampleTransactions = [
        // Sales
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Product Sale',
          subtitle: 'Electronics',
          amount: 1250.0,
          type: TransactionType.sale,
          category: 'Electronics',
          description: 'Laptop sale',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Service Revenue',
          subtitle: 'Consulting',
          amount: 800.0,
          type: TransactionType.sale,
          category: 'Services',
          description: 'Consultation hours',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
        ),
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Online Sale',
          subtitle: 'E-commerce',
          amount: 450.0,
          type: TransactionType.sale,
          category: 'Online',
          description: 'Website order',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        // Expenses
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Office Rent',
          subtitle: 'Monthly rent',
          amount: 500.0,
          type: TransactionType.expense,
          category: 'Rent',
          description: 'Office space',
          createdAt: now.subtract(const Duration(days: 6)),
          updatedAt: now.subtract(const Duration(days: 6)),
        ),
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Utilities',
          subtitle: 'Electricity & Water',
          amount: 120.0,
          type: TransactionType.expense,
          category: 'Utilities',
          description: 'Monthly utilities',
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now.subtract(const Duration(days: 4)),
        ),
        // Salaries
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Employee Salary',
          subtitle: 'John Doe',
          amount: 600.0,
          type: TransactionType.salary,
          category: 'Payroll',
          description: 'Monthly salary',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        // Debts
        TransactionModel(
          id: const Uuid().v4(),
          title: 'Debt - Client Payment',
          subtitle: 'ABC Company',
          amount: 300.0,
          type: TransactionType.debt,
          category: 'Receivables',
          description: 'Invoice pending',
          dueDate: now.add(const Duration(days: 7)),
          debtorName: 'ABC Company',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
      ];

      for (final transaction in sampleTransactions) {
        await _firestore
            .collection(_transactionsCollection)
            .doc(transaction.id)
            .set(transaction.toMap());
      }

      print('Sample data added successfully');
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }
}
