class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final double salary;
  final String position;
  final DateTime hireDate;
  final String? phone;
  final String? address;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.salary,
    required this.position,
    required this.hireDate,
    this.phone,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'salary': salary,
      'position': position,
      'hireDate': hireDate.toIso8601String(),
      'phone': phone,
      'address': address,
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      salary: (map['salary'] ?? 0).toDouble(),
      position: map['position'] ?? '',
      hireDate: map['hireDate'] != null
          ? DateTime.parse(map['hireDate'])
          : DateTime.now(),
      phone: map['phone'],
      address: map['address'],
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    double? salary,
    String? position,
    DateTime? hireDate,
    String? phone,
    String? address,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      salary: salary ?? this.salary,
      position: position ?? this.position,
      hireDate: hireDate ?? this.hireDate,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
