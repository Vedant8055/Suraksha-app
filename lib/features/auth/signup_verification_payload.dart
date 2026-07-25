/// Carries verified email signup data from step 1 to step 2.
class SignupVerificationPayload {
  const SignupVerificationPayload({
    required this.fullName,
    required this.phone,
    required this.phoneDisplay,
    required this.email,
    required this.emailVerificationToken,
  });

  final String fullName;
  final String phone;
  final String phoneDisplay;
  final String email;
  final String emailVerificationToken;
}
