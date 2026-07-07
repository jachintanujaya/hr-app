class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';

  static const attendance = '/attendance';
  static const teamAttendance = '/attendance/team';

  static const timeOff = '/time-off';
  static const timeOffApprovals = '/time-off/approvals';
  static const timeOffPolicies = '/time-off/policies';

  static const profile = '/profile';
  static const teamMembers = '/employees/team';
  static const allEmployees = '/employees/all';

  static const workingHoursSettings = '/attendance/working-hours-settings';
  static const settings = '/settings';
  static const workingHoursPolicies = '/settings/working-hours-policies';
  static const workingHoursPolicyAssign = '/settings/working-hours-policies/:policyId/assign';
}
