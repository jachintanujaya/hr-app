import 'package:equatable/equatable.dart';
import '../../../../core/permissions/user_role.dart';

enum EmploymentStatus { active, onLeave, suspended, terminated }

class EmployeeEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final UserRole role;
  final String? managerId;
  final String? managerName;
  final String? department;
  final String? jobTitle;
  final DateTime? hireDate;
  final EmploymentStatus status;
  final String? avatarUrl;

  const EmployeeEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.managerId,
    this.managerName,
    this.department,
    this.jobTitle,
    this.hireDate,
    this.status = EmploymentStatus.active,
    this.avatarUrl,
  });

  EmployeeEntity copyWith({
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? managerId,
    String? managerName,
    String? department,
    String? jobTitle,
    DateTime? hireDate,
    EmploymentStatus? status,
    String? avatarUrl,
  }) {
    return EmployeeEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      hireDate: hireDate ?? this.hireDate,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        role,
        managerId,
        managerName,
        department,
        jobTitle,
        hireDate,
        status,
        avatarUrl,
      ];
}
