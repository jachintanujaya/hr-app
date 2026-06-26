import '../../../../core/permissions/user_role.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    required super.role,
    super.managerId,
    super.managerName,
    super.department,
    super.jobTitle,
    super.hireDate,
    super.status = EmploymentStatus.active,
    super.avatarUrl,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String),
      managerId: json['manager_id'] as String?,
      managerName: json['manager_name'] as String?,
      department: json['department'] as String?,
      jobTitle: json['job_title'] as String?,
      hireDate: json['hire_date'] != null ? DateTime.tryParse(json['hire_date'] as String) : null,
      status: _statusFromString(json['status'] as String? ?? 'active'),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'manager_id': managerId,
      'department': department,
      'job_title': jobTitle,
      'hire_date': hireDate?.toIso8601String(),
      'status': status.name,
      'avatar_url': avatarUrl,
    };
  }

  static EmploymentStatus _statusFromString(String value) {
    return EmploymentStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == value.toLowerCase(),
      orElse: () => EmploymentStatus.active,
    );
  }

  factory EmployeeModel.fromEntity(EmployeeEntity e) {
    return EmployeeModel(
      id: e.id,
      fullName: e.fullName,
      email: e.email,
      phone: e.phone,
      role: e.role,
      managerId: e.managerId,
      managerName: e.managerName,
      department: e.department,
      jobTitle: e.jobTitle,
      hireDate: e.hireDate,
      status: e.status,
      avatarUrl: e.avatarUrl,
    );
  }
}
