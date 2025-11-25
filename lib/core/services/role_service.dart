import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { owner, manager, accountant }

extension UserRoleExtension on UserRole {
  String get value {
    return toString().split('.').last;
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'manager':
        return UserRole.manager;
      case 'accountant':
        return UserRole.accountant;
      default:
        return UserRole.accountant;
    }
  }
}

class RoleService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  /// Get current user's role
  Future<UserRole> getCurrentUserRole() async {
    try {
      if (_userId.isEmpty) {
        return UserRole.accountant;
      }

      final doc = await _firestore.collection('users').doc(_userId).get();

      final roleString = doc.data()?['role'] as String?;

      if (roleString == null) {
        return UserRole.accountant;
      }

      return UserRoleExtension.fromString(roleString);
    } catch (e) {
      print('Error getting user role: $e');
      return UserRole.accountant;
    }
  }

  /// Check if user has specific permission
  bool hasPermission(UserRole role, String permission) {
    final permissions = _getRolePermissions(role);
    return permissions.contains(permission);
  }

  /// Get all permissions for a role
  Set<String> _getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return {
          'view_all_data',
          'manage_users',
          'edit_transactions',
          'delete_transactions',
          'view_reports',
          'access_settings',
          'export_data',
          'view_analytics',
          'manage_managers',
          'manage_accountants',
        };
      case UserRole.manager:
        return {
          'view_team_data',
          'create_transactions',
          'edit_own_transactions',
          'delete_own_transactions',
          'view_team_reports',
          'export_team_data',
        };
      case UserRole.accountant:
        return {
          'view_transactions',
          'view_reports',
          'export_data',
          'reconcile_accounts',
        };
    }
  }

  /// Get role display name
  String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.accountant:
        return 'Account Officer';
    }
  }

  /// Get role description
  String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Full access to all features';
      case UserRole.manager:
        return 'Manage team and transactions';
      case UserRole.accountant:
        return 'View and manage accounting records';
    }
  }

  /// Get role icon
  IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return Icons.business_center;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.accountant:
        return Icons.account_balance;
    }
  }

  /// Get all managers (Owner only)
  Future<List<Map<String, dynamic>>> getAllManagers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'manager')
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...?doc.data()})
          .toList();
    } catch (e) {
      print('Error getting managers: $e');
      return [];
    }
  }

  /// Get all accountants (Owner only)
  Future<List<Map<String, dynamic>>> getAllAccountants() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'accountant')
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...?doc.data()})
          .toList();
    } catch (e) {
      print('Error getting accountants: $e');
      return [];
    }
  }

  /// Deactivate user (Owner only)
  Future<void> deactivateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User deactivated: $userId');
    } catch (e) {
      print('Error deactivating user: $e');
      rethrow;
    }
  }

  /// Activate user (Owner only)
  Future<void> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User activated: $userId');
    } catch (e) {
      print('Error activating user: $e');
      rethrow;
    }
  }

  /// Update user role (Owner only)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User role updated: $userId -> $newRole');
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  /// Delete user (Owner only)
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(userId).delete();

      print('User deleted: $userId');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
