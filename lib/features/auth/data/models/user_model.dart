import '../../../../core/permissions/user_role.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.managerId,
    super.department,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      managerId: json['manager_id'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role.name,
      'manager_id': managerId,
      'department': department,
      'avatar_url': avatarUrl,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      role: entity.role,
      managerId: entity.managerId,
      department: entity.department,
      avatarUrl: entity.avatarUrl,
    );
  }
}
