import '../../features/auth/data/models/auth_model.dart';

/// Pure redirect rules (unit-tested). No Flutter, no cubit.
///
/// [resolved]: the stored session has been checked at least once.
/// [user]: signed-in user, or null.
/// [location]: the location being navigated to.
String? resolveRedirect({
  required bool resolved,
  required AuthModel? user,
  required String location,
}) {
  const splash = '/';
  const login = '/login';
  const otp = '/otp';
  const register = '/register';

  if (!resolved) return location == splash ? null : splash;

  if (user == null) {
    return (location == login ||
            location == otp ||
            location == register)
        ? null
        : login;
  }

  final home = homeFor(user);
  if (location == splash || location == login || location == otp) return home;

  if (user.isDriver) {
    if (!location.startsWith('/driver')) return home;
    final approved = user.driverStatus == VerificationStatus.approved;
    final inVerification = location.startsWith('/driver/onboarding') ||
        location.startsWith('/driver/status');
    if (!approved && !inVerification) return home;
    if (approved && inVerification) return home;
    // Rejected/pending drivers must not reopen the wizard.
    if (location.startsWith('/driver/onboarding') &&
        user.driverStatus != VerificationStatus.none &&
        user.driverStatus != VerificationStatus.draft) {
      return home;
    }
    return null;
  }

  // Passenger
  if (location.startsWith('/driver')) return home;
  if (!user.profileComplete && location != register) return register;
  if (user.profileComplete && location == register) return home;
  return null;
}

/// Where a signed-in user belongs right now.
String homeFor(AuthModel user) {
  if (user.isDriver) {
    switch (user.driverStatus) {
      case VerificationStatus.approved:
        return '/driver/dashboard';
      case VerificationStatus.none:
      case VerificationStatus.draft:
        return '/driver/onboarding';
      case VerificationStatus.pending:
      case VerificationStatus.rejected:
      case VerificationStatus.suspended:
        return '/driver/status';
    }
  }
  return user.profileComplete ? '/passenger/home' : '/register';
}
