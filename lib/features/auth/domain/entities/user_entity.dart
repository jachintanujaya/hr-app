import 'package:equatable/equatable.dart';
import '../../../../core/permissions/user_role.dart';

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? managerId; // who this employee reports to (admin's id)
  final String? department;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.managerId,
    this.department,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, email, role, managerId, department, avatarUrl];
}
