import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final String? category;
  final String? description;
  final String? paymentMethod;
  final DateTime? dueDate;
  final String? debtorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    this.category,
    this.description,
    this.paymentMethod,
    this.dueDate,
    this.debtorName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'dueDate': dueDate,
      'debtorName': debtorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    try {
      // Helper function to parse DateTime from various formats
      DateTime _parseDateTime(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is DateTime) {
          return value;
        } else if (value is String) {
          return DateTime.parse(value);
        }
        return DateTime.now();
      }

      return TransactionModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        subtitle: map['subtitle'] ?? '',
        amount: (map['amount'] ?? 0).toDouble(),
        type: _parseTransactionType(map['type']),
        category: map['category'],
        description: map['description'],
        paymentMethod: map['paymentMethod'],
        dueDate: map['dueDate'] != null ? _parseDateTime(map['dueDate']) : null,
        debtorName: map['debtorName'],
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
      );
    } catch (e) {
      print('Error parsing TransactionModel: $e, Map: $map');
      return TransactionModel(
        id: map['id'] ?? '',
        title: map['title'] ?? 'Unknown',
        subtitle: map['subtitle'] ?? '',
        amount: 0,
        type: TransactionType.sale,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  static TransactionType _parseTransactionType(dynamic type) {
    if (type == null) return TransactionType.sale;

    final typeString = type.toString().toLowerCase();

    switch (typeString) {
      case 'sale':
      case 'transactiontype.sale':
        return TransactionType.sale;
      case 'expense':
      case 'transactiontype.expense':
        return TransactionType.expense;
      case 'salary':
      case 'transactiontype.salary':
        return TransactionType.salary;
      case 'debt':
      case 'transactiontype.debt':
        return TransactionType.debt;
      default:
        return TransactionType.sale;
    }
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    String? paymentMethod,
    DateTime? dueDate,
    String? debtorName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      dueDate: dueDate ?? this.dueDate,
      debtorName: debtorName ?? this.debtorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum TransactionType { sale, expense, salary, debt }
