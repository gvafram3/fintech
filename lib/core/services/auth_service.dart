import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  String get currentUserId => _auth.currentUser?.uid ?? '';

  /// Sign up user and save role
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('Starting signup for: $email');

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        throw Exception('Failed to create user');
      }

      print('User created with ID: $userId');

      return {
        'success': true,
        'userId': userId,
        'message': 'Signup successful',
      };
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      print('Signup error: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Update user role in Firestore
  Future<void> updateUserRole({
    required String userId,
    required String role,
    required String fullName,
    String? email,
  }) async {
    try {
      print('Updating role for user: $userId');

      await _firestore.collection('users').doc(userId).set({
        'fullName': fullName,
        'email': email ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));

      print('User role updated to: $role');
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  /// Get user role from Firestore (current user or specific user)
  Future<String?> getUserRole({String? userId}) async {
    try {
      final id = userId ?? currentUserId;

      if (id.isEmpty) {
        print('No user ID available');
        return null;
      }

      final doc = await _firestore.collection('users').doc(id).get();

      return doc.data()?['role'] as String?;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (currentUserId.isEmpty) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();

      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Get current user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUserId.isEmpty) return null;

      final doc = await _firestore.collection('users').doc(currentUserId).get();

      if (!doc.exists) return null;

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Logging in user: $email');

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      print('Login successful');

      return {'success': true, 'message': 'Login successful'};
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Sign in user
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Signing in user: $email');

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      print('Sign in successful');

      return {'success': true, 'message': 'Sign in successful'};
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      print('Sign in error: $e');
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Forgot password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication error: $code';
    }
  }
}
