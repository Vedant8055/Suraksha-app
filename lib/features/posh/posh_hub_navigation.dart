import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/core/navigation/app_navigator.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_certificate_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_complaint_prep_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_education_screen.dart';
import 'package:suraksha_women_safety_app/features/posh/posh_quiz_screen.dart';

/// POSH hub destinations — keeps navigation out of the portal screen body.
class PoshHubNavigation {
  PoshHubNavigation._();

  static Future<void> openEducation(BuildContext context) =>
      AppNavigator.pushPremium(context, const POSHEducationScreen());

  static Future<void> openQuiz(BuildContext context) =>
      AppNavigator.pushPremium(context, const POSHQuizScreen());

  static Future<void> openComplaintPrep(BuildContext context) =>
      AppNavigator.pushPremium(context, const POSHComplaintPrepScreen());

  static Future<void> openCertificate(BuildContext context) =>
      AppNavigator.pushPremium(context, const POSHCertificateScreen());
}
