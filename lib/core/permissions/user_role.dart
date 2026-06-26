/// The 3 roles in the system.
/// employee  -> regular staff
/// admin     -> manager of a team of employees
/// superAdmin-> HR, full org-wide control
enum UserRole {
  employee,
  admin,
  superAdmin;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }
}
