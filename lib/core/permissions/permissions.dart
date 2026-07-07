import 'user_role.dart';

/// Centralized permission rules, derived from role.
/// Keep ALL "who can do what" logic here instead of scattering
/// `if (role == admin)` checks across the UI/bloc layers.
class Permissions {
  final UserRole role;

  const Permissions(this.role);

  // ---- Attendance ----
  bool get canClockInOut => true; // everyone clocks in/out for themselves
  bool get canViewTeamAttendance => role == UserRole.admin || role == UserRole.superAdmin;
  bool get canEditAttendanceRecords => role == UserRole.admin || role == UserRole.superAdmin;
  bool get canViewCompanyWideAttendanceReports => role == UserRole.superAdmin;

  // ---- Time off ----
  bool get canRequestTimeOff => true;
  bool get canApproveTeamTimeOff => role == UserRole.admin || role == UserRole.superAdmin;
  bool get canManageTimeOffPolicies => role == UserRole.superAdmin;

  // ---- Employee management ----
  bool get canViewOwnProfile => true;
  bool get canManageTeamMembers => role == UserRole.admin || role == UserRole.superAdmin;
  bool get canCreateOrDeleteEmployees => role == UserRole.superAdmin;
  bool get canManageOrgStructure => role == UserRole.superAdmin;
  bool get canAssignRoles => role == UserRole.superAdmin;

  // ---- Dashboard ----
  bool get seesTeamDashboard => role == UserRole.admin || role == UserRole.superAdmin;
  bool get seesCompanyDashboard => role == UserRole.superAdmin;

  bool get canManageWorkingHoursSettings => role == UserRole.superAdmin;

  bool get canAccessSettingsMenu => canManageTimeOffPolicies || canManageWorkingHoursSettings;
}
