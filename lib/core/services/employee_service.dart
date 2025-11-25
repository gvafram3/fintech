import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  String get _employeesCollection => 'users/$_userId/employees';

  // Add employee
  Future<void> addEmployee(EmployeeModel employee) async {
    try {
      await _firestore
          .collection(_employeesCollection)
          .doc(employee.id)
          .set(employee.toMap());
    } catch (e) {
      print('Error adding employee: $e');
      rethrow;
    }
  }

  // Get all employees
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      final querySnapshot = await _firestore
          .collection(_employeesCollection)
          .get();
      return querySnapshot.docs
          .map(
            (doc) => EmployeeModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
    } catch (e) {
      print('Error getting employees: $e');
      return [];
    }
  }

  // Get employee by ID
  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      final doc = await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .get();
      if (doc.exists) {
        return EmployeeModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting employee: $e');
      return null;
    }
  }

  // Update employee
  Future<void> updateEmployee(String employeeId, EmployeeModel employee) async {
    try {
      await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .update(employee.toMap());
    } catch (e) {
      print('Error updating employee: $e');
      rethrow;
    }
  }

  // Delete employee
  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore
          .collection(_employeesCollection)
          .doc(employeeId)
          .delete();
    } catch (e) {
      print('Error deleting employee: $e');
      rethrow;
    }
  }

  // Get employees stream (for real-time updates)
  Stream<List<EmployeeModel>> getEmployeesStream() {
    try {
      return _firestore.collection(_employeesCollection).snapshots().map((
        snapshot,
      ) {
        final employees = snapshot.docs
            .map(
              (doc) =>
                  EmployeeModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();
        employees.sort((a, b) => a.name.compareTo(b.name));
        return employees;
      });
    } catch (e) {
      print('Error getting employees stream: $e');
      return Stream.value([]);
    }
  }

  // Count total employees
  Future<int> countTotalEmployees() async {
    try {
      final querySnapshot = await _firestore
          .collection(_employeesCollection)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error counting employees: $e');
      return 0;
    }
  }
}
