import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  /// Loads the saved app language (for providers / notifications without BuildContext).
  static Future<AppLocalizations> current() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale_v1') ?? 'en';
    final normalized = code.toLowerCase().split(RegExp(r'[_-]')).first;
    final lang = (normalized == 'hi' || normalized == 'mr') ? normalized : 'en';
    return AppLocalizations(Locale(lang));
  }

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('mr')];

  static String _languageCodeFor(Locale locale) {
    final normalizedCode = locale.languageCode.toLowerCase();
    return supportedLocales.any((item) => item.languageCode == normalizedCode)
        ? normalizedCode
        : 'en';
  }

  static final Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'Suraksha',
      'greetingHello': 'Hello',
      'welcomeBack': 'Welcome Back',
      'signInToContinue': 'Sign in to continue your safety journey',
      'emailOrPhone': 'Email or Phone Number',
      'password': 'Password',
      'login': 'LOGIN',
      'createAccount': 'Create Account',
      'signUpToContinue': 'Sign up to start your safety journey',
      'signUpStep1of2': 'Step 1 of 2',
      'signUpStep2of2': 'Step 2 of 2',
      'signUpVerifyPhone': 'Verify your email',
      'signUpVerifyPhoneSubtitle':
          'Enter your name, email, and mobile number. We will send a one-time code to your email.',
      'signUpVerifyEmail': 'Verify your email',
      'signUpVerifyEmailSubtitle':
          'Enter your name, email, and mobile number. Tap SEND OTP, then enter the 6-digit code from your email below.',
      'signUpCompleteProfile': 'Complete your profile',
      'signUpCompleteProfileSubtitle':
          'Set a password to finish creating your account.',
      'continueToAccountDetails': 'CONTINUE',
      'fullName': 'Full Name',
      'fullNameRequired': 'Please enter your full name.',
      'phoneNumber': 'Phone Number',
      'phoneNumberInvalid': 'Enter a valid 10-digit mobile number.',
      'emailOptional': 'Email',
      'emailInvalid': 'Enter a valid email address.',
      'confirmPassword': 'Confirm Password',
      'signUp': 'SIGN UP',
      'alreadyHaveAccount': 'Already have an account? Sign in',
      'dontHaveAccount': "Don't have an account? Sign up",
      'passwordsDoNotMatch': 'Passwords do not match.',
      'forgotPassword': 'Forgot password?',
      'forgotPasswordTitle': 'Reset password',
      'forgotPasswordSubtitle':
          'Enter your registered email to receive a 6-digit OTP. Accounts without an email cannot reset here — add an email while signed in, or contact support.',
      'sendOtp': 'SEND OTP',
      'resendOtp': 'RESEND OTP',
      'resendOtpIn': 'Resend OTP in {seconds}s',
      'enterOtp': '6-digit OTP',
      'otpEnterHint':
          'Enter the 6-digit code from your email. If you already received it, type it here and continue.',
      'verifyOtp': 'VERIFY OTP',
      'otpSent': 'OTP sent to your email. Enter it below.',
      'otpSendFailed': 'Could not send OTP. Check your details and try again.',
      'otpSendCheckInbox':
          'If an email arrived with a code, enter it below. If not, wait a moment and tap Resend.',
      'otpInvalid': 'Enter the 6-digit OTP.',
      'phoneVerified': 'Email verified.',
      'verifyPhoneFirst': 'Verify your email with OTP before continuing.',
      'verifyEmailFirst': 'Verify your email with OTP before signing up.',
      'newPassword': 'New password',
      'resetPassword': 'RESET PASSWORD',
      'passwordResetSuccess': 'Password updated. You are signed in.',
      'authSessionExpired': 'Your session expired. Please sign in again.',
      'emergencyContactsInformed': 'Emergency Contacts Informed',
      'liveLocationSharedWith': 'Live location has been shared with:',
      'fetchingLocation': 'Fetching location...',
      'liveFeedActive': 'Live Feed Active ({time})',
      'startingLiveTransmission': 'Starting live transmission...',
      'liveTransmissionPaused': 'Live transmission paused',
      'emergencyModeActive': 'EMERGENCY MODE ACTIVE',
      'helpOnTheWay': 'Help is on the way. Your live location is being shared.',
      'currentLocation': 'Current Location',
      'status': 'Status',
      'iAmSafeCancelSos': 'I AM SAFE - CANCEL SOS',
      'myProfile': 'My Profile',
      'profileSubtitle':
          'Manage your safety identity, language, and emergency readiness.',
      'profileOverview': 'Profile Overview',
      'profileStatsTitle': 'Your safety snapshot',
      'profileHeroCta':
          'Personalize your profile for faster emergency support.',
      'languageSelectionTitle': 'Choose app language',
      'darkMode': 'Dark Mode',
      'darkModeSubtitleOn': 'Dark Bluish Theme',
      'darkModeSubtitleOff': 'Soft Calm Light Theme',
      'language': 'Language',
      'contentLanguage': 'Content language for the app',
      'english': 'English',
      'hindi': 'Hindi',
      'marathi': 'Marathi',
      'editProfile': 'Edit Profile',
      'editPhoneNumber': 'Edit Phone Number',
      'addEmergencyContactTitle': 'Add Emergency Contact',
      'editEmergencyContactTitle': 'Edit Emergency Contact',
      'editProfileDetails': 'EDIT PROFILE DETAILS',
      'editMedicalProfile': 'EDIT MEDICAL PROFILE',
      'email': 'Email',
      'phone': 'Phone Number',
      'relation': 'Relation',
      'name': 'Name',
      'bloodGroup': 'Blood Group',
      'bloodGroupSelect': 'Select blood group',
      'allergies': 'Allergies',
      'medicalConditions': 'Medical Conditions',
      'currentMedications': 'Current Medications',
      'notProvided': 'Not provided',
      'emergencyContacts': 'Emergency Contacts',
      'contactsSaved': 'Contacts Saved',
      'emergencyContactList': 'Emergency Contact List',
      'activityLogsTitle': 'Logs',
      'activityLogsTileValue': 'Encrypted activity history (7 days)',
      'activityLogsSubtitle':
          'Read-only, encrypted records of app activity. Older than 7 days are deleted. Passwords and OTPs are never stored.',
      'activityLogsFrom': 'From',
      'activityLogsTo': 'To',
      'activityLogsLast24h': 'Last 24 hours',
      'activityLogsYesterday': 'Yesterday',
      'activityLogsExport': 'Export .txt',
      'activityLogsEmpty': 'No logs in this time range.',
      'activityLogsLoadFailed': 'Could not load logs.',
      'activityLogsUnlockReason': 'Unlock to view Suraksha activity logs.',
      'activityLogsExportUnlock': 'Unlock to export activity logs.',
      'activityLogsUnlockCancelled':
          'Unlock your phone to open Logs.',
      'activityLogsUnlockAction': 'Unlock',
      'activityLogsLockMissing':
          'Set a screen lock on your phone to open Logs.',
      'activityLogsTampered': 'This line failed integrity checks.',
      'activityLogsEncryptedBadge': 'Encrypted',
      'activityLogsRetentionBadge': '7-day vault',
      'activityLogsEventCount': '{count} events',
      'activityLogsUnlockTitle': 'Protected activity vault',
      'activityLogsEmptyHint': 'Try a wider time range or wait for new activity.',
      'addEmergencyContact': 'Add emergency contact',
      'addNewContact': 'Add new contact',
      'logoutSession': 'LOGOUT SESSION',
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'done': 'Done',
      'saving': 'Saving...',
      'saved': 'Saved',
      'screamDetection': 'Scream Detection',
      'screamDetectionEnabled': 'Scream detection enabled.',
      'screamDetectionDisabled': 'Scream detection disabled.',
      'screamDetectionEnableFailed': 'Could not enable scream detection.',
      'distressSensitivity': 'Detection sensitivity',
      'distressSensitivitySubtitle':
          'High catches quieter screams; low reduces false alarms.',
      'distressSensitivity_low': 'Low',
      'distressSensitivity_medium': 'Medium',
      'distressSensitivity_high': 'High',
      'distressTestMode': 'Test mode (no SOS)',
      'distressTestModeSubtitle':
          'Detect screams and phrases but never send SOS. Use to verify accuracy.',
      'distressLastHeard': 'Last heard',
      'microphoneSafetyMonitorActive': 'Microphone safety monitor is active.',
      'microphoneSafetyMonitorInactive':
          'Microphone stays off while this is disabled.',
      'impactDetection': 'Impact Detection',
      'impactDetectionEnabled': 'Impact detection enabled.',
      'impactDetectionDisabled': 'Impact detection disabled.',
      'impactDetectionEnableFailed': 'Could not enable impact detection.',
      'motionSensorsActive': 'Motion sensors are watching for sudden impact.',
      'motionSensorsInactive':
          'Motion sensors stay off while this is disabled.',
      'phoneNumberRequired': 'Phone number is required.',
      'nameAndPhoneRequired': 'Name and phone number are required.',
      'duplicatePhoneNumberTitle': 'Number already saved',
      'duplicatePhoneNumber': 'This number is already saved.',
      'savedLocallyRetryLater': 'Saved locally. Server sync will retry later.',
      'photoSavedLocally': 'Photo saved locally.',
      'profilePhotoUnlockReason':
          'Unlock your phone to change your profile photo.',
      'profilePhotoUnlockCancelled':
          'Unlock your phone with PIN, password, fingerprint, or face before opening the gallery.',
      'profilePhotoDeviceLockMissing':
          'Set a screen lock (PIN, password, fingerprint, or face) on your phone first. Suraksha does not create a separate PIN for this.',
      'profilePhotoCropTitle': 'Crop photo',
      'profilePhotoCropHint':
          'Pinch to zoom and drag to choose the area for your profile photo.',
      'profilePhotoCropFailed': 'Could not crop this photo. Try another image.',
      'serverSyncWillRetryLater': 'Server sync will retry later.',
      'profileSavedTitle': 'Profile saved',
      'profileSavedMessage': 'Your information is now stored and ready to use.',
      'medicalSavedTitle': 'Medical profile saved',
      'medicalSavedMessage':
          'Your medical details have been updated successfully.',
      'contactSavedTitle': 'Contact saved',
      'contactSavedMessage':
          'Emergency contact details were updated successfully.',
      'draftSavedTitle': 'Draft saved',
      'draftSavedMessage': 'Your draft has been stored locally on this device.',
      'emergencyServices': 'Emergency Services',
      'communityAlerts': 'Community Alerts',
      'safetyRegionLabel': 'Region',
      'safetyDataDisclaimerTitle': 'Data sources',
      'safetyConfidenceSuffix': 'confidence',
      'safetySourceOpenStreetMap': 'OpenStreetMap',
      'safetySourceSunset': 'Sunset API',
      'safetySourceCrowd': 'Anonymous crowd',
      'safetySourceSurakshaReports': 'Suraksha reports',
      'safetySourceSurakshaEngine': 'Suraksha engine',
      'safetySourceSurakshaCommunity': 'Community verified',
      'safetySourceRegionalGuidance': 'Regional guidance',
      'safetyDimCrime': 'Crime',
      'safetyDimInfrastructure': 'Lighting',
      'safetyDimSupport': 'Support',
      'safetyDimVisibility': 'Visibility',
      'safetyDimTemporal': 'Time',
      'safetySourceGridModel': 'Grid model',
      'safetySourceOpenDataDistrict': 'District open data',
      'safetyUpdatedAgo': 'Updated',
      'aiSummaryFromGemini': 'AI summary (Gemini)',
      'aiSummaryFromTemplate': 'AI summary (offline)',
      'journeySafetyAlerts': 'Journey safety alerts',
      'journeySafetyAlertsSubtitle':
          'Push and in-app alerts when entering higher-risk zones during navigation.',
      'notifPrefSos': 'SOS alerts',
      'notifPrefSosSubtitle':
          'Critical SOS and danger-related notifications.',
      'notifPrefRoute': 'Route warnings',
      'notifPrefRouteSubtitle':
          'Daily Route Guard deviation alerts on this device.',
      'notifPrefCommunity': 'Community alerts',
      'notifPrefCommunitySubtitle':
          'Nearby community safety cards and area alerts.',
      'notifPrefReminders': 'Safety reminders',
      'notifPrefRemindersSubtitle':
          'Optional check-in and preparedness reminders.',
      'notifOnboardingTitle': 'Stay reachable in emergencies',
      'notifOnboardingBody':
          'Suraksha uses notifications for time-sensitive safety alerts. You can change categories anytime in Profile.',
      'notifOnboardingBulletSos': 'SOS and critical danger alerts',
      'notifOnboardingBulletRoute': 'Route deviation warnings',
      'notifOnboardingBulletCommunity': 'Community safety alerts nearby',
      'notifOnboardingBulletReminders': 'Optional safety reminders',
      'notifEnableNotifications': 'Enable notifications',
      'notifOpenSettings': 'Open system settings',
      'notifSkipForNow': 'Skip for now',
      'notifPermissionDeniedHint':
          'Permission is off. Open system settings to allow notifications.',
      'pleaseWait': 'Please wait…',
      'notifDeliveryStatusLabel': 'Delivery: {status}',
      'notifExpiredHandled': 'That alert has expired and was dismissed.',
      'notifInboxTitle': 'Safety alerts inbox',
      'notifInboxEmpty': 'No active safety alerts right now.',
      'notifInboxOpenSubtitle': 'View delivery status for critical and recent alerts.',
      'journeyRerouteHint': 'Safer route available',
      'tapForAlerts': 'Tap for alerts',
      'tapRefreshTryAgain': 'Tap refresh to try again',
      'loadingLiveAreaAlerts': 'Loading live area alerts...',
      'checkingTrafficTransportNearbyActivity':
          'Checking traffic, transport and nearby activity',
      'liveAlertsWillAppearHere': 'Live alerts will appear here',
      'keepGpsOnForRealtimeCommunityUpdates':
          'Keep GPS on for realtime community updates',
      'locationRequiredTitle': 'Location required',
      'locationRequiredMessage':
          'Suraksha requires GPS and location permission to work. Please enable them to continue.',
      'locationAutoRefreshMessage':
          'Once location is enabled, services refresh automatically.',
      'retryLocation': 'Retry location setup',
      'womenHelpline': 'Women Helpline',
      'nearbyServices': 'Nearby Services',
      'nearbyHospitals': 'Nearby Hospitals',
      'policeStations': 'Police Stations',
      'nearbyWashrooms': 'Nearby Washrooms',
      'nearbyBloodBanks': 'Nearby Blood Banks',
      'nearbyPharmacies': 'Nearby Pharmacies',
      'nearbyPetrolPumps': 'Nearby Petrol Pumps',
      'tapToLoadNearby': 'Tap a button to load nearby real-time services.',
      'noNearbyPlaces': 'No nearby places found in 5 km radius.',
      'safeZoneActive': 'Prioritizing your Safety',
      'helloKaveri': 'Hello, Kaveri',
      'openSafetyMap': 'Open Safety Map',
      'openSafetyMapConfirm': 'Want to see this location on the map?',
      'mapOpenChoiceTitle': 'Open location',
      'mapOpenChoiceMessage': 'Choose how you want to open this place.',
      'mapOpenChoiceSuraksha': 'Suraksha Map',
      'mapOpenChoiceGoogle': 'Google Maps',
      'yes': 'Yes',
      'no': 'No',
      'couldNotOpenDialer': 'Could not open dialer',
      'policeEmergency': 'Police Emergency',
      'scanningNearbyPlaces': 'Scanning nearby places...',
      'nearbyResultsCount': '{count} nearby results',
      'toiletsNoToiletsInArea': 'No toilets found in this area.',
      'toiletsNoToiletsInAreaHint':
          'No toilets found in this area. Try increasing the search radius or relaxing filters.',
      'toiletsSanitationRegistryEmpty':
          'Sanitation registry returned no published toilets here.',
      'toiletsSanitationRegistryEmptyHint':
          'The toilet service is connected, but no sanitation toilets are published for this location yet. Ask the sanitation admin to publish entries (with GPS coordinates) to the public API for your tenant.',
      'toiletsSanitationMissingCoordinates':
          'Sanitation toilets exist but are missing map coordinates.',
      'toiletsSanitationMissingCoordinatesHint':
          'The sanitation platform returned toilets without valid latitude/longitude, so they cannot be shown on the map. Update those toilet records with GPS coordinates in the sanitation admin panel.',
      'toiletsSanitationClosedPermissionHint':
          'Note: this integration can only fetch open toilets. Closed toilets need either an open status in sanitation or an API key allowed to read closed toilets.',
      'toiletsLocationUnavailable':
          'Location not available. Turn on GPS and allow location permission.',
      'toiletsConnectionError':
          'Could not reach toilet service right now. Please try again.',
      'toiletsRefreshing': 'Refreshing clean and usable public toilets...',
      'toiletsFoundCount': '{count} toilets found with current filters',
      'toiletsOnMapCount': '{count} toilets on the map',
      'toiletsLoadingNearby': 'Loading nearby toilets...',
      'chooseServiceToScanYourArea':
          'Choose a service below to scan your current area.',
      'cyberCrimeProtection': 'Cyber Crime Protection',
      'aiAssist': 'AI Assist',
      'report': 'Report',
      'vault': 'Vault',
      'learn': 'Learn',
      'deepfake': 'Deepfake',
      'aiScamFraudAssistantTitle': 'AI Scam & Fraud Detection Assistant',
      'pasteEvidenceContext':
          'Paste suspicious messages, links, chats or questions. Attach screenshots as evidence context.',
      'suspiciousMessageLabel': 'Suspicious message, email or chat',
      'pasteFullMessageHereHint': 'Paste the full message here...',
      'suspiciousLinksLabel': 'Suspicious links',
      'urlHint': 'https://example.com, bit.ly/...',
      'askQuestionLabel': 'Ask a question',
      'scamQuestionHint': 'Is this a scam? Is this profile fake?',
      'attachScreenshot': 'Attach screenshot',
      'analyze': 'Analyze',
      'selectIncidentType': 'Select incident type',
      'attachScreenshotsOrProof': 'Attach screenshots or transaction proof',
      'incidentDescription': 'Incident description',
      'incidentDetailsHint':
          'Describe what happened, usernames, amounts, threats, and platforms.',
      'suspectContactLabel': 'Phone/email/profile link',
      'suspectContactHint': 'Suspect contact or profile URL',
      'transactionIdLabel': 'Transaction ID',
      'transactionIdHint': 'UPI/ref no. if financial fraud',
      'incidentTime': 'Incident time: {time}',
      'pdfReady': 'PDF ready',
      'newReport': 'New report',
      'saveDraft': 'Save draft',
      'reportGenerated': 'Report generated.',
      'draftSavedOnline': 'Draft saved online.',
      'couldNotSubmitOnline': 'Could not submit online. Please try again.',
      'secureEvidenceVault': 'Secure Evidence Vault',
      'uploadTagSearchPackageEvidence':
          'Upload, tag, search and package cyber evidence. Backend files are AES encrypted.',
      'takeQuiz': 'Take quiz',
      'progressBadge': '{percent}% complete | Badge: {badge}',
      'cyberDefender': 'Cyber Defender',
      'cyberLearner': 'Cyber Learner',
      'deepfakeSubtitle':
          'Awareness, emergency response, legal guidance and helpline access.',
      'deepfakeWarning':
          'If someone threatens to leak morphed/private media, do not pay or negotiate. Preserve evidence and report quickly.',
      'emergencyActions': 'Emergency actions',
      'call1930': 'Call 1930',
      'police100': 'Police 100',
      'cyberPortal': 'Cyber Portal',
      'reportStatusDraft': 'Draft',
      'reportStatusReported': 'Reported',
      'reportStatusUnderInvestigation': 'Under investigation',
      'reportStatusResolved': 'Resolved',
      'reportStatusLabel': 'Status',
      'cyberPortalGuideTitle': 'File on cybercrime.gov.in',
      'cyberPortalGuideSubtitle':
          'Your Suraksha complaint is ready. Use this guided flow to file on the national portal and save your acknowledgement number here.',
      'cyberPortalGuideStep1':
          'Save or share your Suraksha complaint PDF using the button below.',
      'cyberPortalGuideStep2':
          'Open cybercrime.gov.in and sign in as a Citizen.',
      'cyberPortalGuideStep3':
          'File a new cyber crime complaint using the same incident details and attach your evidence.',
      'cyberPortalGuideStep4':
          'Copy the government acknowledgement number and save it below for follow-up.',
      'cyberPortalCopyComplaint': 'Copy complaint text',
      'cyberPortalComplaintCopied': 'Complaint text copied to clipboard.',
      'cyberPortalAckLabel': 'Government acknowledgement number',
      'cyberPortalAckHint': 'Enter the number from cybercrime.gov.in',
      'cyberPortalAckTooShort': 'Enter a valid acknowledgement number.',
      'cyberPortalSaveAck': 'Save acknowledgement',
      'cyberPortalAckSaved': 'Acknowledgement number saved.',
      'cyberPortalAckSavedOn':
          'Saved as {number} on {date}.',
      'cyberPortalFiledBadge': 'Filed on portal',
      'uploadEncryptedEvidence': 'Upload encrypted evidence',
      'noFilesSelectedYet': 'No files selected yet.',
      'generate': 'Generate',
      'generatedComplaint': 'Generated complaint',
      'reportSummaryUnavailable': 'Report summary unavailable.',
      'pdfPayloadGenerated':
          'PDF payload generated. Export integration can save/share it from backend response.',
      'evidenceTitleLabel': 'Evidence title',
      'evidenceTitleHint': 'Threat screenshot, UPI proof...',
      'category': 'Category',
      'private': 'Private',
      'tags': 'Tags',
      'tagsHint': 'blackmail, instagram, payment',
      'finish': 'Finish',
      'searchVault': 'Search vault',
      'searchByTitle': 'Search by title',
      'noEvidenceFound':
          'No evidence found. Upload evidence to start your secure vault.',
      'sessionExpiredSignIn': 'Session expired. Please sign in again.',
      'loginRequiredCyber': 'Please login again to use secure cyber features.',
      'fileTooLarge10Mb': 'File is too large. Maximum upload size is 10 MB.',
      'networkServerIssue': 'Network or server issue. Please try again.',
      'cyberEvidenceDecryptFailed':
          'Could not open this encrypted file. Try re-uploading it.',
      'cyberEvidenceServerMissing':
          'Evidence file is missing on the server. Please re-upload this item.',
      'couldNotSharePdf': 'Could not share PDF. Please try again.',
      'couldNotExportEvidence': 'Could not export evidence package.',
      'riskLevel': 'Risk Level',
      'recommendedActions': 'Recommended actions',
      'safetyTips': 'Safety tips',
      'encrypted': 'Encrypted',
      'notEncrypted': 'Not encrypted',
      'linkedToReport': 'Linked to report',
      'preview': 'Preview',
      'download': 'Download',
      'delete': 'Delete',
      'edit': 'Edit',
      'noUnlinkedEvidence': 'No unlinked evidence in vault.',
      'minDescriptionChars': 'Add at least 10 characters of incident details.',
      'draftPendingDetails': 'Draft report pending details.',
      'evidenceFilesSecured': '{count} evidence file(s) secured in vault.',
      'vaultEvidenceLinked': '{count} vault item(s) linked to report.',
      'summaryStep': 'Summary',
      'myReports': 'My Reports',
      'noSubmittedReportsYet': 'No submitted reports yet. Generate a complaint to see it here.',
      'draft': 'Draft',
      'pickFromGallery': 'Gallery',
      'pickFile': 'Pick file',
      'attachFromVault': 'From vault',
      'vaultItemsSelected': '{count} vault item(s) selected',
      'uploadingEvidence': 'Uploading evidence {current}/{total}…',
      'selectVaultEvidence': 'Select vault evidence',
      'analyzeInputRequired': 'Paste a message, link, question, or attach a screenshot.',
      'clearScreenshot': 'Clear screenshot',
      'screenshotTextExtracted': 'Screenshot text extracted',
      'evidenceEncryptedSaved': 'Evidence encrypted and saved.',
      'uploadFailed': 'Upload failed.',
      'previewFailed': 'Preview failed.',
      'downloadFailed': 'Download failed.',
      'deleteEvidenceTitle': 'Delete evidence?',
      'deleteEvidenceConfirm': 'Remove "{title}" from your secure vault?',
      'evidenceDeleted': 'Evidence deleted.',
      'deleteFailed': 'Delete failed.',
      'exportFailed': 'Export failed.',
      'exportEvidencePackage': 'Export evidence package',
      'cyberAiResultDisclaimer':
          'This is a potential risk assessment only — not legal proof, police advice, or a final determination. Always verify with official sources.',
      'cyberEvidencePrivacyNotice':
          'Files you upload are stored in Suraksha’s secure server vault (AES-encrypted on disk under your account). Metadata (title, category, tags) is saved with your account. Evidence is not sent to the official cybercrime portal unless you file there yourself.',
      'cyberEvidenceConfirmTitle': 'Confirm evidence upload',
      'cyberEvidenceConfirmMessage':
          'File: {name}\nSize: {size}\nCategory: {category}\nPrivate: {private}\n\nUpload this file to your Suraksha vault?',
      'cyberEvidenceInvalidType':
          'Unsupported file type. Use JPG, PNG, WEBP, PDF, MP3, WAV, or M4A.',
      'cyberEvidenceFileMissing': 'Could not read the selected file.',
      'cyberEvidenceUploadCancel': 'Cancel upload',
      'cyberUploadCancelled': 'Upload cancelled.',
      'cyberVaultLockTitle': 'Vault viewing lock',
      'cyberVaultLockSubtitle':
          'Optional PIN or biometric required before previewing or downloading evidence.',
      'cyberVaultEnableLock': 'Enable viewing lock',
      'cyberVaultDisableLock': 'Disable viewing lock',
      'cyberVaultUnlockTitle': 'Unlock evidence vault',
      'cyberVaultUnlockAction': 'Unlock',
      'cyberVaultBiometricReason': 'Unlock Suraksha evidence vault',
      'cyberVaultPinIncorrect': 'Incorrect PIN.',
      'cyberVaultLockEnabled': 'Evidence viewing lock enabled.',
      'cyberVaultLockDisabled': 'Evidence viewing lock disabled.',
      'cyberVaultSetPinTitle': 'Set vault PIN',
      'cyberVaultConfirmPinLabel': 'Confirm PIN',
      'cyberVaultPinMismatch': 'PINs do not match.',
      'cyberAcknowledgementHistory': 'Acknowledgement history',
      'cyberAcknowledgementHistoryEmpty': 'No portal acknowledgement numbers saved yet.',
      'cyberAckSavedAt': 'Saved {when}',
      'filterAll': 'All',
      'filterLinked': 'Linked',
      'filterUnlinked': 'Unlinked',
      'reportDetails': 'Report details',
      'linkedEvidence': 'Linked evidence',
      'noLinkedEvidence': 'No evidence linked to this report yet.',
      'digitalSafetyLearningHub': 'Digital Safety Learning Hub',
      'learningHubSubtitle': 'Build skills for phishing, UPI, privacy, stalking prevention and deepfake response.',
      'cyberSafetyScore': 'Cyber Safety Score',
      'cyberSafetyScoreUpdated': 'Cyber Safety Score: {score}',
      'catFinancialFraud': 'Financial Fraud',
      'catCyberStalking': 'Cyber Stalking',
      'catOnlineBullying': 'Online Bullying',
      'catIdentityTheft': 'Identity Theft',
      'catSocialMediaHarassment': 'Social Media Harassment',
      'catHarassment': 'Harassment',
      'catBlackmail': 'Blackmail',
      'catFakeProfile': 'Fake Profile',
      'catDeepfakeThreat': 'Deepfake Threat',
      'catDeepfakeScam': 'Deepfake Scam',
      'catFakeJobScam': 'Fake Job Scam',
      'catUpiFraud': 'UPI Fraud',
      'catOther': 'Other',
      'evidenceCatAll': 'All',
      'evidenceCatScreenshot': 'Screenshot',
      'evidenceCatAudio': 'Audio',
      'evidenceCatThreatMessage': 'Threat Message',
      'evidenceCatImage': 'Image',
      'evidenceCatTransactionProof': 'Transaction Proof',
      'evidenceCatDocument': 'Document',
      'evidenceCatOther': 'Other',
      'multiSelectNone': 'None selected',
      'multiSelectCount': '{count} selected',
      'filterCategories': 'Filter categories',
      'filterLinkStatus': 'Link status',
      'additionalCategoriesNote': 'Additional incident types',
      'configureServer': 'Configure server',
      'configureServerHint':
          'Enter your PC IP where the backend runs. Example: http://192.168.1.5:5000/api',
      'serverUrlHint': 'http://192.168.1.5:5000/api',
      'serverUrlSaved': 'Server URL saved. Retrying connection...',
      'cannotReachServer':
          'Unable to connect to the server. Please check your internet connection and try again.',
      'fixConnection': 'Retry connection',
      'deepfakeEmergencySupportTitle':
          'Deepfake & Morphed Image Emergency Support',
      'medicalHealthVault': 'Medical Health Vault',
      'emergencyNotes': 'Emergency notes',
      'medicalDisclaimer':
          'This information is user-provided and is not verified medical advice. Always follow instructions from qualified medical professionals.',
      'medicalNeverUpdated': 'Not updated yet',
      'medicalLastUpdatedAt': 'Last updated {date} at {time}',
      'medicalRevealTitle': 'Show medical details?',
      'medicalRevealMessage':
          'Medical information is hidden by default. Confirm to display your stored details on this screen.',
      'medicalRevealConfirm': 'Show details',
      'medicalDetailsHidden': 'Medical details are hidden',
      'medicalDetailsHiddenSubtitle':
          'Confirm before viewing blood group, allergies, conditions, medications, and notes.',
      'medicalEmergencyAccessTitle': 'Emergency access mode',
      'medicalEmergencyAccessSubtitle':
          'For responders: reveal all medical details on-screen after confirmation.',
      'medicalEmergencyModeTitle': 'Enable emergency access?',
      'medicalEmergencyModeMessage':
          'This will display your full medical profile for emergency helpers on this device.',
      'medicalEmergencyModeConfirm': 'Enable emergency access',
      'medicalEmergencyModeActive':
          'Emergency access is active. Your medical details are visible on this screen.',
      'medicalExitEmergencyMode': 'Exit',
      'medicalExportAction': 'Export / share medical data',
      'medicalDeleteTitle': 'Delete medical vault data?',
      'medicalDeleteMessage':
          'This clears medical fields from this device and attempts to clear them from your account profile.',
      'medicalDeleteConfirm': 'Delete medical data',
      'medicalDeleteDone': 'Medical data deleted.',
      'medicalLockedTitle': 'Medical vault is locked',
      'medicalLockedSubtitle':
          'Unlock with your PIN or device biometrics to view or edit medical information.',
      'medicalUnlockTitle': 'Enter vault PIN',
      'medicalUnlockAction': 'Unlock',
      'medicalUnlockWithPin': 'Unlock with PIN',
      'medicalUnlockWithBiometric': 'Unlock with biometrics',
      'medicalBiometricReason': 'Unlock Medical Health Vault',
      'medicalPinLabel': 'PIN (4–8 digits)',
      'medicalPinConfirmLabel': 'Confirm PIN',
      'medicalPinIncorrect': 'Incorrect PIN.',
      'medicalPinTooShort': 'PIN must be at least 4 digits.',
      'medicalEnableLockTitle': 'Protect medical vault',
      'medicalEnableLockMessage':
          'Set a PIN to require unlock before opening the vault. Biometrics can also be used when available.',
      'medicalEnableLockAction': 'Enable PIN / biometric lock',
      'medicalDisableLockTitle': 'Remove vault lock?',
      'medicalDisableLockMessage':
          'Anyone with access to this signed-in account can open the medical vault without a PIN.',
      'medicalDisableLockConfirm': 'Remove lock',
      'medicalDisableLockAction': 'Disable vault lock',
      'medicalLockEnabled': 'Vault lock enabled.',
      'medicalLockDisabled': 'Vault lock disabled.',
      'surakshaAi': 'Suraksha AI',
      'surakshaAiSubtitle': 'Your personal safety assistant',
      'surakshaAiWelcome':
          'Hi, I am Suraksha AI. Ask me about SOS, route safety, cyber scams, POSH, or medical emergency prep. If you are in immediate danger, call 112 first.',
      'surakshaAiPlaceholder': 'Ask about safety, routes, SOS...',
      'surakshaAiThinking': 'Thinking...',
      'surakshaAiQuickPrompt1': 'How do I use SOS?',
      'surakshaAiQuickPrompt2': 'I feel unsafe while travelling',
      'surakshaAiQuickPrompt3': 'Someone is harassing me online',
      'surakshaAiLimitedOfflineGuidance': 'Limited offline guidance',
      'surakshaAiPrivacyWarning':
          'Privacy tip: Do not share passwords, OTPs, banking credentials, Aadhaar/PAN, or unnecessary identity details in this chat.',
      'surakshaAiNewConversation': 'New conversation',
      'surakshaAiClearChat': 'Clear chat',
      'surakshaAiClearChatConfirm':
          'Clear this chat and start fresh? Server conversation history for Suraksha AI will also be reset.',
      'surakshaAiConversationCleared': 'Conversation cleared.',
      'surakshaAiFeedbackHelpful': 'Helpful',
      'surakshaAiFeedbackIrrelevant': 'Irrelevant',
      'surakshaAiFeedbackUnsafe': 'Unsafe',
      'surakshaAiFeedbackThanks': 'Thanks for your feedback.',
      'surakshaAiFeedbackFailed': 'Could not save feedback right now.',
      'surakshaAiActionCall112': 'Call 112',
      'surakshaAiActionSos': 'Trigger SOS',
      'surakshaAiActionSafetyMap': 'Safety Map',
      'surakshaAiActionCyber': 'Cyber Protection',
      'surakshaAiActionPosh': 'POSH',
      'surakshaAiSosTriggered': 'SOS triggered from Suraksha AI.',
      'surakshaAiIntentDanger': 'Detected intent: immediate danger',
      'surakshaAiIntentCyber': 'Detected intent: cyber / blackmail',
      'surakshaAiIntentPosh': 'Detected intent: workplace harassment',
      'surakshaAiIntentMedical': 'Detected intent: medical emergency',
      'surakshaAiIntentGreeting': 'Detected intent: greeting',
      'surakshaAiIntentGeneral': 'Detected intent: general question',
      'keepEmergencyMedicalInformationOrganized':
          'Keep emergency medical information beautifully organized for quick use.',
      'emergencyMedicalId': 'Emergency Medical ID',
      'scanInCaseOfMedicalEmergency': 'Scan in case of medical emergency',
      'medicalProfileSaved': 'Medical profile saved',
      'medicalDetailsReady':
          'Your medical details are ready for emergency use.',
      'savedLocallyOnThisDevice': 'Saved locally on this device.',
      'medicalProfileSavedLocallySyncRetryLater':
          'Medical profile saved locally. Sync will retry later.',
      'certificateDetails': 'Certificate details',
      'issuedOn': 'Issued on {date}',
      'poshCertifiedMessage':
          'You have completed all three quiz levels and demonstrated strong POSH Act knowledge.',
      'validForPoshCertificate':
          'Valid for: POSH Act awareness and workplace safety learning',
      'safeZoneUpdatedNearby': 'Safe zone updated nearby',
      'crowdedAreaWarning': 'Crowded area warning',
      'loadingNearbySafetyPoints': 'Loading nearby safety points...',
      'unableToFetchLocation':
          'Unable to fetch location. Move near open sky and try again.',
      'couldNotFetchYourLocation': 'Could not fetch your location.',
      'youAreHere': 'You are here',
      'surakshaLiveLocationNotificationTitle': 'Suraksha Live Location',
      'surakshaLiveLocationNotificationText':
          'Tracking live location for safety features.',
      'journeyStopped': 'Journey stopped',
      'totalRoute': 'total route',
      'stop': 'Stop',
      'start': 'Start',
      'minsAgo2': '2 mins ago',
      'minsAgo15': '15 mins ago',
      'map': 'Map',
      'medical': 'Medical',
      'cyber': 'Cyber',
      'poshPortal': 'POSH Portal',
      'liveSafetyMapTitle': 'Live Safety Map',
      'locating': 'Locating...',
      'myLocation': 'My Location',
      'refreshNearby': 'Refresh Nearby',
      'retryLiveLocation': 'Retry Live Location',
      'safetyIntelligenceMap': 'Safety Intelligence Map',
      'couldNotFindThatLocation': 'Could not find that location.',
      'couldNotOpenThisPlace': 'Could not open this place.',
      'tryAgain': 'Try again',
      'longPressDropPinPreviewRoute':
          'Long press to drop pin. Tap markers to preview route.',
      'fetchingYourLocation': 'Fetching your current location...',
      'mapWillOpenAroundYou':
          'The map will open directly around you once GPS is ready.',
      'searchLocation': 'Search location...',
      'liveTrackingActive': 'Live tracking active',
      'journeyTrackingActive': 'Journey tracking active',
      'destinationReached': 'Destination reached',
      'selectedDestination': 'Selected destination',
      'calculatingRoute': 'Calculating route',
      'remaining': 'Remaining',
      'routePreview': 'Route preview',
      'liveNavigation': 'Live navigation',
      'followingYourRoute': 'Following your route with live progress',
      'readyWithDistanceAndEstimatedTravelTime':
          'Ready with distance and estimated travel time',
      'calculatingRouteDistance': 'Calculating route distance',
      'covered': 'Covered',
      'eta': 'ETA',
      'selectedLocation': 'Selected Location',
      'customPin': 'Custom Pin',
      'study': 'Study',
      'quizzes': 'Quizzes',
      'complaint': 'Complaint',
      'poshActLearningHub': 'POSH Act Learning Hub',
      'poshStudy1Title': 'What the POSH Act Covers',
      'poshStudy1Bullet1':
          'The POSH Act is the Sexual Harassment of Women at Workplace Act, 2013.',
      'poshStudy1Bullet2':
          'It protects dignity, equality, and safe working conditions.',
      'poshStudy1Bullet3':
          'It applies to public and private workplaces, offices, shops, hospitals, schools, NGOs, transport provided by employer, and work-related visits.',
      'poshStudy1Bullet4':
          'The law covers employees, trainees, interns, contract staff, volunteers, and workplace visitors in the relevant context.',
      'poshStudy1Bullet5':
          'Unwelcome conduct of a sexual nature can be verbal, written, digital, or physical.',
      'poshStudy1Bullet6':
          'Examples include unwanted touching, sexual remarks, sexual messages, repeated harassment, or showing pornography.',
      'poshStudy2Title': 'Complaint Process and IC Handling',
      'poshStudy2Bullet1':
          'The complaint should normally be filed in writing within 3 months of the incident or last incident in a continuing pattern.',
      'poshStudy2Bullet2':
          'The Internal Committee should be properly formed where the workplace has 10 or more employees.',
      'poshStudy2Bullet3':
          'The committee generally includes a senior woman presiding officer, employee members, and an external member familiar with harassment matters.',
      'poshStudy2Bullet4':
          'Conciliation can be used only if the complainant wants it, and it should not be forced.',
      'poshStudy2Bullet5':
          'If no conciliation happens, the IC conducts a formal inquiry with both sides heard fairly.',
      'poshStudy2Bullet6':
          'The process should stay confidential, written, and documented.',
      'poshStudy3Title': 'Evidence, Safety, and Employer Duties',
      'poshStudy3Bullet1':
          'Keep chats, emails, screenshots, call logs, witness names, dates, and location details.',
      'poshStudy3Bullet2':
          'Interim relief can include leave, transfer, no-contact directions, or reporting-line changes if needed for safety.',
      'poshStudy3Bullet3':
          'If the facts also show criminal conduct, a police complaint or FIR can be filed in addition to the POSH process.',
      'poshStudy3Bullet4':
          'Employers should display the policy, train staff, support the IC, and implement recommendations in time.',
      'poshStudy3Bullet5':
          'Confidentiality applies to complainant, respondent, witnesses, and proceedings.',
      'poshStudy3Bullet6':
          'A complaint is not fake just because it could not be proven; deliberate falsehood is a different standard.',
      'poshStudy4Title': 'Important POSH Boundaries',
      'poshStudy4Bullet1':
          'Do not use the mechanism for unrelated personal disputes or knowingly fabricated allegations.',
      'poshStudy4Bullet2': 'Do not delete evidence or pressure witnesses.',
      'poshStudy4Bullet3':
          'Do not ignore repeated small incidents; patterns matter.',
      'poshStudy4Bullet4': 'Use factual, dated, and detailed reporting.',
      'poshStudy4Bullet5':
          'When in immediate danger, call emergency services first.',
      'poshStudy4Bullet6':
          'The POSH portal is for learning, documenting, and structured complaint preparation.',
      'studyFirst': 'Study first',
      'readAllSectionsBeforeQuiz1': 'Read all sections before Quiz 1',
      'threeLevels': 'Three levels',
      'twentyMcqsEachQuiz': '20 MCQs in each quiz',
      'quizCertificationTrack': 'Quiz Certification Track',
      'studyFirstThenClearQuizzesInOrder':
          'Study first, then clear the quizzes in order.',
      'level': 'Level',
      'levelPassed': 'Level Passed',
      'passed': 'Passed',
      'available': 'Available',
      'locked': 'Locked',
      'submitQuiz': 'Submit quiz',
      'next': 'Next',
      'unlocked': 'Unlocked',
      'quizNotClearedYet': 'Quiz not cleared yet',
      'reviewStudy': 'Review study',
      'retry': 'Retry',
      'viewCertificate': 'View certificate',
      'continueLabel': 'Continue',
      'poshCertified': 'POSH Certified',
      'fileWorkplaceComplaint': 'File Workplace Complaint',
      'fileWorkplaceComplaintSubtitle':
          'Prepare a detailed incident record for your reference. This is not official IC, employer, or government filing. In immediate danger, call 112 first.',
      'keepRecordsFactual':
          'Keep your records factual and attach evidence when possible.',
      'yourFullName': 'Your Full Name',
      'yourPhoneNumber': 'Your Phone Number',
      'yourEmailAddress': 'Your Email Address',
      'accusedPersonName': 'Accused Person Name',
      'companyWorkplaceName': 'Company / Workplace Name',
      'incidentDateDdMmYyyy': 'Incident Date (DD/MM/YYYY)',
      'incidentLocation': 'Incident Location',
      'witnessesIfAny': 'Witnesses (if any)',
      'detailedIncidentDescription': 'Detailed Incident Description',
      'submitting': 'Submitting...',
      'submitComplaint': 'SUBMIT COMPLAINT',
      'guideIntro':
          'This guide is educational and operational. It explains process, boundaries, documentation, and escalation under the POSH framework in India.',
      'legalDisclaimer':
          'Legal Disclaimer: Suraksha provides educational POSH guidance only—not legal advice or official filing. Saving drafts or records here does not submit to your Internal Committee, employer, or government. For critical matters, consult a qualified lawyer, HR-POSH expert, or competent authority.',
      'poshLegalSourceLabel': 'Legal source',
      'poshLegalSourceNote':
          'Educational summary based on the POSH Act, 2013 and commonly published workplace compliance guidance. Not an official government filing channel.',
      'poshLastReviewed': 'Content last reviewed: {date}',
      'poshHubEducationTitle': 'Education',
      'poshHubEducationSubtitle':
          'Study POSH basics and open the detailed Act guide.',
      'poshHubQuizTitle': 'Quiz',
      'poshHubQuizSubtitle':
          'Clear three quiz levels to earn your certificate.',
      'poshHubComplaintTitle': 'Complaint preparation',
      'poshHubComplaintSubtitle':
          'Draft incident details securely—Suraksha is not an official filing portal.',
      'poshHubCertificateTitle': 'Certificate',
      'poshHubCertificateSubtitle':
          'View your POSH awareness certificate after clearing all quiz levels.',
      'poshFilingBoundaryTitle': 'Not official filing',
      'poshFilingBoundaryMessage':
          'Saving a draft or saving to Suraksha keeps a private record in this app only. It does not file with your Internal Committee (IC), employer, or any government portal. Submit officially through your workplace IC or competent authority.',
      'poshSaveDraft': 'Save draft',
      'poshDraftSaved': 'Draft saved securely on this device.',
      'poshSaveToSuraksha': 'Save to Suraksha (not official filing)',
      'poshSavedToSurakshaNotice':
          'Saved in Suraksha for your records. This is not an official IC or government submission.',
      'poshDangerDetectedTitle': 'Immediate danger detected',
      'poshDangerDetectedMessage':
          'Your notes suggest you may be in immediate danger. Call emergency services now or open SOS from the dashboard.',
      'poshCall112': 'Call 112',
      'poshOpenSos': 'Open SOS',
      'poshGuideContents': 'Contents',
      'poshGuideSearchHint': 'Search guide sections',
      'poshGuideNoSearchResults': 'No sections match your search.',
      'poshGuideBookmark': 'Bookmark section',
      'poshGuideBookmarked': 'Bookmarked',
      'poshGuideFontSize': 'Text size',
      'poshCertificateNotReady':
          'Complete all three quiz levels to unlock your certificate.',
      'poshComplaintDraftRestored': 'Your saved draft was restored.',
      'guide1Title': '1. Background And Objective',
      'guide1Body':
          'The Sexual Harassment of Women at Workplace (Prevention, Prohibition and Redressal) Act, 2013 — commonly called the POSH Act — came into force to give workplaces a clear legal duty to prevent sexual harassment, prohibit such conduct, and provide a fair redressal system.\n\n'
          'It builds on the Supreme Court’s Vishaka guidelines (1997) and turns those principles into a statutory framework. The Act’s core aims are: (1) prevent sexual harassment at work, (2) prohibit it through policy and accountability, and (3) create accessible complaint and inquiry mechanisms.\n\n'
          'Every employer covered by the Act must provide a safe working environment, display information about the complaint process, sensitise employees, and support Internal Committee (IC) or Local Committee (LC) proceedings without retaliation.\n\n'
          'This Suraksha guide is educational only. It helps you understand process and prepare records. It is not a substitute for legal advice, and using Suraksha does not itself file a complaint with an IC, employer, or government authority.',
      'guide2Title': '2. Where It Applies',
      'guide2Body':
          'The Act applies widely across organised and many unorganised workplace settings in India. A “workplace” is not limited to a traditional office desk. It can include government and private offices, factories, shops, hospitals, educational institutions, NGOs, sports institutes, stadiums, and other establishments.\n\n'
          'It also covers places visited in the course of employment — for example client sites, training venues, conferences, and travel for work. Dwelling places used as workplaces (including some domestic-work contexts) can fall within the Act’s scope where the statutory conditions are met.\n\n'
          'Remote or hybrid work does not remove protection. Conduct through office email, official chat tools, video meetings, or work-related digital channels can still be workplace-related if connected to employment.\n\n'
          'If your organisation has fewer than 10 workers, complaints are generally handled through the Local Committee (LC) constituted by the District Officer, rather than an Internal Committee.',
      'guide3Title': '3. Who Is Protected',
      'guide3Body':
          'The Act primarily protects an “aggrieved woman” in relation to a workplace. Protection is not limited to permanent employees on payroll. It can include women who are employed (regular, temporary, ad hoc, daily wage), contract staff, trainees, apprentices, interns, and, in many practical contexts, women who visit or interact with the workplace in connection with work.\n\n'
          'The respondent (person against whom the complaint is made) may be an employee, employer, or another person connected with the workplace, depending on facts. Status differences — junior vs senior, contractor vs full-time — do not by themselves defeat a complaint.\n\n'
          'POSH is a women-protection workplace statute. Other laws and organisational policies may address harassment affecting other genders; those pathways are separate from the POSH Act framework explained here.\n\n'
          'If you are unsure whether your role is covered, note your employment/engagement type, workplace location, and how the incident connects to work — then seek guidance from IC/LC contacts, a POSH-aware HR professional, or a lawyer.',
      'guide4Title': '4. What Counts As Sexual Harassment',
      'guide4Body':
          'Under the Act, sexual harassment includes any one or more unwelcome acts or behaviour of a sexual nature, whether direct or by implication. Illustrative examples include: unwelcome physical contact and advances; a demand or request for sexual favours; making sexually coloured remarks; showing pornography; and any other unwelcome physical, verbal, or non-verbal conduct of a sexual nature.\n\n'
          'Harassment can be a single serious incident or a pattern. It may occur in person or through digital means (messages, calls, emails, social media, deepfakes, or morphed images) when linked to the workplace relationship.\n\n'
          'The key idea is that the conduct is unwelcome. Consent cannot be assumed from silence, past friendship, or workplace hierarchy. Quid pro quo situations (benefits or threats tied to sexual favours) and a hostile work environment created by sexual conduct are both serious.\n\n'
          'Not every workplace conflict is sexual harassment. Rude but non-sexual behaviour may still violate other policies. For POSH, focus on whether the conduct is sexual in nature and unwelcome, and document dates, words/actions, impact, and witnesses.',
      'guide5Title': '5. Internal Committee (IC) Requirements',
      'guide5Body':
          'Every workplace with 10 or more employees must constitute an Internal Committee (IC). The IC typically includes: a Presiding Officer who is a senior woman employee; at least two employee members preferably committed to women’s causes / social work / legal knowledge; and one external member from an NGO or association committed to the cause of women, or a person familiar with issues relating to sexual harassment.\n\n'
          'At least one-half of the total IC members should be women. Members generally have a tenure of up to three years. The employer must ensure the IC is actually functioning — not just named on paper.\n\n'
          'Where no IC exists (including workplaces with fewer than 10 employees), the Local Committee (LC) at the district level is the forum. Employers who fail to constitute an IC where required risk penalties under the Act, and may face further consequences for repeated non-compliance.\n\n'
          'Practically: ask HR/admin for the current IC member list, complaint email/drop-box, and policy document. Keep a copy of that information with your records.',
      'guide6Title': '6. Complaint Timeline And Format',
      'guide6Body':
          'Under current law (POSH Act, 2013), an aggrieved woman should ordinarily submit a written complaint to the IC/LC within three months of the incident. For a series of incidents, the three-month period is generally counted from the last incident.\n\n'
          'The IC/LC may extend the time by up to another three months (maximum six months in total under the present framework) if it is satisfied that circumstances prevented timely filing, and it must record reasons in writing. Proposed amendments discussed in public debate (including a longer filing window) are not a substitute for the current statutory rule until enacted — follow the timeline that applies to your case and seek legal advice if you are near or past the limit.\n\n'
          'A strong complaint usually includes: complainant and respondent identification; workplace details; dates/times/places; a clear narrative of facts; names of witnesses; list of evidence; impact on work/health/safety; and the relief sought (for example no-contact, transfer, inquiry, interim measures).\n\n'
          'If writing is difficult, the Act contemplates assistance so that the complaint can be reduced to writing and signed/verified as required. Keep your own dated copy of whatever you submit.',
      'guide7Title': '7. Conciliation And Inquiry',
      'guide7Body':
          'Before a full inquiry, the IC may attempt conciliation at the request of the aggrieved woman. Conciliation is voluntary. Monetary settlement as the basis of conciliation is not permitted under the Act’s conciliation framework. If conciliation succeeds, the IC records the settlement and generally does not conduct further inquiry on those terms; copies go to the employer and parties as required.\n\n'
          'If conciliation is not requested, fails, or is inappropriate, the IC proceeds with inquiry. The respondent is informed and given an opportunity to respond in writing. Both sides should be heard; principles of natural justice apply. The IC has powers of a civil court for certain purposes (such as summoning and examining persons on oath and requiring documents), within the Act’s framework.\n\n'
          'Inquiry should ordinarily be completed within 90 days. The IC then submits its report to the employer (or District Officer for LC matters) within 10 days of completing the inquiry, and makes the report available to the concerned parties.\n\n'
          'Do not rely only on verbal updates. Ask for written acknowledgements, hearing dates, and copies you are entitled to receive.',
      'guide8Title': '8. Interim Relief During Proceedings',
      'guide8Body':
          'During inquiry, the IC may recommend interim measures to protect the complainant and preserve a fair process. Common examples include: transfer of either party; grant of leave to the aggrieved woman (in addition to leave otherwise entitled, subject to statutory limits); change of reporting relationship; restraint on the respondent from evaluating the complainant’s work; no-contact or restricted-communication directions; and workplace safety/security support.\n\n'
          'Interim relief is not a final finding of guilt. It is a protective and process-integrity step. Request interim measures in writing if you face continued contact, intimidation, performance retaliation, or unsafe proximity.\n\n'
          'If interim recommendations are made, the employer should implement them. Track whether they are actually enforced. If retaliation continues, document each incident with date, time, persons involved, and any messages or emails.\n\n'
          'In immediate physical danger, call 112 / local police first. POSH interim measures are workplace process tools — they do not replace emergency response.',
      'guide9Title': '9. Inquiry Outcome And Employer Action',
      'guide9Body':
          'After inquiry, the IC issues findings. If allegations are not proved, it may recommend that no action is required against the respondent. If allegations are proved, it may recommend action under service rules / applicable disciplinary rules. Depending on facts and policy, recommendations can include warning, written apology, counselling, withholding promotion/pay rise, termination, or other lawful disciplinary action.\n\n'
          'The IC may also recommend payment of compensation to the aggrieved woman, which can be recovered from the respondent’s salary/wages as provided under the Act and rules, where applicable.\n\n'
          'The employer must act on the IC’s recommendations within 60 days of receipt. Failure to implement recommendations can itself create compliance exposure for the employer.\n\n'
          'Ask for the written report outcome applicable to you, note the implementation deadline, and keep proof of what action was (or was not) taken.',
      'guide10Title': '10. Police Complaint And Criminal Law',
      'guide10Body':
          'POSH is a workplace civil/administrative redressal framework. It does not cancel criminal law. If facts disclose offences under the Bharatiya Nyaya Sanhita (or earlier IPC provisions as applicable to the incident date), Information Technology Act offences, or other criminal laws, you may pursue police complaint / FIR in parallel or separately.\n\n'
          'Examples of situations that often need criminal evaluation (case-specific): sexual assault, stalking, criminal intimidation, voyeurism, non-consensual intimate imagery, blackmail, and certain online sexual offences.\n\n'
          'You can pursue IC proceedings and criminal remedies together where appropriate. Tell the IC if a police case exists, because coordination and evidence handling may matter. Do not destroy devices or original files that police or forensic processes may need.\n\n'
          'If you are in immediate danger, call 112, move to a safe public place if possible, and use Suraksha SOS to alert trusted contacts. File workplace POSH steps when you are safe enough to do so.',
      'guide11Title': '11. Confidentiality Rules',
      'guide11Body':
          'Confidentiality is a central duty under POSH. The identity and addresses of the aggrieved woman, respondent, and witnesses; information relating to conciliation and inquiry proceedings; and contents of the complaint and inquiry findings should not be published or communicated to the public, press, or media in a manner that violates the Act.\n\n'
          'Limited disclosures may be required by law (for example to the employer for implementation, to parties for fair hearing, or under lawful authority). Gossip, group chats, and social-media posts about ongoing cases can create legal and safety risks.\n\n'
          'Employers and IC members must handle documents securely. Complainants should also store copies safely (encrypted vaults, restricted folders) and share only with trusted advisors or counsel.\n\n'
          'If someone leaks your identity or case details, record what was leaked, by whom, when, and where it appeared — and raise it with the IC/employer and, if needed, legal counsel.',
      'guide12Title': '12. False Complaints: Correct Legal Position',
      'guide12Body':
          'A complaint that is not proved is not automatically a “false” or “malicious” complaint. Survivors may face evidentiary limits, fear, missing witnesses, or trauma-related gaps. The law distinguishes an unproven case from a case filed with knowingly false allegations or forged/fabricated evidence.\n\n'
          'Action for malicious / false complaints is contemplated where the IC concludes that the allegation was made knowing it to be false, or that forged/misleading evidence was produced. This is a high and specific threshold — not a default label for every dismissed complaint.\n\n'
          'Threats like “if you complain we will countersue for false case” are sometimes used to intimidate. Document such threats. Seek independent legal advice before withdrawing a genuine complaint under pressure.\n\n'
          'Good-faith complainants should focus on accurate facts, preserved evidence, and consistent statements. Do not exaggerate dates or invent details — credibility rests on truthfulness.',
      'guide13Title': '13. How Not To Misuse The Act',
      'guide13Body':
          'POSH exists to address sexual harassment and protect workplace dignity. Misuse harms genuine survivors and weakens trust in the mechanism. Do not file complaints to settle unrelated score-settling (pure performance disputes, personal relationship break-ups without sexual harassment facts, or office politics).\n\n'
          'Do not coach witnesses to lie, alter chat exports selectively to mislead, create fake screenshots, or destroy inconvenient evidence. Do not pressure colleagues to join a complaint they did not experience.\n\n'
          'Respondents also must not misuse process: no retaliation, no witness intimidation, no leaking confidential complaint details, and no using hierarchical power to block a fair hearing.\n\n'
          'If your concern is serious but not sexual harassment, use the correct channel (grievance redressal, labour authorities, criminal law, or civil remedies) instead of forcing facts into POSH.',
      'guide14Title': '14. Employer Compliance Checklist',
      'guide14Body':
          'A compliant employer generally should: (1) constitute a properly composed IC where employee strength is 10+, (2) notify IC nominations and contact details, (3) publish and circulate a POSH policy, (4) display conspicuous notices about consequences of sexual harassment and how to complain, (5) organise regular awareness and capacity-building for employees and IC members, (6) assist the complaint process and provide necessary facilities to the IC/LC, (7) monitor timely inquiry and implement recommendations within statutory timelines, and (8) submit required reports/returns as applicable under the Act and Rules.\n\n'
          'Employers must also prevent and address retaliation against complainants and witnesses. Creating a chilling climate after a complaint is a compliance failure, not “neutrality.”\n\n'
          'Ask your workplace for: policy PDF, IC list, training records, and complaint submission method. If the workplace refuses basic compliance information, note that refusal in your personal records and consider LC/legal advice pathways.\n\n'
          'Government workplaces and private employers are both expected to meet the Act’s duties; size and sector do not erase core obligations where the Act applies.',
      'guide15Title': '15. Practical Evidence Checklist',
      'guide15Body':
          'Preserve evidence early. Useful materials often include: screenshots of chats/emails/DMs with visible dates and handles; original message export files; call logs; meeting invites/calendar entries; CCTV request references; access-card or attendance logs showing proximity; witness names and what each person saw/heard; prior written complaints to managers/HR; medical or counselling records if relevant and you choose to share them; and a personal timeline written soon after incidents.\n\n'
          'Keep originals when possible. Avoid editing images in ways that strip metadata if you can help it. Store backups in more than one safe place. Do not post evidence publicly while proceedings are ongoing.\n\n'
          'Write a chronological note: Date → Place → What happened → Who was present → What you said/did → Immediate impact → Any follow-up harassment. Update it if new incidents occur.\n\n'
          'Suraksha can help you organise a draft record, but official submission must still go to your IC/LC or other competent authority. In danger, prioritise safety and emergency help over perfect documentation.',
      'guide16Title': '16. Appeals And Further Remedies',
      'guide16Body':
          'If you are aggrieved by the recommendations of the IC/LC, the Act provides for appeal to the court or tribunal as notified — commonly aligned with the appellate channel available under service rules for similar disciplinary matters. Appeals are time-bound (generally within 90 days of the recommendations, subject to the Act/rules applicable to your case).\n\n'
          'Separate from POSH appeal, you may have other remedies depending on facts: police/FIR for criminal offences; labour/service-law challenges; civil claims; complaints to higher administrative authorities; or approaches to bodies such as the National/State Commission for Women where appropriate.\n\n'
          'If the employer fails to implement IC recommendations, document the default and seek legal advice on enforcement and compliance complaints.\n\n'
          'Because appellate strategy is fact-specific, consult a lawyer promptly after receiving the written outcome so limitation periods are not missed.',
      'guide17Title': '17. Good-Faith Use Of POSH Portal',
      'guide17Body':
          'Use this Suraksha POSH section in good faith: learn the framework, prepare accurate drafts, organise evidence lists, and understand IC vs criminal pathways. Saving a draft or saving a record in Suraksha does not file your case with an Internal Committee, Local Committee, employer, or government portal.\n\n'
          'When you are ready for official action, submit through your workplace IC/LC process (or other competent authority). Keep Suraksha copies as your personal preparation file.\n\n'
          'If your notes or situation indicate immediate danger, call 112 / emergency services first, move to safety if possible, and use Suraksha SOS to alert trusted contacts. Workplace complaint preparation can continue after you are safe.\n\n'
          'Share only truthful information. Do not use the portal to harass others, fabricate allegations, or circulate confidential case details. Good-faith use protects you and keeps the mechanism meaningful for everyone who needs it.',
      'safeRouteChanged': 'Safe route changed',
      'dailyRouteGuard': 'Daily Route Guard',
      'routeGuardDialogTitle': 'Daily route changed',
      'routeGuardDialogMessage':
          'You moved away from your usual route. Confirm you are safe.',
      'routeGuardConfirmWithin': 'Confirm within {seconds}s.',
      'routeGuardDeviationMeters':
          'About {meters} m from your usual path.',
      'routeGuardLearningRoute': 'Learning route',
      'routeGuardRoutinesLearned': '{count} routine(s) learned',
      'routeGuardIntelligenceLimited': 'Area data limited',
      'routeGuardMapRouteActive': 'Map route active',
      'safetyVerdictSafe': 'Lower observed risk',
      'safetyVerdictSafeSummary':
          'Available signals suggest lower observed risk here right now. This is not a guarantee of safety—stay alert.',
      'safetyVerdictCaution': 'Use caution',
      'safetyVerdictCautionSummary':
          'Use extra caution here—some risk signals were detected nearby.',
      'safetyVerdictHighRisk': 'Higher concern',
      'safetyVerdictHighRiskSummary':
          'This area may not feel safe right now, especially for women and elderly users.',
      'safetyVerdictLimitedDataSummary':
          'We have limited verified information for this area right now. Stay alert and use normal daytime precautions.',
      'safetyVerdictSafeWithEmergencySummary':
          'Emergency support is available within 1 km. Observed risk looks lower right now, but safety is never guaranteed.',
      'safetyVerdictNoCoreEmergencySummary':
          'No police station or hospital was found within 1 km. Stay alert in this area.',
      'safetyEmergencyWithin1kmTitle': 'Emergency services within 1 km',
      'safetyReasonNoCoreEmergency1km':
          'No police station or hospital is available within 1 km.',
      'safetyReasonPoliceWithin1km':
          '{count} police station(s) within 1 km.',
      'safetyReasonHospitalWithin1km': '{count} hospital(s) within 1 km.',
      'safetyReasonPharmacyWithin1km': '{count} pharmacy(ies) within 1 km.',
      'safetyReasonPetrolWithin1km': '{count} petrol pump(s) within 1 km.',
      'safetyReasonWashroomWithin1km': '{count} washroom(s) within 1 km.',
      'safetyReasonBloodBankWithin1km': '{count} blood bank(s) within 1 km.',
      'safetyVerdictMonitoring': 'Still learning',
      'safetyVerdictMonitoringSummary':
          'Live area intelligence is still building. Stay aware while we learn your surroundings.',
      'safetyWhySafeTitle': 'Why observed risk looks lower',
      'safetyWhyNotSafeTitle': 'Why this area may not feel safe',
      'safetyWhatToDo': 'What to do',
      'safetyUpdatingAreaIntelligence': 'Updating area safety intelligence...',
      'safetyActionSafe': 'Stay aware and keep trusted contacts reachable.',
      'safetyActionCaution':
          'Stay in lit areas and keep trusted contacts informed.',
      'safetyActionHighRisk':
          'Avoid isolated routes and share live location with someone you trust.',
      'safetyScoreDisclaimer':
          'Scores reflect observed signals only and do not guarantee that an area is safe.',
      'safetySourceGoogle': 'Google',
      'mapOfflineBannerTitle': 'Offline — limited map features',
      'mapOfflineBannerBody':
          'Showing your last-known location. Nearby services, live routing, and fresh safety data need internet.',
      'mapOfflinePlacesUnavailable':
          'Nearby places need internet. Emergency dialing still works.',
      'mapOfflineEmergencyHint':
          'Emergency actions still work without map data:',
      'mapNearbyPlacesListTitle': 'Nearby safety places',
      'mapTapToOpenPlace': 'Double tap to open this place.',
      'routeGuardMonitoringActive': 'Monitoring active',
      'routeGuardMonitoringInactive': 'Monitoring inactive',
      'routeGuardLastChecked': 'Last checked {time}',
      'routeGuardDataConfidence': 'Data confidence: {level}',
      'routeGuardConfidenceHigh': 'Higher',
      'routeGuardConfidenceMedium': 'Building',
      'routeGuardConfidenceLow': 'Limited',
      'routeGuardRouteLearned': 'Route learned',
      'routeGuardRouteNotLearned': 'Route not learned',
      'liveLocationSharingWith': 'Live location shared with',
      'stopLiveLocationSharing': 'Stop sharing',
      'aiSafetyIntelligence': 'AI Safety Intelligence',
      'refreshIntelligence': 'Refresh intelligence',
      'couldNotOpenGoogleMaps': 'Could not open Google Maps.',
      'listView': 'List View',
      'mapView': 'Map View',
      'nearbyCleanToilets': 'Nearby Clean Toilets',
      'toiletsRefresh': 'Refresh',
      'toiletsIncreaseRadius': 'Increase radius',
      'toiletsOpenMap': 'Open map',
      'toiletsTryAgain': 'Try again',
      'toiletsViewOnMap': 'View on Map',
      'toiletsNavigate': 'Navigate',
      'toiletsReportIssue': 'Report Issue',
      'toiletsOpenNowOnly': 'Open now only',
      'toiletsFemaleFacility': 'Female facility',
      'toiletsAccessible': 'Accessible',
      'toiletsWaterAvailable': 'Water available',
      'toiletsResults': 'Results',
      'toiletsRadiusLabel': 'Radius',
      'toiletsScopeLabel': 'Scope',
      'toiletsAllRegistered': 'All toilets',
      'toiletsAllRegisteredShort': 'All',
      'toiletsQualityLabel': 'Quality',
      'toiletsCleanOnly': 'Clean only',
      'toiletsCleanAndUsable': 'Clean + usable',
      'mapTraffic': 'Traffic',
      'mapTrafficSubtitle': 'Show road traffic overlay',
      'mapPublicToilets': 'Public Toilets',
      'mapLayers': 'Map Layers',
      'mapTypeNormal': 'Normal',
      'mapTypeHybrid': 'Hybrid',
      'mapTypeTerrain': 'Terrain',
      'couldNotFindLocation': 'Could not find that location.',
      'couldNotOpenPlace': 'Could not open this place.',
      'unableToOpenIssueReporting': 'Unable to open issue reporting.',
      'impactDetected': 'Impact detected',
      'cancelSos': 'Cancel SOS',
      'sendSosNow': 'Send SOS now',
      'later': 'Later',
      'openContacts': 'Open contacts',
      'servicePolice': 'Police',
      'serviceHospitals': 'Hospitals',
      'servicePharmacies': 'Pharmacies',
      'servicePetrolPumps': 'Petrol pumps',
      'serviceWashrooms': 'Washrooms',
      'serviceBloodBanks': 'Blood banks',
      'openNow': 'Open now',
      'closedNow': 'Closed now',
      'hoursUnavailable': 'Hours unavailable',
      'currentLocationLabel': 'Current location',
      'safetyScoreLabel': 'Safety Score {score}',
      'policeCountLabel': '{count} police',
      'hospitalsCountLabel': '{count} hospitals',
      'pharmaciesCountLabel': '{count} pharmacies',
      'petrolPumpsCountLabel': '{count} petrol pumps',
      'washroomsCountLabel': '{count} washrooms',
      'bloodBanksCountLabel': '{count} blood banks',
      'toiletsCleanlinessLabel': 'Cleanliness',
      'toiletsAvailabilityLabel': 'Availability',
      'toiletsLastUpdated': 'Last updated',
      'toiletsLastUpdatedNotAvailable': 'Last updated not available',
      'toiletsNotAvailable': 'Not available',
      'toiletsStatusNotVerified': 'Status not verified',
      'toiletsFacilityFemale': 'Female',
      'toiletsFacilityMale': 'Male',
      'toiletsFacilityAccessible': 'Accessible',
      'toiletsFacilityWater': 'Water',
      'toiletsCleanlinessScore': 'Cleanliness score',
      'toiletsCleanlinessStatus': 'Cleanliness status',
      'toiletsAvailability': 'Availability',
      'toiletsAddress': 'Address',
      'toiletsAddressNotAvailable': 'Address not available',
      'toiletsFacilities': 'Facilities',
      'impactDetectedMessage':
          'Your SOS countdown is active. Act now if this was accidental.',
      'saveEmergencyContactFirst': 'Save emergency contact first',
      'saveEmergencyContactFirstMessage':
          'Please save the emergency contact first, so that in any emergency, your loved ones will get to know first.',
      'sosCountdownActiveMessage':
          'SOS countdown is active. Cancel now if this was accidental.',
      'sosWillBeSentIn': 'SOS will be sent in {seconds} seconds.',
      'screamDetected': 'Scream or loud distress sound detected',
      'savingLastKnownLocation': 'Saving last known location...',
      'lastLocationSavedForHelp': 'Last location saved for emergency help.',
      'assessmentLimited': 'Assessment limited',
      'aiConfidenceLabel': 'AI Confidence {score}%',
      'riskLabelVerySafe': 'Very Safe',
      'riskLabelSafe': 'Safe',
      'riskLabelModerate': 'Moderate Risk',
      'riskLabelHighRisk': 'High Risk',
      'riskLabelCritical': 'Critical Risk',
      'riskLabelMonitoring': 'Monitoring',
      'riskLabelLocationOff': 'Location Off',
      'riskLabelLearning': 'Learning',
      'statusInitializing': 'Initializing safety monitor...',
      'statusGpsOff':
          'GPS is off. Turn on location to capture live area data.',
      'statusLocationDeniedForever':
          'Location permission permanently denied. Enable it in App Settings.',
      'statusLocationPermissionRequired':
          'Location permission required for realtime safety monitoring.',
      'statusGpsConnected': 'GPS connected. Capturing realtime safety data.',
      'statusFetchingIntelligence': 'Fetching area safety intelligence...',
      'statusLiveStreamPaused': 'Live location stream paused.',
      'statusLiveIntelligenceActive':
          'Live safety intelligence active for your area.',
      'statusNearbyServicesLoaded':
          'Nearby emergency services loaded from live map data.',
      'statusAreaAssessedLocal':
          'Area safety assessed from live location and local signals.',
      'statusCannotReachServer':
          'Cannot reach Suraksha server. Set LAN_BASE_URL in .env to your PC IP.',
      'statusLearningDailyRoute':
          'Learning daily route pattern from live GPS.',
      'statusMapRouteCleared': 'Map route cleared. Daily route guard continues.',
      'statusSafetyConfirmed': 'Safety confirmed. Route monitoring continues.',
      'statusRouteHistoryReset': 'Route history reset. Learning starts again now.',
      'statusSafeRouteChanged': 'Safe route changed. Are you safe?',
      'statusMonitoringMapRouteTo':
          'Monitoring safest map route to {name}.',
      'statusFollowingMapRoute': 'Following selected safest map route.',
      'statusFollowingMapRouteTo':
          'Following selected safest map route to {name}.',
      'statusMovedAwayMapRoute':
          'You moved away from the selected safest map route. Are you safe?',
      'statusLearningTravelRoutines': 'Learning your daily travel routines.',
      'statusWatchingCommutePattern': 'Watching for a known commute pattern.',
      'statusMovedAwayUsualRoute':
          'You moved away from your usual route. Are you safe?',
      'statusFollowingLearnedRoute':
          'Following your learned safer daily route.',
      'statusSafetyCheckEnded':
          'Safety check ended. Route monitoring continues.',
      'statusInitializingMap': 'Initializing map services...',
      'statusLocationServiceDisabled': 'Location service is disabled.',
      'statusLocationPermissionDenied': 'Location permission denied.',
      'statusDestinationReached': 'Destination reached',
      'statusLoadingBestRoute': 'Loading best route...',
      'statusRoadRoutingUnavailable':
          'Road routing unavailable (missing Maps API key).',
      'statusRoadRouteFallback':
          'Road route unavailable, showing direct line fallback.',
      'routeFactorSelectedMapRoute': 'Selected safest map route',
      'routeFactorStrongCommute': 'Strong commute pattern',
      'routeFactorRepeatedDaily': 'Repeated daily pattern',
      'routeFactorNoMatchingRoutine': 'No matching routine for this trip yet',
      'routeProgressStrongCommute':
          'Strong commute pattern ({trips} trips learned)',
      'routeProgressProvisional':
          'Provisional pattern ({trips}/{need} trips)',
      'routeProgressRecordingTrip':
          'Recording trip · {need} more GPS points needed',
      'routeProgressTakeUsualRoute':
          'Take your usual route twice to build a guard pattern',
      'routeProgressSavedTrips':
          'Saved {trips} trips · need matching time & corridor',
      'routeProgressRoutinesWaiting':
          '{count} routine(s) saved · waiting for match',
      'routeChangedNotificationTitle': 'Route changed — are you safe?',
      'routeChangedNotificationBody':
          'You left your usual route. Open Suraksha and tap I\'m safe within {seconds}s.',
      'cyberReasonCredentialRequest': 'Sensitive credential request found.',
      'cyberReasonPaymentPressure':
          'Payment or account pressure indicators found.',
      'cyberReasonBlackmail': 'Blackmail/extortion indicators found.',
      'cyberThreatNoIndicators': 'No strong local indicators found.',
      'cyberActionNoOtp': 'Do not share OTP/passwords',
      'cyberActionSaveEvidence': 'Save evidence',
      'cyberActionVerifyOfficial': 'Verify from official source',
      'cyberTipNeverPayBlackmail': 'Never pay blackmailers',
      'cyberTipReport1930': 'Report financial fraud on 1930',
      'cyberTipBlockSenders': 'Block suspicious senders',
      'cyberRiskHigh': 'HIGH',
      'cyberRiskMedium': 'MEDIUM',
      'cyberRiskLow': 'LOW',
      'learnPasswordTitle': 'Password Safety',
      'learnPasswordSummary':
          'Create strong passwords and protect recovery channels.',
      'learnPasswordTip1': 'Use a password manager.',
      'learnPasswordTip2': 'Enable two-factor authentication.',
      'learnPasswordTip3': 'Do not reuse passwords.',
      'learnPasswordQuiz': 'Is password reuse safe?',
      'learnDatingTitle': 'Online Dating Safety',
      'learnDatingSummary':
          'Recognize coercion, fake identities and image-based abuse risks.',
      'learnDatingTip1': 'Video verify carefully.',
      'learnDatingTip2': 'Do not share intimate media.',
      'learnDatingTip3': 'Meet only in public places.',
      'learnDatingQuiz': 'Should you send money to a new online match?',
      'learnQuizNo': 'No',
      'learnQuizYes': 'Yes',
      'deepfakeTitle': 'Deepfake & Morphed Image Emergency Support',
      'deepfakeSectionWhatTitle': 'What are deepfakes?',
      'deepfakeSectionWhatBody':
          'Manipulated media that can falsely show a person in fake photos, audio or videos.',
      'deepfakeSectionDoTitle': 'What to do immediately',
      'deepfakeSectionDoBody':
          'Save screenshots, URLs and sender IDs. Do not pay or negotiate. Report to cybercrime.gov.in.',
      'deepfakeSectionEvidenceTitle': 'Evidence preservation',
      'deepfakeSectionEvidenceBody':
          'Keep original files, timestamps, platform links and transaction details.',
      'helplineCyberCrime': 'Cyber Crime Helpline',
      'helplinePoliceEmergency': 'Police Emergency',
      'notAvailableShort': 'N/A',
      'contributingFactorsTitle': 'Contributing factors',
      'recommendedActionsTitle': 'Recommended actions',
      'priorityCritical': 'CRITICAL',
      'priorityCaution': 'CAUTION',
      'priorityInfo': 'INFO',
      'timeJustNow': 'Just now',
      'timeMinutesAgo': '{count}m ago',
      'timeHoursAgo': '{count}h ago',
      'timeDaysAgo': '{count}d ago',
      'alertCategoryUpcomingRisk': 'Upcoming Risk Zone',
      'alertCategoryVerifiedIncident': 'Verified Incident Report',
      'alertCategoryAreaIncidentStatus': 'Area Incident Status',
      'alertCategoryRoadLighting': 'Road Lighting',
      'alertCategoryCrowdActivity': 'Crowd Activity',
      'alertCategoryGridRisk': 'Grid Risk Model',
      'alertCategoryDistrictCrime': 'District Crime Context',
      'alertCategoryEmergencyInfra': 'Emergency Infrastructure',
      'alertCategoryCommunitySafeRoute': 'Community Safe Route',
      'alertCategoryAreaSafety': 'Area Safety',
      'alertCategoryPublicTransport': 'Public Transport',
      'alertCategoryPublicTransportNetwork': 'Public Transport Network',
      'alertCategoryPedestrianActivity': 'Pedestrian Activity',
      'alertCategoryRegionNotice': 'Region Notice',
      'alertSummaryUpcomingRisk': 'Elevated risk conditions are expected ahead.',
      'alertActionUpcomingRisk':
          'Slow down, stay alert, and consider an alternate route.',
      'alertSummaryIncidentCategory':
          '{category} report recorded nearby in {region}.',
      'alertSummaryIncidentGeneric':
          'Recent verified incident recorded nearby.',
      'alertActionVerifiedIncident':
          'Keep belongings close, avoid phone use in isolated spots, and stay aware.',
      'alertDisclaimerSurakshaReports':
          'Based on verified Suraksha user incident reports. Not official police records.',
      'alertSummaryNoIncidents':
          'No verified Suraksha incident reports in the last 72 hours near this location in {region}.',
      'alertActionNoIncidents':
          'No recent app-reported incidents nearby. Continue monitoring and stay alert in low-traffic zones.',
      'alertDisclaimerNoIncidents':
          'Absence of app reports does not guarantee zero crime. Official data may differ.',
      'alertSunsetCivilTwilight': 'after civil twilight',
      'alertSunsetNightHours': 'during night hours',
      'alertSummaryUnlitNearby':
          'OpenStreetMap shows unlit road segments within {meters} m. Conditions are {sunset}.',
      'alertSummaryMostlyLit':
          'OpenStreetMap lighting tags suggest mostly lit corridors nearby. Reduced visibility still applies {sunset}.',
      'alertSummaryDarkLimited':
          'It is dark in {region}. Street lighting data is limited for this stretch.',
      'alertActionRoadLighting':
          'Stay on well-lit main roads. Use torch if needed and avoid shadowed paths.',
      'alertDisclaimerLighting':
          'Lighting inferred from sunset times. OSM road lighting tags may be incomplete.',
      'alertSummaryCrowdHigh':
          'Elevated anonymous app activity nearby ({pings} pings in 2 h across {cells} cells).',
      'alertSummaryCrowdModerate':
          'Moderate anonymous app activity nearby ({pings} pings in 2 h).',
      'alertSummaryCrowdVeryLow':
          'Very low anonymous app activity detected nearby in the last 2 hours.',
      'alertSummaryCrowdLow':
          'Low anonymous app activity nearby ({pings} pings in 2 h).',
      'alertActionCrowdVeryLowDark':
          'Fewer people may be around. Prefer populated, well-lit routes.',
      'alertActionCrowdGeneral':
          'Crowd patterns are one signal among many—stay situationally aware.',
      'alertDisclaimerCrowd':
          'Based on anonymous Suraksha app activity pings—not live footfall sensors.',
      'alertSummaryGridRisk':
          '{label} for this ~1 km grid ({count30d} incident(s) in 30d, {count7d} in 7d).',
      'alertActionGridElevated':
          'Historical incident patterns in this grid are elevated—stay alert and prefer main roads.',
      'alertActionGridModerate':
          'Grid history is moderate. Continue monitoring live alerts.',
      'alertDisclaimerGrid':
          'Statistical grid model based on historical incident patterns.',
      'alertSummaryDistrictCrime':
          'Nashik district open-data reference ({period}): ~{rate} reported incidents per 100k population. Area-level context only.',
      'alertActionDistrictCrime':
          'Use this as regional background—not a live pinpoint crime alert for your exact location.',
      'alertDisclaimerDistrictCrime':
          'District-level open data context only.',
      'alertSummaryEmergencyInfra':
          'Nearby support scan lists {police} police, {hospitals} hospital/clinic, and {fuel} fuel station features within {radius} km of you.',
      'alertActionEmergencySparse':
          'Emergency support is sparse here. Keep SOS armed and share live location.',
      'alertActionEmergencyAvailable':
          'Mapped emergency infrastructure is available nearby if needed.',
      'alertDisclaimerEmergencyInfra':
          'Combined from OSM, Google Places, and Suraksha authority mappings. Availability may vary.',
      'alertSummaryEmergencyLimited':
          'Limited mapped police, hospital, or responder coverage near this location in Nashik.',
      'alertActionEmergencyLimited':
          'Keep SOS armed. Inform an emergency contact of your location before moving further.',
      'alertDisclaimerEmergencyLimited':
          'Derived from Suraksha + OpenStreetMap coverage. May not list all facilities.',
      'alertSummarySafeCorridor':
          '{count} community-verified safe corridor(s) identified near your route.',
      'alertActionSafeCorridor':
          'Open the Safety Map to follow the highlighted community-verified path.',
      'alertActionAreaHighRisk':
          'Arm SOS, share live location with a trusted contact, and consider an alternate route.',
      'alertActionAreaReview':
          'Review the reasons below and follow recommended actions.',
      'alertActionAreaManageable':
          'Conditions look manageable. Continue monitoring nearby updates.',
      'alertActionAreaStayAlert':
          'Stay alert, share live location, and keep SOS ready.',
      'alertActionAreaSafe':
          'No strong risk signals detected. Continue with normal awareness.',
      'alertSummaryAreaSafeVerified':
          'This area appears safe right now based on the live signals we can verify.',
      'alertSummaryPublicTransport':
          'Auto rickshaws, MSRTC buses, and taxis typically serve main Nashik corridors. Availability varies by time and route.',
      'alertActionPublicTransport':
          'Use main roads and busy junctions for quicker access to autos, buses, or taxis.',
      'alertDisclaimerPublicTransport':
          'General Nashik transport guidance—not live transit API data. Check locally for current service.',
      'alertSummaryPublicTransportNetwork':
          'Auto rickshaws, buses, taxis, and other local transport options are available around your current location.',
      'alertActionPublicTransportNetwork':
          'Head to a main road or busy junction for the quickest pickup.',
      'alertSummaryLightingLateNight':
          'Streets may be poorly lit after midnight around your current area.',
      'alertSummaryLightingEvening':
          'Reduced visibility after 7 PM. Street lighting may be inconsistent nearby.',
      'alertSummaryPedestrianLateNight':
          'Very low pedestrian activity is expected after midnight in this area.',
      'alertSummaryPedestrianNight':
          'Pedestrian footfall typically reduces after 8 PM in this corridor.',
      'alertSummaryPedestrianDay':
          'Normal pedestrian activity is expected during daytime hours near you.',
      'alertActionPedestrianNight':
          'Avoid isolated routes and stay where people are visibly present.',
      'alertActionPedestrianDay':
          'Area activity looks normal. Continue with standard precautions.',
      'alertSummaryOutsideRegion':
          'Phase 1 safety intelligence is optimized for {region}. You appear outside the mapped region—some signals may be limited.',
      'alertActionOutsideRegion':
          'Move within Nashik for full OSM, crowd, and incident fusion coverage.',
      'alertDisclaimerNashik':
          'Safety intelligence for the Nashik region. Signals may be incomplete.',
      'alertReasonSeriousViolentCrime':
          'Serious violent crime has been reported nearby.',
      'alertReasonCrimeSignalsElevated':
          'Crime-related signals are elevated near this location.',
      'safetyReasonSupportNearby':
          'Trusted emergency support is available nearby.',
      'safetyReasonPlentyEmergencyServices':
          'There are plenty of emergency services present in this area.',
      'safetyReasonNoCrimesReported':
          'No crimes reported in this area for now.',
      'safetyReasonGoodDaytimeFootfall':
          'There is considerable footfall and crowd on nearby roads, which helps this area feel safer during the day.',
      'safetyReasonRegisteredMurder':
          'Registered murder case(s) have been reported in this area.',
      'safetyReasonRegisteredHalfMurder':
          'Registered attempt-to-murder or half-murder case(s) have been reported in this area.',
      'safetyReasonRegisteredDrug':
          'Registered drug-related case(s) have been reported in this area.',
      'safetyReasonRegisteredRobbery':
          'Registered robbery case(s) have been reported in this area.',
      'safetyReasonRegisteredTheft':
          'Registered theft case(s) have been reported in this area.',
      'safetyReasonRegisteredChainSnatching':
          'Registered chain-snatching case(s) have been reported in this area.',
      'safetyReasonRegisteredAssault':
          'Registered assault or harassment case(s) have been reported in this area.',
      'safetyReasonNightTraffic':
          'Road traffic and movement patterns suggest extra caution after 7 PM.',
      'safetyReasonNormalFootfall':
          'Normal pedestrian activity suggests the area is not isolated.',
      'safetyReasonGoodLighting':
          'Lighting and infrastructure signals look steady in this area.',
      'safetyReasonLowRiskSignals':
          'No strong risk signals are currently being detected.',
      'safetyReasonDrugActivity':
          'Recent drug-related activity reported in this area.',
      'safetyReasonChainSnatching':
          'Chain-snatching cases have been reported nearby.',
      'safetyReasonTheftProne':
          'This stretch is known for theft-related incidents.',
      'safetyReasonHarassmentReports':
          'Harassment or assault reports have been recorded nearby.',
      'safetyReasonPoorLighting':
          'Poor street lighting may reduce visibility here.',
      'safetyReasonLowFootfall':
          'Low pedestrian activity makes this area feel isolated.',
      'safetyReasonCrimeActivity':
          'Incident activity remains elevated in the surrounding area.',
      'safetyReasonLimitedSupport':
          'Limited nearby emergency support points may slow rapid assistance.',
      'safetyReasonNightRisk':
          'Night-time conditions reduce visibility and public activity.',
      'safetyReasonGpsLimited':
          'Live location precision is limited; assessment may update as GPS improves.',
      'safetyReasonUnsafeNightlife':
          'Unsafe nightlife or red-light activity may increase risk here.',
      'safetyReasonGeneralCaution':
          'Additional caution is advised in this area.',
      'safetyReasonLimitedData':
          'Verified live area data is limited — stay extra alert here.',
      'routeVerdictChanged': 'Route changed',
      'routeVerdictChangedSummary':
          'You moved away from your usual route. Please confirm you are safe.',
      'routeVerdictLearning': 'Learning route',
      'routeVerdictLearningSummary':
          'Daily Route Guard is learning your travel patterns from live GPS.',
      'routeVerdictOnTrack': 'On usual route',
      'routeVerdictOnTrackSummary':
          'You appear to be following your learned safer daily route.',
      'routeVerdictCaution': 'Route caution',
      'routeVerdictCautionSummary':
          'Some route conditions need extra attention right now.',
      'routeVerdictAlert': 'Route alert',
      'routeVerdictAlertSummary':
          'Your current route may not match your usual safer pattern.',
      'refresh': 'Refresh',
      'openMap': 'Open map',
      'resetHomeWorkplaceRouteLearning': 'Reset home-workplace route learning',
      'homeWorkplaceRouteLearningReset': 'Home-workplace route learning reset.',
      'safetyCheckEndsIn': 'Safety check ends in',
      'unlessYouConfirm': 'unless you confirm.',
      'imSafe': 'I am safe',
      'routeGuardNeedHelp': 'Need help',
      'statusRouteGuardEscalated':
          'No safety confirmation received. Emergency SOS was started.',
      'statusRouteGuardHelpRequested':
          'Emergency SOS started from route guard.',
      'pleaseFillAllRequiredDetails': 'Please fill all required details.',
      'complaintSubmittedSuccessfully': 'Complaint submitted successfully.',
      'submissionFailedTryAgain': 'Submission failed. Please try again.',
      'openDetailedPoshActGuide': 'OPEN DETAILED POSH ACT GUIDE',
      'clearPreviousQuizToUnlockThisLevel':
          'Clear the previous quiz to unlock this level.',
      'previous': 'Previous',
      'retryQuiz': 'Retry quiz',
      'pleaseAnswerEveryQuestionFirst': 'Please answer every question first.',
      'pleaseAnswerThisQuestionBeforeContinuing':
          'Please answer this question before continuing.',
      'currentLevel': 'Current level',
      'detailedPoshActGuide': 'Detailed POSH Act Guide',
      'cyberLawHubTitle': 'Cyber Crime Law Library',
      'cyberLawDeepfakeFullGuide': 'Full deepfake legal guide',
      'cyberLawHubSubtitle': 'Know your rights. Know the law. Know how to fight back.',
      'cyberLawHelplineTitle': 'Emergency Helplines',
      'cyberLawHelplineDesc': 'Cyber Crime: 1930  |  Women: 181  |  Child: 1098  |  Police: 112',
      'cyberLawOverviewHeader': 'Overview',
      'cyberLawActsHeader': 'Applicable Laws & Sections',
      'cyberLawPunishmentHeader': 'Legal Punishment',
      'cyberLawWhatToDoHeader': 'If You Are a Victim',
      'cyberLawReportHeader': 'Where to Report',
      'authEnterEmailPhonePassword': 'Please enter email/phone and password.',
      'authLoginFailed': 'Login failed. Please try again.',
      'authDatabaseUnavailable':
          'Server database is temporarily unavailable. Please wait a moment and try again.',
      'authVerificationFailed': 'Verification failed. Try again.',
      'authFillRequiredFields':
          'Please fill all required fields (password at least 8 characters).',
      'authSignupFailed': 'Signup failed. Please try again.',
      'logoutBeforeNewSignup':
          'Log out of your current account before creating a new one.',
      'authPasswordMinLength': 'Password must be at least 8 characters.',
      'authPasswordRequirements':
          'Use at least 8 characters with a letter and a number.',
      'authTooManyRequests': 'Too many attempts. Try again in {seconds} seconds.',
      'authRetryAfterSeconds': '{message} Try again in {seconds}s.',
      'passwordReqMinLength': 'At least 8 characters',
      'passwordReqLetter': 'Contains a letter',
      'passwordReqNumber': 'Contains a number',
      'passwordReqConfirmMatch': 'Passwords match',
      'passwordStrengthWeak': 'Weak password',
      'passwordStrengthFair': 'Fair password',
      'passwordStrengthGood': 'Good password',
      'passwordStrengthStrong': 'Strong password',
      'signupConsentRequired':
          'Accept the terms, privacy policy, and sensitive data consent to continue.',
      'signupAcceptTermsPrefix': 'I accept the ',
      'signupTermsLink': 'Terms of Service',
      'signupAcceptPrivacyPrefix': 'I accept the ',
      'signupPrivacyLink': 'Privacy Policy',
      'signupSensitiveConsent':
          'I consent to sensitive processing for safety features',
      'signupSensitiveConsentSubtitle':
          'Location, SOS, medical vault, and distress monitoring are optional and can be controlled later in Profile.',
      'signupTermsTitle': 'Terms of Service',
      'signupTermsBody':
          'Suraksha provides safety tools and informational guidance only. It does not guarantee emergency response. Use official emergency numbers when in immediate danger.',
      'signupPrivacyTitle': 'Privacy Policy',
      'signupPrivacyBody':
          'We process account, location, medical, and incident data only to provide safety features you enable. You can export or delete your data from Profile > Account privacy.',
      'signedInDevicesTitle': 'Signed-in devices',
      'signedInDevicesSubtitle':
          'These devices can refresh your session. Revoke any device you no longer use.',
      'sessionsEmpty': 'No other active sessions found.',
      'sessionsLoadFailed': 'Could not load signed-in devices.',
      'sessionsCannotRevokeCurrent': 'Use logout to end this device session.',
      'sessionRevoked': 'Device session revoked.',
      'sessionsRevokedOthers': 'Signed out {count} other device(s).',
      'sessionsRevokeOthers': 'Sign out other devices',
      'sessionsRevokeAllTitle': 'Sign out everywhere?',
      'sessionsRevokeAllMessage':
          'This ends every active session, including this device.',
      'sessionsRevokeAllConfirm': 'Sign out all devices',
      'currentDevice': 'This device',
      'otherDevice': 'Other device',
      'unknownDevice': 'Unknown device',
      'accountPrivacyTitle': 'Account privacy',
      'accountPrivacySubtitle':
          'Download your data or delete specific records stored for your account.',
      'privacyDownloadTitle': 'Download data',
      'privacyDownloadAction': 'Copy account export',
      'privacyDownloadSubtitle':
          'Copies a JSON snapshot of your profile and linked records to the clipboard.',
      'privacyExportCopied': 'Account export copied to clipboard.',
      'privacyDeleteDataTitle': 'Delete stored data',
      'privacyDeleteLocation': 'Delete location data',
      'privacyDeleteLocationSubtitle':
          'Clears last-known location and live location history.',
      'privacyDeleteLocationDone': 'Location data deleted.',
      'privacyDeleteMedical': 'Delete medical data',
      'privacyDeleteMedicalSubtitle':
          'Clears blood group, allergies, conditions, and medications on your profile.',
      'privacyDeleteMedicalDone': 'Medical data deleted.',
      'privacyDeleteIncidents': 'Delete incident reports',
      'privacyDeleteIncidentsSubtitle': 'Removes incident reports linked to your account.',
      'privacyDeleteIncidentsDone': 'Incident reports deleted.',
      'privacyDeleteEvidence': 'Delete evidence records',
      'privacyDeleteEvidenceSubtitle':
          'Removes cybercrime and media evidence linked to your account.',
      'privacyDeleteEvidenceDone': 'Evidence records deleted.',
      'privacyDeleteAccountTitle': 'Delete account',
      'privacyDeleteAccountMessage':
          'This permanently deletes your account and associated server records. Type DELETE to confirm.',
      'privacyDeleteAccountConfirmLabel': 'Type DELETE',
      'privacyDeleteAccountConfirm': 'Delete my account',
      'privacyDeleteAccountDone': 'Account deleted.',
      'privacyActionFailed': 'Could not complete that privacy action.',
      'authResetPasswordFailed': 'Could not reset password. Try again.',
      'authRequestTimedOut':
          'Request timed out. Check your connection and try again.\nServer: {server}',
      'authCouldNotReachServer':
          'Could not reach server at {server}. Ensure backend is running and phone/PC use the same Wi‑Fi.',
      'networkRequestFailed': 'Network request failed',
      'invalidDetails': 'Invalid details.',
      'networkRequestTimedOut': 'Request timed out. Please try again.',
      'profileUserNamePlaceholder': 'User Name',
      'profileEmailPlaceholder': 'email@example.com',
      'emergencyContactDefault': 'Emergency Contact',
      'routeGuardMetersFromPattern': '{meters} m from pattern',
      'routeGuardMapPoints': '{count} map points',
      'routeGuardRouteLogs': '{count} route logs',
      'countdownMinutesSeconds': '{minutes}m {seconds}s',
      'distressPhraseDetected': 'Distress phrase detected',
      'distressMatchedPhrase': 'Matched: {phrase}',
      'distressScreamConfidence': 'Scream confidence: {percent}%',
      'emergencyFetchingLocation': 'Fetching location...',
      'emergencyLiveFeedActive': 'Live Feed Active ({time})',
      'emergencyLiveTransmissionStarting': 'Starting live transmission...',
      'emergencyLiveTransmissionPaused': 'Live transmission paused',
      'dashboardSosLabel': 'SOS',
      'sosConfirmTitle': 'Activate emergency SOS?',
      'sosConfirmMessage':
          'Suraksha will alert your saved emergency contacts, attempt to send an SMS, and share a live tracking link. This does not automatically dispatch police or an ambulance. Call 112 if you need official emergency help.',
      'sosConfirmMessageSmsOnly':
          'Suraksha will alert your saved emergency contacts and attempt to send an SMS. Live tracking links are disabled in this build. This does not automatically dispatch police or an ambulance. Call 112 if you need official emergency help.',
      'sosConfirmMessageLiveOnly':
          'Suraksha will alert your saved emergency contacts and share a live tracking link. Automatic SMS is disabled in this build. This does not automatically dispatch police or an ambulance. Call 112 if you need official emergency help.',
      'sosConfirmMessageMinimal':
          'Suraksha will activate emergency mode for your saved contacts. Automatic SMS and live tracking links are disabled in this build. Call 112 if you need official emergency help.',
      'activateSos': 'Activate SOS',
      'a11yOpenEmergencyMode': 'Open emergency mode. SOS is active.',
      'a11ySendMessage': 'Send message',
      'mapHeatmapLegend':
          'Colored map areas show relative risk. Use the score, risk label, and factors below — not color alone.',
      'featureUnavailable': 'This feature is currently unavailable.',
      'featureFlagDisabledHint':
          'This capability is turned off in this build.',
      'partialDeliveryBanner':
          'Partial success: some emergency alerts were delivered.',
      'sosSafeConfirmTitle': 'Are you safe now?',
      'sosSafeConfirmMessage':
          'This will end live tracking and attempt to send an “I’m safe” message to your emergency contacts.',
      'keepSosActive': 'Keep SOS active',
      'confirmSafe': 'I am safe',
      'sosDeliveryWaiting': 'Waiting',
      'sosDeliverySending': 'Sending…',
      'sosDeliverySent': 'Sent',
      'sosDeliveryPartial': 'Partially sent',
      'sosDeliveryFailed': 'Failed',
      'sosDeliveryUnavailable': 'Unavailable',
      'sosServerAlert': 'Server alert',
      'sosSmsAlert': 'Contact SMS',
      'sosTrackingLinkCopied': 'Live tracking link copied',
      'copyLiveTrackingLink': 'Copy tracking link',
      'openSmsComposer': 'Open SMS',
      'primaryEmergencyContact': 'Primary emergency contact',
      'sendTestSms': 'Send test SMS',
      'makePrimaryContact': 'Make primary contact',
      'distressConsentTitle': 'Enable automatic safety monitoring?',
      'distressMicrophoneConsentBody':
          'Suraksha will continuously use the microphone to detect possible screams or distress phrases. Monitoring uses battery and may produce false alarms. A 10-second countdown lets you cancel before SOS. Android may ask you to exempt Suraksha from battery optimization. Start with Test mode and stop monitoring at any time.',
      'distressImpactConsentBody':
          'Suraksha will monitor motion sensors for a possible severe impact. False alarms are possible. A 10-second countdown lets you mark “Not an emergency” before SOS. Start with Test mode and stop monitoring at any time.',
      'enableMonitoring': 'Enable monitoring',
      'continue': 'Continue',
      'distressBatteryRestrictedWarning':
          'Battery optimization may stop background monitoring. Allow unrestricted battery use in Android settings.',
      'distressLowerSensitivityHint':
          'Several false alarms were recorded. Consider lowering sensitivity.',
      'impactSensitivity': 'Impact sensitivity',
      'impactTestMode': 'Impact test mode',
      'impactTestModeSubtitle':
          'Detect impacts without sending an SOS.',
      'safetyMonitoringActive': 'Safety monitoring is active',
      'microphoneMonitor': 'Microphone',
      'impactMonitor': 'Impact sensor',
      'stopMonitoring': 'Stop',
      'notAnEmergency': 'Not an emergency',
      'openSettings': 'Open settings',
      'distressBatteryGuidanceTitle': 'Allow unrestricted battery use?',
      'distressBatteryGuidanceBody':
          'Android battery optimization can pause microphone monitoring in the background. Suraksha will ask the system to exempt this app so safety monitoring can keep running. You can change this later in settings.',
      'distressTestScreamFeedback':
          'Test mode: possible scream detected. No SOS was sent.',
      'distressTestPhraseFeedback':
          'Test mode: distress phrase detected. No SOS was sent.',
      'impactTestDetectionFeedback':
          'Test mode: impact detected. No SOS was sent.',
      'dashboardPoshLabel': 'POSH',
      'communityAlertStayAwareFallback':
          'Review nearby conditions on the map and stay aware while moving.',
      'poshQuizStudySubtitle':
          'Study the full framework first, then clear three quiz levels to unlock your certificate.',
      'poshQuizAllLevelsCleared': 'All levels cleared. Your certificate is ready.',
      'poshQuizQuestionsCount': '{count} questions',
      'poshQuizMixedMcq': 'Mixed MCQ',
      'poshQuizSingleChoice': 'Single choice',
      'poshQuizQuestionProgress': 'Question {current} of {total}',
      'poshQuizAnsweredCount': '{count} answered',
      'poshQuizCertificateEarned':
          'You cleared all three quiz levels and earned your certificate.',
      'poshQuizNextLevelUnlocked': 'Great work. The next level is now unlocked.',
      'poshQuizReviewScore':
          'You scored {score}/{total}. Review the study section and retry this level.',
      'poshComplaintTimedOut': 'The complaint request timed out. Please try again.',
      'poshComplaintNetworkUnavailable':
          'Network connection unavailable. Please check your internet and try again.',
      'poshComplaintSessionExpired':
          'Your session expired. Please sign in again to submit a complaint.',
      'poshComplaintTitle': 'POSH Workplace Complaint',
      'poshComplaintComplainant': 'Complainant: {name}',
      'poshComplaintPhone': 'Phone: {phone}',
      'poshComplaintEmail': 'Email: {email}',
      'poshComplaintAccused': 'Accused: {name}',
      'poshComplaintWorkplace': 'Workplace: {name}',
      'poshComplaintIncidentDate': 'Incident Date: {date}',
      'poshComplaintIncidentLocation': 'Incident Location: {location}',
      'poshComplaintWitnesses': 'Witnesses: {witnesses}',
      'poshComplaintDetails': 'Complaint Details: {details}',
      'cyberNoSummaryAvailable': 'No summary available.',
      'cyberReportGenerated': 'Report generated.',
      'cyberReportDefaultTitle': 'Cyber Report',
      'cyberReportedStatus': 'Reported',
      'cyberEvidenceLabel': 'Evidence',
      'cyberOtherCategory': 'Other',
      'cyberDeepfakeAwareness': 'Deepfake Awareness',
      'cyberHelpline': 'Helpline',
      'cyberInformation': 'Information',
      'cyberShareComplaintSubject': 'Suraksha cyber crime complaint',
      'cyberShareComplaintBody': 'Cyber crime complaint PDF generated by Suraksha.',
      'cyberShareEvidenceSubject': 'Suraksha cyber evidence',
      'cyberShareEvidenceBody': 'Cybercrime evidence exported from Suraksha.',
      'cyberSharePackageSubject': 'Suraksha evidence package',
      'cyberSharePackageBody': 'Evidence package exported from Suraksha vault.',
      'medicalDefaultBloodGroup': 'O Positive',
      'medicalDefaultAllergies': 'Peanuts, Penicillin',
      'medicalDefaultConditions': 'Asthma',
      'medicalDefaultMedications': 'Inhaler (as needed)',
      'mapInitializingServices': 'Initializing map services...',
      'mapLocationServiceDisabled': 'Location service is disabled.',
      'mapLocationPermissionDenied': 'Location permission denied.',
      'mapUpcomingElevatedRisk': 'Upcoming elevated risk',
      'mapLoadingBestRoute': 'Loading best route...',
      'mapRoadRoutingUnavailable': 'Road routing unavailable (missing Maps API key).',
      'mapNearbyServicesPartialIssues':
          'Nearby services loaded with partial issues: {errors}',
      'mapNearbyServicesLoadFailed':
          'Nearby services could not be loaded. Please try again.',
      'mapPoliceStationFallback': 'Police Station',
      'mapPoliceStationsLabel': 'Police stations',
      'mapHospitalsLabel': 'Hospitals',
      'mapSelectedDestinationFallback': 'selected destination',
      'mapDirectFallbackRouteReason': 'Direct fallback route without Google routing',
      'nearbyGpsUnavailable': 'Live GPS not available. Please keep location ON.',
      'nearbyGoogleMapsKeyMissing':
          'Nearby places are unavailable. Ask your admin to set GOOGLE_MAPS_API_KEY on the Suraksha backend.',
      'nearbyPlacesApiError': 'Places API error: {status}',
      'nearbyUnnamedPlace': 'Unnamed place',
      'nearbyAddressUnavailable': 'Address unavailable',
      'nearbyFetchFailed': 'Unable to fetch nearby places right now. Please try again.',
      'safetyEmergencyServicesWithin1Km': 'Emergency services within 1 km',
      'distressMonitorNotificationTitle': 'Suraksha distress monitor active',
      'distressMonitorNotificationText':
          'Listening for screams and help phrases offline.',
      'distressMonitorTestModeNotification': 'Test mode — no SOS will be sent.',
      'smsLastKnownLocation': 'Last known location: {url}',
      'smsTrackLiveLocation': 'Track live location: {url}',
      'sosActivatedSmsPermissionNeeded':
          'SOS activated. SMS permission is needed to alert your emergency contacts.',
      'sosRealtimeConnectionFailed':
          'Realtime connection failed. Your SOS was saved and contacts may still be notified.',
      'sosMicrophonePermissionNeeded':
          'Microphone permission is needed for scream detection.',
      'communityAlertGoogleMapsKeyMissing': 'Google Maps API key is missing.',
      'communityAlertLoadFailed': 'Unable to load live community alerts right now.',
      'communityAlertTrafficDataLimited': 'Traffic data limited nearby',
      'communityAlertTrafficSampleFailed':
          'Could not sample nearby driving routes from Google Maps.',
      'communityAlertHeavyTraffic': 'Heavy traffic near you',
      'communityAlertHeavyTrafficDetail':
          'Google Maps shows slower-than-usual driving times on nearby routes.',
      'communityAlertTrafficNormal': 'Traffic looks normal nearby',
      'communityAlertTrafficNormalDetail':
          'Driving times on sampled nearby routes look typical for this time.',
      'communityAlertRouteBlockage': 'Possible route blockage or detour',
      'communityAlertRouteBlockageDetail':
          'Some sampled routes show unusually long delays that may indicate blockage.',
      'communityAlertTransportAvailable': 'Public transport network available',
      'communityAlertTransportAvailableDetail':
          'Bus stops, metro, or train stations were found near your location.',
      'communityAlertLowActivity': 'Low activity area detected',
      'communityAlertLowActivityDetail':
          'Fewer active public places were detected around you right now.',
      'communityAlertSilentZone': 'Silent-zone context nearby',
      'communityAlertSilentZoneDetail':
          '{count} hospitals, schools, or court locations found around you.',
      'communityAlertLightingStrong': 'Lighting looks strong nearby',
      'communityAlertLightingStrongDetail':
          'Street and public lighting indicators look relatively strong in this area.',
      'communityAlertLightingModerate': 'Lighting looks moderate nearby',
      'communityAlertLightingModerateDetail':
          'Lighting coverage appears moderate; stay alert after dark.',
      'communityAlertLightingLimited': 'Lighting may be limited nearby',
      'communityAlertLightingCoverageLimited': 'Lighting coverage looks limited',
      'communityAlertLightingLimitedDetail':
          'Limited lighting indicators nearby — extra caution advised at night.',
      'communityAlertJustNow': 'Just now',
      'communityAlertMinsAgo': '{minutes} mins ago',
      'communityAlertHoursAgo': '{hours} hours ago',
    },
    'hi': {
      'appTitle': 'सुरक्षा',
      'greetingHello': 'नमस्ते',
      'welcomeBack': 'वापस स्वागत है',
      'signInToContinue': 'अपनी सुरक्षा यात्रा जारी रखने के लिए साइन इन करें',
      'emailOrPhone': 'ईमेल या फोन नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'createAccount': 'खाता बनाएं',
      'signUpToContinue': 'अपनी सुरक्षा यात्रा शुरू करने के लिए साइन अप करें',
      'signUpStep1of2': 'चरण 1 / 2',
      'signUpStep2of2': 'चरण 2 / 2',
      'signUpVerifyPhone': 'अपना ईमेल सत्यापित करें',
      'signUpVerifyPhoneSubtitle':
          'अपना नाम, ईमेल और मोबाइल नंबर दर्ज करें। हम ईमेल पर एक बार का कोड भेजेंगे।',
      'signUpVerifyEmail': 'अपना ईमेल सत्यापित करें',
      'signUpVerifyEmailSubtitle':
          'अपना नाम, ईमेल और मोबाइल दर्ज करें। SEND OTP दबाएँ, फिर ईमेल से मिला 6 अंकों का कोड नीचे लिखें।',
      'signUpCompleteProfile': 'अपनी प्रोफ़ाइल पूरी करें',
      'signUpCompleteProfileSubtitle':
          'खाता बनाने के लिए पासवर्ड सेट करें।',
      'continueToAccountDetails': 'आगे बढ़ें',
      'fullName': 'पूरा नाम',
      'fullNameRequired': 'कृपया अपना पूरा नाम दर्ज करें।',
      'phoneNumber': 'फोन नंबर',
      'phoneNumberInvalid': 'मान्य 10 अंकों का मोबाइल नंबर दर्ज करें।',
      'emailOptional': 'ईमेल',
      'emailInvalid': 'मान्य ईमेल पता दर्ज करें।',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'signUp': 'साइन अप',
      'alreadyHaveAccount': 'पहले से खाता है? साइन इन करें',
      'dontHaveAccount': 'खाता नहीं है? साइन अप करें',
      'passwordsDoNotMatch': 'पासवर्ड मेल नहीं खाते।',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'forgotPasswordTitle': 'पासवर्ड रीसेट करें',
      'forgotPasswordSubtitle':
          'अपना पंजीकृत ईमेल दर्ज करें। हम 6 अंकों का OTP भेजेंगे। जिन खातों में ईमेल नहीं है वे यहां रीसेट नहीं कर सकते।',
      'sendOtp': 'OTP भेजें',
      'resendOtp': 'OTP दोबारा भेजें',
      'resendOtpIn': '{seconds}s में OTP दोबारा भेजें',
      'enterOtp': '6 अंकों का OTP',
      'otpEnterHint':
          'ईमेल में मिला 6 अंकों का कोड यहाँ लिखें। अगर कोड पहले आ चुका है, तो यहीं दर्ज कर आगे बढ़ें।',
      'verifyOtp': 'OTP सत्यापित करें',
      'otpSent': 'OTP आपके ईमेल पर भेजा गया। नीचे दर्ज करें।',
      'otpSendFailed': 'OTP नहीं भेजा जा सका। विवरण जाँचकर फिर कोशिश करें।',
      'otpSendCheckInbox':
          'अगर ईमेल में कोड आया है तो नीचे लिखें। नहीं आया हो तो थोड़ा रुककर Resend दबाएँ।',
      'otpInvalid': '6 अंकों का OTP दर्ज करें।',
      'phoneVerified': 'ईमेल सत्यापित हो गया।',
      'verifyPhoneFirst': 'जारी रखने से पहले OTP से ईमेल सत्यापित करें।',
      'verifyEmailFirst': 'साइन अप से पहले OTP से ईमेल सत्यापित करें।',
      'newPassword': 'नया पासवर्ड',
      'resetPassword': 'पासवर्ड रीसेट करें',
      'passwordResetSuccess': 'पासवर्ड अपडेट हो गया। आप साइन इन हैं।',
      'authSessionExpired': 'आपका सत्र समाप्त हो गया। कृपया फिर साइन इन करें।',
      'emergencyContactsInformed': 'आपातकालीन संपर्कों को सूचित किया गया',
      'liveLocationSharedWith': 'लाइव लोकेशन साझा की गई है:',
      'fetchingLocation': 'स्थान प्राप्त किया जा रहा है...',
      'liveFeedActive': 'लाइव फ़ीड सक्रिय ({time})',
      'startingLiveTransmission': 'लाइव ट्रांसमिशन शुरू हो रहा है...',
      'liveTransmissionPaused': 'लाइव ट्रांसमिशन रुका हुआ है',
      'emergencyModeActive': 'आपातकालीन मोड सक्रिय',
      'helpOnTheWay': 'मदद आ रही है। आपकी लाइव लोकेशन साझा की जा रही है।',
      'currentLocation': 'मौजूदा स्थान',
      'status': 'स्थिति',
      'iAmSafeCancelSos': 'मैं सुरक्षित हूँ - SOS रद्द करें',
      'myProfile': 'मेरा प्रोफाइल',
      'profileSubtitle':
          'अपनी सुरक्षा पहचान, भाषा और आपातकालीन तैयारी संभालें।',
      'profileOverview': 'प्रोफाइल सारांश',
      'profileStatsTitle': 'आपकी सुरक्षा झलक',
      'profileHeroCta': 'तेज़ सहायता के लिए प्रोफाइल को निजी बनाएं।',
      'languageSelectionTitle': 'ऐप भाषा चुनें',
      'darkMode': 'डार्क मोड',
      'darkModeSubtitleOn': 'डार्क ब्लू थीम',
      'darkModeSubtitleOff': 'हल्की शांत थीम',
      'language': 'भाषा',
      'contentLanguage': 'ऐप की सामग्री की भाषा',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिंदी',
      'marathi': 'मराठी',
      'editProfile': 'प्रोफाइल संपादित करें',
      'editPhoneNumber': 'फोन नंबर संपादित करें',
      'addEmergencyContactTitle': 'आपातकालीन संपर्क जोड़ें',
      'editEmergencyContactTitle': 'आपातकालीन संपर्क संपादित करें',
      'editProfileDetails': 'प्रोफाइल विवरण संपादित करें',
      'editMedicalProfile': 'मेडिकल प्रोफाइल संपादित करें',
      'email': 'ईमेल',
      'phone': 'फोन नंबर',
      'relation': 'नाते',
      'loadingNearbySafetyPoints': 'नज़दीकी सुरक्षा बिंदु लोड हो रहे हैं...',
      'unableToFetchLocation':
          'स्थान प्राप्त नहीं किया जा सका। खुले आसमान के पास जाएँ और फिर प्रयास करें।',
      'couldNotFetchYourLocation': 'आपका स्थान प्राप्त नहीं किया जा सका।',
      'youAreHere': 'आप यहाँ हैं',
      'surakshaLiveLocationNotificationTitle': 'सुरक्षा लाइव लोकेशन',
      'surakshaLiveLocationNotificationText':
          'सुरक्षा सुविधाओं के लिए लाइव लोकेशन ट्रैक की जा रही है।',
      'journeyStopped': 'यात्रा बंद की गई',
      'totalRoute': 'कुल मार्ग',
      'stop': 'बंद करें',
      'start': 'शुरू करें',
      'name': 'नाम',
      'bloodGroup': 'ब्लड ग्रुप',
      'bloodGroupSelect': 'ब्लड ग्रुप चुनें',
      'allergies': 'एलर्जी',
      'medicalConditions': 'चिकित्सीय स्थितियां',
      'currentMedications': 'वर्तमान दवाएं',
      'notProvided': 'उपलब्ध नहीं',
      'emergencyContacts': 'आपातकालीन संपर्क',
      'contactsSaved': 'संपर्क सहेजे गए',
      'emergencyContactList': 'आपातकालीन संपर्क सूची',
      'activityLogsTitle': 'लॉग्स',
      'activityLogsTileValue': 'एन्क्रिप्टेड गतिविधि इतिहास (7 दिन)',
      'activityLogsSubtitle':
          'केवल पढ़ने योग्य, एन्क्रिप्टेड गतिविधि रिकॉर्ड। 7 दिन से पुराने हटा दिए जाते हैं। पासवर्ड और OTP कभी संग्रहीत नहीं होते।',
      'activityLogsFrom': 'से',
      'activityLogsTo': 'तक',
      'activityLogsLast24h': 'पिछले 24 घंटे',
      'activityLogsYesterday': 'कल',
      'activityLogsExport': '.txt निर्यात करें',
      'activityLogsEmpty': 'इस समय सीमा में कोई लॉग नहीं।',
      'activityLogsLoadFailed': 'लॉग लोड नहीं हो सके।',
      'activityLogsUnlockReason': 'Suraksha गतिविधि लॉग देखने के लिए अनलॉक करें।',
      'activityLogsExportUnlock': 'गतिविधि लॉग निर्यात करने के लिए अनलॉक करें।',
      'activityLogsUnlockCancelled': 'लॉग्स खोलने के लिए फ़ोन अनलॉक करें।',
      'activityLogsUnlockAction': 'अनलॉक',
      'activityLogsLockMissing': 'लॉग्स खोलने के लिए फ़ोन पर स्क्रीन लॉक सेट करें।',
      'activityLogsTampered': 'यह पंक्ति अखंडता जाँच में विफल रही।',
      'activityLogsEncryptedBadge': 'एन्क्रिप्टेड',
      'activityLogsRetentionBadge': '7-दिन वॉल्ट',
      'activityLogsEventCount': '{count} इवेंट',
      'activityLogsUnlockTitle': 'सुरक्षित गतिविधि वॉल्ट',
      'activityLogsEmptyHint': 'समय सीमा बढ़ाएँ या नई गतिविधि का इंतज़ार करें।',
      'addEmergencyContact': 'आपातकालीन संपर्क जोड़ें',
      'addNewContact': 'नया संपर्क जोड़ें',
      'logoutSession': 'लॉगआउट',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'ok': 'ठीक है',
      'done': 'हो गया',
      'saving': 'सहेजा जा रहा है...',
      'saved': 'सहेजा गया',
      'screamDetection': 'चीख पहचान',
      'screamDetectionEnabled': 'चीख पहचान चालू की गई।',
      'screamDetectionDisabled': 'चीख पहचान बंद की गई।',
      'screamDetectionEnableFailed': 'चीख पहचान चालू नहीं की जा सकी।',
      'distressSensitivity': 'पहचान संवेदनशीलता',
      'distressSensitivitySubtitle':
          'उच्च = धीमी चीख भी; निम्न = कम गलत अलर्ट।',
      'distressSensitivity_low': 'निम्न',
      'distressSensitivity_medium': 'मध्यम',
      'distressSensitivity_high': 'उच्च',
      'distressTestMode': 'टेस्ट मोड (कोई SOS नहीं)',
      'distressTestModeSubtitle':
          'चीख/शब्द पहचानें लेकिन SOS न भेजें। सटीकता जाँच के लिए।',
      'distressLastHeard': 'अंतिम सुना',
      'microphoneSafetyMonitorActive': 'माइक्रोफोन सुरक्षा मॉनिटर चालू है।',
      'microphoneSafetyMonitorInactive':
          'यह बंद रहने पर माइक्रोफोन बंद रहता है।',
      'impactDetection': 'झटका पहचान',
      'impactDetectionEnabled': 'झटका पहचान चालू की गई।',
      'impactDetectionDisabled': 'झटका पहचान बंद की गई।',
      'impactDetectionEnableFailed': 'झटका पहचान चालू नहीं की जा सकी।',
      'motionSensorsActive': 'मोशन सेंसर अचानक झटके पर नज़र रख रहे हैं।',
      'motionSensorsInactive': 'यह बंद रहने पर मोशन सेंसर बंद रहते हैं।',
      'phoneNumberRequired': 'फोन नंबर आवश्यक है।',
      'nameAndPhoneRequired': 'नाम और फोन नंबर आवश्यक हैं।',
      'duplicatePhoneNumberTitle': 'नंबर पहले से सहेजा गया है',
      'duplicatePhoneNumber': 'यह नंबर पहले से सहेजा गया है।',
      'savedLocallyRetryLater':
          'स्थानीय रूप से सहेजा गया। सर्वर सिंक बाद में फिर से कोशिश करेगा।',
      'photoSavedLocally': 'फ़ोटो स्थानीय रूप से सहेजी गई।',
      'profilePhotoUnlockReason':
          'प्रोफ़ाइल फ़ोटो बदलने के लिए अपने फ़ोन को अनलॉक करें।',
      'profilePhotoUnlockCancelled':
          'गैलरी खोलने से पहले PIN, पासवर्ड, फ़िंगरप्रिंट या फेस लॉक से फ़ोन अनलॉक करें।',
      'profilePhotoDeviceLockMissing':
          'पहले अपने फ़ोन पर स्क्रीन लॉक (PIN, पासवर्ड, फ़िंगरप्रिंट या फेस) सेट करें। Suraksha इसके लिए अलग PIN नहीं बनाता।',
      'profilePhotoCropTitle': 'फ़ोटो क्रॉप करें',
      'profilePhotoCropHint':
          'ज़ूम करने के लिए पिंच करें और प्रोफ़ाइल फ़ोटो का क्षेत्र चुनने के लिए खींचें।',
      'profilePhotoCropFailed':
          'यह फ़ोटो क्रॉप नहीं हो सकी। कोई दूसरी छवि आज़माएँ।',
      'serverSyncWillRetryLater': 'सर्वर सिंक बाद में फिर से कोशिश करेगा।',
      'profileSavedTitle': 'प्रोफाइल सहेजा गया',
      'profileSavedMessage': 'आपकी जानकारी सुरक्षित रूप से सहेज ली गई है।',
      'medicalSavedTitle': 'मेडिकल प्रोफाइल सहेजा गया',
      'medicalSavedMessage': 'आपकी मेडिकल जानकारी सफलतापूर्वक अपडेट हो गई है।',
      'contactSavedTitle': 'संपर्क सहेजा गया',
      'contactSavedMessage': 'आपातकालीन संपर्क विवरण सफलतापूर्वक अपडेट हो गए।',
      'draftSavedTitle': 'ड्राफ्ट सहेजा गया',
      'draftSavedMessage': 'आपका ड्राफ्ट इस डिवाइस पर सुरक्षित कर लिया गया है।',
      'emergencyServices': 'आपातकालीन सेवाएं',
      'communityAlerts': 'समुदाय अलर्ट',
      'safetyRegionLabel': 'क्षेत्र',
      'safetyDataDisclaimerTitle': 'डेटा स्रोत',
      'safetyConfidenceSuffix': 'विश्वास',
      'safetySourceOpenStreetMap': 'OpenStreetMap',
      'safetySourceSunset': 'सूर्यास्त API',
      'safetySourceCrowd': 'अज्ञात भीड़',
      'safetySourceSurakshaReports': 'Suraksha रिपोर्ट',
      'safetySourceSurakshaEngine': 'Suraksha इंजन',
      'safetySourceSurakshaCommunity': 'समुदाय सत्यापित',
      'safetySourceRegionalGuidance': 'क्षेत्रीय मार्गदर्शन',
      'safetyDimCrime': 'अपराध',
      'safetyDimInfrastructure': 'रोशनी',
      'safetyDimSupport': 'सहायता',
      'safetyDimVisibility': 'दृश्यता',
      'safetyDimTemporal': 'समय',
      'safetySourceGridModel': 'ग्रिड मॉडल',
      'safetySourceOpenDataDistrict': 'जिला ओपन डेटा',
      'safetyUpdatedAgo': 'अपडेट',
      'aiSummaryFromGemini': 'AI सारांश (Gemini)',
      'aiSummaryFromTemplate': 'AI सारांश (ऑफ़लाइन)',
      'journeySafetyAlerts': 'यात्रा सुरक्षा अलर्ट',
      'journeySafetyAlertsSubtitle':
          'नेविगेशन के दौरान उच्च जोखिम वाले क्षेत्र में प्रवेश पर पुश और इन-ऐप अलर्ट।',
      'notifPrefSos': 'SOS अलर्ट',
      'notifPrefSosSubtitle': 'गंभीर SOS और खतरे संबंधी सूचनाएँ।',
      'notifPrefRoute': 'मार्ग चेतावनियाँ',
      'notifPrefRouteSubtitle': 'डेली रूट गार्ड विचलन अलर्ट।',
      'notifPrefCommunity': 'सामुदायिक अलर्ट',
      'notifPrefCommunitySubtitle': 'आसपास के सामुदायिक सुरक्षा अलर्ट।',
      'notifPrefReminders': 'सुरक्षा रिमाइंडर',
      'notifPrefRemindersSubtitle': 'वैकल्पिक चेक-इन और तैयारी रिमाइंडर।',
      'notifOnboardingTitle': 'आपात में संपर्क में रहें',
      'notifOnboardingBody':
          'Suraksha समय-संवेदनशील सुरक्षा अलर्ट के लिए सूचनाओं का उपयोग करता है। श्रेणियाँ प्रोफ़ाइल में बदल सकते हैं।',
      'notifOnboardingBulletSos': 'SOS और गंभीर खतरा अलर्ट',
      'notifOnboardingBulletRoute': 'मार्ग विचलन चेतावनियाँ',
      'notifOnboardingBulletCommunity': 'आसपास सामुदायिक सुरक्षा अलर्ट',
      'notifOnboardingBulletReminders': 'वैकल्पिक सुरक्षा रिमाइंडर',
      'notifEnableNotifications': 'सूचनाएँ सक्षम करें',
      'notifOpenSettings': 'सिस्टम सेटिंग्स खोलें',
      'notifSkipForNow': 'अभी छोड़ें',
      'notifPermissionDeniedHint':
          'अनुमति बंद है। सूचनाएँ अनुमति देने के लिए सिस्टम सेटिंग्स खोलें।',
      'pleaseWait': 'कृपया प्रतीक्षा करें…',
      'notifDeliveryStatusLabel': 'डिलीवरी: {status}',
      'notifExpiredHandled': 'वह अलर्ट समाप्त हो चुका है और हटा दिया गया।',
      'notifInboxTitle': 'सुरक्षा अलर्ट इनबॉक्स',
      'notifInboxEmpty': 'अभी कोई सक्रिय सुरक्षा अलर्ट नहीं है।',
      'notifInboxOpenSubtitle': 'गंभीर और हाल के अलर्ट की डिलीवरी स्थिति देखें।',
      'journeyRerouteHint': 'अधिक सुरक्षित मार्ग उपलब्ध',
      'tapForAlerts': 'अलर्ट देखने के लिए टैप करें',
      'tapRefreshTryAgain': 'फिर कोशिश के लिए रिफ्रेश टैप करें',
      'loadingLiveAreaAlerts': 'लाइव क्षेत्र अलर्ट लोड हो रहे हैं...',
      'checkingTrafficTransportNearbyActivity':
          'ट्रैफ़िक, परिवहन और आसपास की गतिविधि जाँच रहे हैं',
      'liveAlertsWillAppearHere': 'लाइव अलर्ट यहाँ दिखेंगे',
      'keepGpsOnForRealtimeCommunityUpdates':
          'रीयलटाइम community updates के लिए GPS चालू रखें',
      'locationRequiredTitle': 'स्थान आवश्यक है',
      'locationRequiredMessage':
          'Suraksha को काम करने के लिए GPS और स्थान अनुमति चाहिए। जारी रखने के लिए इन्हें सक्षम करें।',
      'locationAutoRefreshMessage':
          'स्थान सक्षम होने के बाद सेवाएँ स्वतः ताज़ा होंगी।',
      'retryLocation': 'स्थान सेटअप पुनः प्रयास करें',
      'womenHelpline': 'महिला हेल्पलाइन',
      'nearbyServices': 'नज़दीकी सेवाएं',
      'nearbyHospitals': 'नज़दीकी अस्पताल',
      'policeStations': 'पुलिस स्टेशन',
      'nearbyWashrooms': 'नज़दीकी वॉशरूम',
      'nearbyBloodBanks': 'नज़दीकी ब्लड बैंक',
      'nearbyPharmacies': 'नज़दीकी फ़ार्मेसी',
      'nearbyPetrolPumps': 'नज़दीकी पेट्रोल पंप',
      'tapToLoadNearby': 'नज़दीकी सेवाएं लोड करने के लिए बटन दबाएं।',
      'noNearbyPlaces': '5 किमी के दायरे में कोई स्थान नहीं मिला।',
      'safeZoneActive': 'सुरक्षा प्राथमिकता',
      'helloKaveri': 'नमस्ते, कावेरी',
      'openSafetyMap': 'सुरक्षा मानचित्र खोलें',
      'openSafetyMapConfirm': 'क्या आप यह स्थान मानचित्र पर देखना चाहते हैं?',
      'mapOpenChoiceTitle': 'स्थान खोलें',
      'mapOpenChoiceMessage': 'आप इस स्थान को कैसे खोलना चाहते हैं, चुनें।',
      'mapOpenChoiceSuraksha': 'सुरक्षा मानचित्र',
      'mapOpenChoiceGoogle': 'गूगल मैप्स',
      'yes': 'हाँ',
      'no': 'नहीं',
      'couldNotOpenDialer': 'डायलर नहीं खुल सका',
      'policeEmergency': 'पुलिस आपातकालीन',
      'scanningNearbyPlaces': 'नज़दीकी स्थान स्कैन किए जा रहे हैं...',
      'nearbyResultsCount': '{count} नज़दीकी परिणाम',
      'toiletsNoToiletsInArea': 'इस क्षेत्र में कोई शौचालय नहीं मिला।',
      'toiletsNoToiletsInAreaHint':
          'इस क्षेत्र में कोई शौचालय नहीं मिला। खोज त्रिज्या बढ़ाएँ या फ़िल्टर ढीले करें।',
      'toiletsSanitationRegistryEmpty':
          'सैनिटेशन रजिस्ट्री ने यहाँ कोई प्रकाशित शौचालय नहीं दिया।',
      'toiletsSanitationRegistryEmptyHint':
          'टॉयलेट सेवा जुड़ी है, लेकिन इस स्थान के लिए सार्वजनिक API में कोई सैनिटेशन शौचालय प्रकाशित नहीं है। सैनिटेशन एडमिन से GPS के साथ प्रविष्टियाँ प्रकाशित करने को कहें।',
      'toiletsSanitationMissingCoordinates':
          'सैनिटेशन शौचालय हैं, लेकिन मानचित्र निर्देशांक गायब हैं।',
      'toiletsSanitationMissingCoordinatesHint':
          'सैनिटेशन प्लेटफ़ॉर्म ने बिना वैध अक्षांश/देशांतर के शौचालय लौटाए, इसलिए वे मानचित्र पर नहीं दिख सकते। एडमिन पैनल में GPS अपडेट करें।',
      'toiletsSanitationClosedPermissionHint':
          'ध्यान दें: यह एकीकरण केवल खुले शौचालय दिखा सकता है। बंद शौचालय के लिए सैनिटेशन में खुला स्थिति या बंद शौचालय पढ़ने की अनुमति वाली API कुंजी चाहिए।',
      'toiletsLocationUnavailable':
          'स्थान उपलब्ध नहीं है। GPS चालू करें और स्थान अनुमति दें।',
      'toiletsConnectionError':
          'टॉयलेट सेवा तक पहुंच नहीं हो सकी। कृपया फिर से प्रयास करें।',
      'toiletsRefreshing': 'स्वच्छ और उपयोगी सार्वजनिक शौचालय ताज़ा किए जा रहे हैं...',
      'toiletsFoundCount': 'वर्तमान फ़िल्टर के साथ {count} शौचालय मिले',
      'toiletsOnMapCount': 'मानचित्र पर {count} शौचालय',
      'toiletsLoadingNearby': 'नज़दीकी शौचालय लोड हो रहे हैं...',
      'chooseServiceToScanYourArea':
          'अपने वर्तमान क्षेत्र को स्कैन करने के लिए नीचे एक सेवा चुनें।',
      'cyberCrimeProtection': 'साइबर क्राइम सुरक्षा',
      'aiAssist': 'एआई सहायता',
      'report': 'रिपोर्ट',
      'vault': 'वॉल्ट',
      'learn': 'सीखें',
      'deepfake': 'डीपफेक',
      'aiScamFraudAssistantTitle': 'एआई घोटाला और धोखाधड़ी पहचान असिस्टेंट',
      'pasteEvidenceContext':
          'संदिग्ध संदेश, लिंक, चैट या प्रश्न पेस्ट करें। साक्ष्य संदर्भ के रूप में स्क्रीनशॉट संलग्न करें।',
      'suspiciousMessageLabel': 'संदिग्ध संदेश, ईमेल या चैट',
      'pasteFullMessageHereHint': 'पूरा संदेश यहाँ पेस्ट करें...',
      'suspiciousLinksLabel': 'संदिग्ध लिंक',
      'urlHint': 'https://example.com, bit.ly/...',
      'askQuestionLabel': 'एक प्रश्न पूछें',
      'scamQuestionHint': 'क्या यह घोटाला है? क्या यह प्रोफ़ाइल नकली है?',
      'attachScreenshot': 'स्क्रीनशॉट संलग्न करें',
      'analyze': 'विश्लेषण करें',
      'selectIncidentType': 'घटना प्रकार चुनें',
      'attachScreenshotsOrProof': 'स्क्रीनशॉट या लेनदेन प्रमाण संलग्न करें',
      'incidentDescription': 'घटना का विवरण',
      'incidentDetailsHint':
          'क्या हुआ इसका विवरण दें, उपयोगकर्ता नाम, राशि, धमकियाँ और प्लेटफ़ॉर्म।',
      'suspectContactLabel': 'फोन/ईमेल/प्रोफ़ाइल लिंक',
      'suspectContactHint': 'संदिग्ध संपर्क या प्रोफ़ाइल URL',
      'transactionIdLabel': 'लेन-देन आईडी',
      'transactionIdHint': 'यदि वित्तीय धोखाधड़ी हो तो UPI/ref नंबर',
      'incidentTime': 'घटना समय: {time}',
      'pdfReady': 'PDF तैयार',
      'newReport': 'नई रिपोर्ट',
      'saveDraft': 'ड्राफ्ट सहेजें',
      'reportGenerated': 'रिपोर्ट तैयार हुई।',
      'draftSavedOnline': 'ड्राफ्ट ऑनलाइन सहेजा गया।',
      'couldNotSubmitOnline':
          'ऑनलाइन सबमिट नहीं हो सका। कृपया फिर प्रयास करें।',
      'secureEvidenceVault': 'सुरक्षित साक्ष्य वॉल्ट',
      'uploadTagSearchPackageEvidence':
          'साइबर साक्ष्य अपलोड करें, टैग करें, खोजें और पैकेज करें। बैकएंड फ़ाइलें AES एन्क्रिप्टेड हैं।',
      'takeQuiz': 'क्विज़ लें',
      'progressBadge': '{percent}% पूरा | बैज: {badge}',
      'cyberDefender': 'साइबर डिफेंडर',
      'cyberLearner': 'साइबर लर्नर',
      'deepfakeSubtitle':
          'जागरूकता, आपातकालीन प्रतिक्रिया, कानूनी मार्गदर्शन और हेल्पलाइन पहुंच।',
      'deepfakeWarning':
          'यदि कोई मोर्फ़्ड/निजी मीडिया लीक करने की धमकी देता है, तो भुगतान न करें या समझौता न करें। साक्ष्य सुरक्षित रखें और तुरंत रिपोर्ट करें।',
      'emergencyActions': 'आपातकालीन कार्यवाही',
      'call1930': '1930 पर कॉल करें',
      'police100': 'पुलिस 100',
      'cyberPortal': 'साइबर पोर्टल',
      'reportStatusDraft': 'ड्राफ्ट',
      'reportStatusReported': 'रिपोर्ट किया गया',
      'reportStatusUnderInvestigation': 'जांच जारी',
      'reportStatusResolved': 'निपटाया गया',
      'reportStatusLabel': 'स्थिति',
      'cyberPortalGuideTitle': 'cybercrime.gov.in पर दर्ज करें',
      'cyberPortalGuideSubtitle':
          'आपकी Suraksha शिकायत तैयार है। राष्ट्रीय पोर्टल पर दर्ज करने और पावती नंबर यहाँ सहेजने के लिए इस चरणों का पालन करें।',
      'cyberPortalGuideStep1':
          'नीचे दिए बटन से अपनी Suraksha शिकायत PDF सहेजें या साझा करें।',
      'cyberPortalGuideStep2':
          'cybercrime.gov.in खोलें और नागरिक के रूप में साइन इन करें।',
      'cyberPortalGuideStep3':
          'वही घटना विवरण और साक्ष्य संलग्न करके नई साइबर अपराध शिकायत दर्ज करें।',
      'cyberPortalGuideStep4':
          'सरकारी पावती नंबर कॉपी करें और फॉलो-अप के लिए नीचे सहेजें।',
      'cyberPortalCopyComplaint': 'शिकायत पाठ कॉपी करें',
      'cyberPortalComplaintCopied': 'शिकायत पाठ क्लिपबोर्ड पर कॉपी हो गया।',
      'cyberPortalAckLabel': 'सरकारी पावती नंबर',
      'cyberPortalAckHint': 'cybercrime.gov.in से नंबर दर्ज करें',
      'cyberPortalAckTooShort': 'मान्य पावती नंबर दर्ज करें।',
      'cyberPortalSaveAck': 'पावती सहेजें',
      'cyberPortalAckSaved': 'पावती नंबर सहेजा गया।',
      'cyberPortalAckSavedOn': '{number} को {date} पर सहेजा गया।',
      'cyberPortalFiledBadge': 'पोर्टल पर दर्ज',
      'uploadEncryptedEvidence': 'एन्क्रिप्टेड साक्ष्य अपलोड करें',
      'noFilesSelectedYet': 'कोई फ़ाइलें अभी तक चयनित नहीं हुई हैं।',
      'generate': 'जनरेट करें',
      'generatedComplaint': 'उत्पन्न शिकायत',
      'reportSummaryUnavailable': 'रिपोर्ट सारांश उपलब्ध नहीं है।',
      'pdfPayloadGenerated':
          'PDF पेलोड तैयार हुआ। निर्यात एकीकरण बैकएंड उत्तर से सहेज/साझा कर सकता है।',
      'evidenceTitleLabel': 'साक्ष्य शीर्षक',
      'evidenceTitleHint': 'धमकी स्क्रीनशॉट, UPI प्रमाण...',
      'category': 'श्रेणी',
      'private': 'निजी',
      'tags': 'टैग',
      'tagsHint': 'ब्लैकमेल, इंस्टाग्राम, पेमेंट',
      'finish': 'समाप्त',
      'searchVault': 'वॉल्ट खोजें',
      'searchByTitle': 'शीर्षक द्वारा खोजें',
      'noEvidenceFound':
          'कोई साक्ष्य नहीं मिला। अपना सुरक्षित वॉल्ट शुरू करने के लिए साक्ष्य अपलोड करें।',
      'sessionExpiredSignIn': 'सत्र समाप्त। कृपया फिर साइन इन करें।',
      'loginRequiredCyber': 'सुरक्षित साइबर सुविधाओं के लिए फिर लॉगिन करें।',
      'fileTooLarge10Mb': 'फ़ाइल बहुत बड़ी है। अधिकतम 10 MB।',
      'networkServerIssue': 'नेटवर्क या सर्वर समस्या। फिर प्रयास करें।',
      'cyberEvidenceDecryptFailed':
          'यह एन्क्रिप्टेड फ़ाइल नहीं खोली जा सकी। फिर अपलोड करें।',
      'cyberEvidenceServerMissing':
          'सर्वर पर साक्ष्य फ़ाइल नहीं मिली। कृपया इसे फिर अपलोड करें।',
      'couldNotSharePdf': 'PDF साझा नहीं हो सका।',
      'couldNotExportEvidence': 'साक्ष्य पैकेज निर्यात नहीं हो सका।',
      'riskLevel': 'जोखिम स्तर',
      'recommendedActions': 'अनुशंसित कार्य',
      'safetyTips': 'सुरक्षा सुझाव',
      'encrypted': 'एन्क्रिप्टेड',
      'notEncrypted': 'एन्क्रिप्टेड नहीं',
      'linkedToReport': 'रिपोर्ट से जुड़ा',
      'preview': 'पूर्वावलोकन',
      'download': 'डाउनलोड',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'noUnlinkedEvidence': 'वॉल्ट में कोई अनलिंक्ड साक्ष्य नहीं।',
      'minDescriptionChars': 'कम से कम 10 अक्षर का विवरण जोड़ें।',
      'draftPendingDetails': 'ड्राफ्ट रिपोर्ट विवरण लंबित।',
      'evidenceFilesSecured': '{count} साक्ष्य फ़ाइल(एं) वॉल्ट में सुरक्षित।',
      'vaultEvidenceLinked': '{count} वॉल्ट आइटम रिपोर्ट से जुड़े।',
      'summaryStep': 'सारांश',
      'myReports': 'मेरी रिपोर्ट',
      'noSubmittedReportsYet': 'अभी कोई रिपोर्ट नहीं। शिकायत बनाएं।',
      'draft': 'ड्राफ्ट',
      'pickFromGallery': 'गैलरी',
      'pickFile': 'फ़ाइल चुनें',
      'attachFromVault': 'वॉल्ट से',
      'vaultItemsSelected': '{count} वॉल्ट आइटम चयनित',
      'uploadingEvidence': 'साक्ष्य अपलोड हो रहा है {current}/{total}…',
      'selectVaultEvidence': 'वॉल्ट साक्ष्य चुनें',
      'analyzeInputRequired': 'संदेश, लिंक, प्रश्न पेस्ट करें या स्क्रीनशॉट संलग्न करें।',
      'clearScreenshot': 'स्क्रीनशॉट हटाएं',
      'screenshotTextExtracted': 'स्क्रीनशॉट से निकाला गया पाठ',
      'evidenceEncryptedSaved': 'साक्ष्य एन्क्रिप्ट करके सहेजा गया।',
      'uploadFailed': 'अपलोड विफल।',
      'previewFailed': 'पूर्वावलोकन विफल।',
      'downloadFailed': 'डाउनलोड विफल।',
      'deleteEvidenceTitle': 'साक्ष्य हटाएं?',
      'deleteEvidenceConfirm': '"{title}" को वॉल्ट से हटाएं?',
      'evidenceDeleted': 'साक्ष्य हटाया गया।',
      'deleteFailed': 'हटाना विफल।',
      'exportFailed': 'निर्यात विफल।',
      'exportEvidencePackage': 'साक्ष्य पैकेज निर्यात',
      'cyberAiResultDisclaimer':
          'यह केवल संभावित जोखिम आकलन है — कानूनी प्रमाण, पुलिस सलाह या अंतिम निर्णय नहीं। हमेशा आधिकारिक स्रोतों से सत्यापित करें।',
      'cyberEvidencePrivacyNotice':
          'आपके अपलोड की गई फ़ाइलें Suraksha के सुरक्षित सर्वर वॉल्ट में संग्रहीत होती हैं (आपके खाते के अंतर्गत डिस्क पर AES-एन्क्रिप्टेड)। मेटाडेटा (शीर्षक, श्रेणी, टैग) आपके खाते के साथ सहेजा जाता है। जब तक आप स्वयं आधिकारिक साइबर अपराध पोर्टल पर शिकायत दर्ज नहीं करते, साक्ष्य वहाँ नहीं भेजा जाता।',
      'cyberEvidenceConfirmTitle': 'साक्ष्य अपलोड की पुष्टि करें',
      'cyberEvidenceConfirmMessage':
          'फ़ाइल: {name}\nआकार: {size}\nश्रेणी: {category}\nनिजी: {private}\n\nइस फ़ाइल को Suraksha वॉल्ट में अपलोड करें?',
      'cyberEvidenceInvalidType':
          'असमर्थित फ़ाइल प्रकार। JPG, PNG, WEBP, PDF, MP3, WAV या M4A उपयोग करें।',
      'cyberEvidenceFileMissing': 'चयनित फ़ाइल पढ़ी नहीं जा सकी।',
      'cyberEvidenceUploadCancel': 'अपलोड रद्द करें',
      'cyberUploadCancelled': 'अपलोड रद्द किया गया।',
      'cyberVaultLockTitle': 'वॉल्ट देखने का लॉक',
      'cyberVaultLockSubtitle':
          'साक्ष्य देखने या डाउनलोड करने से पहले वैकल्पिक PIN या बायोमेट्रिक।',
      'cyberVaultEnableLock': 'व्यूइंग लॉक सक्षम करें',
      'cyberVaultDisableLock': 'व्यूइंग लॉक अक्षम करें',
      'cyberVaultUnlockTitle': 'साक्ष्य वॉल्ट अनलॉक करें',
      'cyberVaultUnlockAction': 'अनलॉक',
      'cyberVaultBiometricReason': 'Suraksha साक्ष्य वॉल्ट अनलॉक करें',
      'cyberVaultPinIncorrect': 'गलत PIN।',
      'cyberVaultLockEnabled': 'साक्ष्य व्यूइंग लॉक सक्षम।',
      'cyberVaultLockDisabled': 'साक्ष्य व्यूइंग लॉक अक्षम।',
      'cyberVaultSetPinTitle': 'वॉल्ट PIN सेट करें',
      'cyberVaultConfirmPinLabel': 'PIN की पुष्टि करें',
      'cyberVaultPinMismatch': 'PIN मेल नहीं खाते।',
      'cyberAcknowledgementHistory': 'पावती इतिहास',
      'cyberAcknowledgementHistoryEmpty': 'अभी तक कोई पोर्टल पावती नंबर सहेजा नहीं गया।',
      'cyberAckSavedAt': 'सहेजा गया {when}',
      'filterAll': 'सभी',
      'filterLinked': 'जुड़े हुए',
      'filterUnlinked': 'अनलिंक्ड',
      'reportDetails': 'रिपोर्ट विवरण',
      'linkedEvidence': 'जुड़ा साक्ष्य',
      'noLinkedEvidence': 'इस रिपोर्ट से कोई साक्ष्य नहीं जुड़ा।',
      'digitalSafetyLearningHub': 'डिजिटल सुरक्षा शिक्षा केंद्र',
      'learningHubSubtitle': 'फ़िशिंग, UPI, गोपनीयता और डीपफेक कौशल बनाएं।',
      'cyberSafetyScore': 'साइबर सुरक्षा स्कोर',
      'cyberSafetyScoreUpdated': 'साइबर सुरक्षा स्कोर: {score}',
      'catFinancialFraud': 'वित्तीय धोखाधड़ी',
      'catCyberStalking': 'साइबर स्टॉकिंग',
      'catOnlineBullying': 'ऑनलाइन बुलिंग',
      'catIdentityTheft': 'पहचान की चोरी',
      'catSocialMediaHarassment': 'सोशल मीडिया उत्पीड़न',
      'catHarassment': 'उत्पीड़न',
      'catBlackmail': 'ब्लैकमेल',
      'catFakeProfile': 'नकली प्रोफ़ाइल',
      'catDeepfakeThreat': 'डीपफेक धमकी',
      'catDeepfakeScam': 'डीपफेक घोटाला',
      'catFakeJobScam': 'नकली नौकरी घोटाला',
      'catUpiFraud': 'UPI धोखाधड़ी',
      'catOther': 'अन्य',
      'evidenceCatAll': 'सभी',
      'evidenceCatScreenshot': 'स्क्रीनशॉट',
      'evidenceCatAudio': 'ऑडियो',
      'evidenceCatThreatMessage': 'धमकी संदेश',
      'evidenceCatImage': 'छवि',
      'evidenceCatTransactionProof': 'लेनदेन प्रमाण',
      'evidenceCatDocument': 'दस्तावेज़',
      'evidenceCatOther': 'अन्य',
      'multiSelectNone': 'कोई चयन नहीं',
      'multiSelectCount': '{count} चयनित',
      'filterCategories': 'श्रेणी फ़िल्टर',
      'filterLinkStatus': 'लिंक स्थिति',
      'additionalCategoriesNote': 'अतिरिक्त घटना प्रकार',
      'configureServer': 'सर्वर कॉन्फ़िगर करें',
      'configureServerHint':
          'PC IP दर्ज करें जहाँ बैकएंड चल रहा है। उदाहरण: http://192.168.1.5:5000/api',
      'serverUrlHint': 'http://192.168.1.5:5000/api',
      'serverUrlSaved': 'सर्वर URL सहेजा गया। कनेक्शन पुनः प्रयास...',
      'cannotReachServer':
          'सर्वर से कनेक्ट नहीं हो पा रहा। कृपया अपना इंटरनेट कनेक्शन जाँचें और पुनः प्रयास करें।',
      'fixConnection': 'पुनः प्रयास करें',
      'deepfakeEmergencySupportTitle':
          'डीपफेक और मॉर्फ़्ड इमेज इमरजेंसी सहायता',
      'medicalHealthVault': 'मेडिकल हेल्थ वॉल्ट',
      'surakshaAi': 'सुरक्षा AI',
      'surakshaAiSubtitle': 'आपका व्यक्तिगत सुरक्षा सहायक',
      'surakshaAiWelcome':
          'नमस्ते, मैं सुरक्षा AI हूँ। SOS, मार्ग सुरक्षा, साइबर घोटाले, POSH या चिकित्सा आपातकाल की तैयारी के बारे में पूछें। तत्काल खतरे में 112 पर कॉल करें।',
      'surakshaAiPlaceholder': 'सुरक्षा, मार्ग, SOS के बारे में पूछें...',
      'surakshaAiThinking': 'सोच रहा हूँ...',
      'surakshaAiQuickPrompt1': 'SOS कैसे उपयोग करें?',
      'surakshaAiQuickPrompt2': 'यात्रा में असुरक्षित महसूस कर रही हूँ',
      'surakshaAiQuickPrompt3': 'कोई ऑनलाइन परेशान कर रहा है',
      'surakshaAiLimitedOfflineGuidance': 'सीमित ऑफ़लाइन मार्गदर्शन',
      'surakshaAiPrivacyWarning':
          'गोपनीयता सुझाव: इस चैट में पासवर्ड, OTP, बैंकिंग विवरण, आधार/पैन या अनावश्यक पहचान जानकारी साझा न करें।',
      'surakshaAiNewConversation': 'नई बातचीत',
      'surakshaAiClearChat': 'चैट साफ़ करें',
      'surakshaAiClearChatConfirm':
          'यह चैट साफ़ कर नई शुरू करें? Suraksha AI का सर्वर इतिहास भी रीसेट होगा।',
      'surakshaAiConversationCleared': 'बातचीत साफ़ की गई।',
      'surakshaAiFeedbackHelpful': 'उपयोगी',
      'surakshaAiFeedbackIrrelevant': 'अप्रासंगिक',
      'surakshaAiFeedbackUnsafe': 'असुरक्षित',
      'surakshaAiFeedbackThanks': 'फ़ीडबैक के लिए धन्यवाद।',
      'surakshaAiFeedbackFailed': 'फ़ीडबैक अभी सहेजा नहीं जा सका।',
      'surakshaAiActionCall112': '112 कॉल करें',
      'surakshaAiActionSos': 'SOS भेजें',
      'surakshaAiActionSafetyMap': 'सेफ्टी मैप',
      'surakshaAiActionCyber': 'साइबर सुरक्षा',
      'surakshaAiActionPosh': 'POSH',
      'surakshaAiSosTriggered': 'Suraksha AI से SOS सक्रिय किया गया।',
      'surakshaAiIntentDanger': 'पहचाना इरादा: तत्काल खतरा',
      'surakshaAiIntentCyber': 'पहचाना इरादा: साइबर / ब्लैकमेल',
      'surakshaAiIntentPosh': 'पहचाना इरादा: कार्यस्थल उत्पीड़न',
      'surakshaAiIntentMedical': 'पहचाना इरादा: मेडिकल आपात',
      'surakshaAiIntentGreeting': 'पहचाना इरादा: अभिवादन',
      'surakshaAiIntentGeneral': 'पहचाना इरादा: सामान्य प्रश्न',
      'keepEmergencyMedicalInformationOrganized':
          'आपातकालीन चिकित्सा जानकारी को तेज़ उपयोग के लिए व्यवस्थित रखें।',
      'emergencyMedicalId': 'आपातकालीन मेडिकल आईडी',
      'scanInCaseOfMedicalEmergency':
          'चिकित्सीय आपातकाल के मामले में स्कैन करें',
      'medicalProfileSaved': 'मेडिकल प्रोफ़ाइल सहेजी गई',
      'medicalDetailsReady':
          'आपकी मेडिकल जानकारी आपातकालीन उपयोग के लिए तैयार है।',
      'savedLocallyOnThisDevice': 'यह डिवाइस पर स्थानीय रूप से सहेजा गया।',
      'medicalProfileSavedLocallySyncRetryLater':
          'चिकित्सीय प्रोफ़ाइल स्थानीय रूप से सहेजी गई। सिंक बाद में पुन: प्रयास करेगा।',
      'certificateDetails': 'प्रमाणपत्र विवरण',
      'issuedOn': '{date} को जारी किया गया',
      'poshCertifiedMessage':
          'आपने तीनों क्विज़ स्तर पूरे किए हैं और मजबूत POSH एक्ट ज्ञान दिखाया है।',
      'validForPoshCertificate':
          'मान्य: POSH एक्ट जागरूकता और कार्यस्थल सुरक्षा सीखने के लिए',
      'safeZoneUpdatedNearby': 'नज़दीक सुरक्षित क्षेत्र अपडेट हुआ',
      'crowdedAreaWarning': 'भीड़भाड़ क्षेत्र चेतावनी',
      'minsAgo2': '2 मिनट पहले',
      'minsAgo15': '15 मिनट पहले',
      'map': 'मैप',
      'medical': 'मेडिकल',
      'cyber': 'साइबर',
      'poshPortal': 'पॉश पोर्टल',
      'liveSafetyMapTitle': 'लाइव सुरक्षा मानचित्र',
      'locating': 'स्थान खोजा जा रहा है...',
      'myLocation': 'मेरा स्थान',
      'refreshNearby': 'नज़दीकी रिफ्रेश करें',
      'retryLiveLocation': 'लाइव लोकेशन पुनः प्रयास करें',
      'safetyIntelligenceMap': 'सुरक्षा इंटेलिजेंस मानचित्र',
      'couldNotFindThatLocation': 'वह स्थान नहीं मिला।',
      'couldNotOpenThisPlace': 'यह स्थान नहीं खोला जा सका।',
      'tryAgain': 'पुनः प्रयास करें',
      'longPressDropPinPreviewRoute':
          'पिन ड्रॉप करने के लिए लंबा दबाएँ। मार्ग देखने के लिए मार्कर टैप करें।',
      'fetchingYourLocation': 'आपका वर्तमान स्थान प्राप्त किया जा रहा है...',
      'mapWillOpenAroundYou':
          'GPS तैयार होते ही मानचित्र सीधे आपके आसपास खुलेगा।',
      'searchLocation': 'स्थान खोजें...',
      'liveTrackingActive': 'लाइव ट्रैकिंग सक्रिय',
      'journeyTrackingActive': 'यात्रा ट्रैकिंग सक्रिय',
      'destinationReached': 'गंतव्य पर पहुँच गए',
      'selectedDestination': 'चयनित गंतव्य',
      'calculatingRoute': 'मार्ग की गणना हो रही है',
      'remaining': 'शेष',
      'routePreview': 'मार्ग पूर्वावलोकन',
      'liveNavigation': 'लाइव नेविगेशन',
      'followingYourRoute': 'लाइव प्रगति के साथ आपके मार्ग का अनुसरण',
      'readyWithDistanceAndEstimatedTravelTime':
          'दूरी और अनुमानित यात्रा समय के साथ तैयार',
      'calculatingRouteDistance': 'मार्ग दूरी की गणना',
      'covered': 'कवर किया',
      'eta': 'अनुमानित समय',
      'selectedLocation': 'चयनित स्थान',
      'customPin': 'कस्टम पिन',
      'study': 'अध्ययन',
      'quizzes': 'क्विज़',
      'complaint': 'शिकायत',
      'poshActLearningHub': 'POSH अधिनियम अध्ययन केंद्र',
      'poshStudy1Title': 'POSH अधिनियम क्या कवर करता है',
      'poshStudy1Bullet1':
          'POSH अधिनियम कार्यस्थल पर महिलाओं के यौन उत्पीड़न (2013) को संबोधित करता है।',
      'poshStudy1Bullet2':
          'यह गरिमा, समानता और सुरक्षित कार्य स्थितियों की रक्षा करता है।',
      'poshStudy1Bullet3':
          'यह सार्वजनिक व निजी कार्यस्थलों, कार्यालयों, दुकानों, अस्पतालों, स्कूलों, NGO और नियोक्ता द्वारा प्रदान किए गए परिवहन पर लागू होता है।',
      'poshStudy1Bullet4':
          'कानून कर्मचारियों, प्रशिक्षुओं, इंटर्न, संविदा कर्मचारियों, स्वयंसेवकों और कार्यस्थल पर आने वाले आगंतुकों को कवर करता है।',
      'poshStudy1Bullet5':
          'यौन प्रकृति का अवांछित आचरण मौखिक, लिखित, डिजिटल या शारीरिक हो सकता है।',
      'poshStudy1Bullet6':
          'उदाहरण: अवांछित छूना, यौन टिप्पणियाँ, संदेश, दोहराया उत्पीड़न, या अश्लील सामग्री दिखाना।',
      'poshStudy2Title': 'शिकायत प्रक्रिया और आंतरिक समिति (IC)',
      'poshStudy2Bullet1':
          'शिकायत सामान्यतः घटना के 3 महीनों के भीतर लिखित रूप में दी जानी चाहिए।',
      'poshStudy2Bullet2':
          '10 या अधिक कर्मचारियों वाले कार्यस्थलों में आंतरिक समिति सही ढंग से गठित होनी चाहिए।',
      'poshStudy2Bullet3':
          'समिति में आमतौर पर एक वरिष्ठ महिला अध्यक्ष, कर्मचारी सदस्य और एक बाहरी सदस्य शामिल होते हैं।',
      'poshStudy2Bullet4':
          'सुलह केवल तब किया जा सकता है जब शिकायतकर्ता चाहे; यह जबरदस्ती नहीं होना चाहिए।',
      'poshStudy2Bullet5':
          'यदि सुलह नहीं होती, तो IC निष्पक्ष जाँच करती है जहाँ दोनों पक्षों को सुना जाता है।',
      'poshStudy2Bullet6': 'प्रक्रिया गोपनीय, लिखित और दस्तावेजीकृत रहे।',
      'poshStudy3Title': 'साक्ष्य, सुरक्षा और नियोक्ता कर्तव्य',
      'poshStudy3Bullet1':
          'चैट्स, ईमेल, स्क्रीनशॉट, कॉल लॉग, गवाहों के नाम, तिथियाँ और स्थान का रिकॉर्ड रखें।',
      'poshStudy3Bullet2':
          'अंतरिम सहायता के रूप में तबादला, रजा, संपर्क-निषेध, या रिपोर्टिंग-लाइन में बदलाव शामिल हो सकते हैं।',
      'poshStudy3Bullet3':
          'यदि तथ्य अपराध को दर्शाते हैं तो पुलिस में शिकायत/FIR भी दर्ज की जा सकती है।',
      'poshStudy3Bullet4':
          'नियोक्ता नीति दिखाएँ, कर्मचारियों को प्रशिक्षित करें, IC का समर्थन करें और सिफारिशें लागू करें।',
      'poshStudy3Bullet5':
          'गोपनीयता शिकायतकर्ता, प्रतिवादी, गवाह और कार्यवाही पर लागू होती है।',
      'poshStudy3Bullet6':
          'एक शिकायत केवल इसलिए झूठी नहीं होती कि उसे प्रमाणित नहीं किया जा सका; जानबूझकर झूठ अलग मामला है।',
      'poshStudy4Title': 'महत्वपूर्ण POSH सीमाएँ',
      'poshStudy4Bullet1':
          'अप्रासंगिक व्यक्तिगत विवादों या जानबूझकर बनाए गए आरोपों के लिए तंत्र का उपयोग न करें।',
      'poshStudy4Bullet2': 'साक्ष्य न मिटाएँ और गवाहों पर दबाव न डालें।',
      'poshStudy4Bullet3':
          'छोटी बारंबार घटनाओं की अनदेखी न करें; पैटर्न मायने रखता है।',
      'poshStudy4Bullet4':
          'तथ्यात्मक, दिनांकित और विस्तृत रिपोर्टिंग का उपयोग करें।',
      'poshStudy4Bullet5':
          'तत्काल खतरे में होने पर पहले आपातकालीन सेवाओं को कॉल करें।',
      'poshStudy4Bullet6':
          'POSH पोर्टल सीखने, दस्तावेजीकरण और संरचित शिकायत तैयारी के लिए है।',
      'studyFirst': 'पहले अध्ययन करें',
      'readAllSectionsBeforeQuiz1': 'क्विज़ 1 से पहले सभी अनुभाग पढ़ें',
      'threeLevels': 'तीन स्तर',
      'twentyMcqsEachQuiz': 'हर क्विज़ में 20 MCQ',
      'quizCertificationTrack': 'क्विज़ प्रमाणन ट्रैक',
      'studyFirstThenClearQuizzesInOrder':
          'पहले अध्ययन करें, फिर क्विज़ को क्रम से पूरा करें।',
      'level': 'स्तर',
      'levelPassed': 'स्तर पास',
      'passed': 'पास',
      'available': 'उपलब्ध',
      'locked': 'लॉक्ड',
      'submitQuiz': 'क्विज़ सबमिट करें',
      'next': 'अगला',
      'unlocked': 'अनलॉक्ड',
      'quizNotClearedYet': 'क्विज़ अभी साफ़ नहीं हुआ है',
      'reviewStudy': 'अध्ययन देखें',
      'retry': 'फिर से प्रयास करें',
      'viewCertificate': 'प्रमाणपत्र देखें',
      'continueLabel': 'जारी रखें',
      'poshCertified': 'POSH प्रमाणित',
      'fileWorkplaceComplaint': 'कार्यस्थल शिकायत दर्ज करें',
      'fileWorkplaceComplaintSubtitle':
          'अपने संदर्भ के लिए विस्तृत घटना रिकॉर्ड तैयार करें। यह आधिकारिक IC, नियोक्ता या सरकारी दाखिल नहीं है। तुरंत खतरे में 112 पर कॉल करें।',
      'keepRecordsFactual':
          'अपने रिकॉर्ड तथ्यात्मक रखें और संभव हो तो साक्ष्य जोड़ें।',
      'yourFullName': 'आपका पूरा नाम',
      'yourPhoneNumber': 'आपका फोन नंबर',
      'yourEmailAddress': 'आपका ईमेल पता',
      'accusedPersonName': 'आरोपी व्यक्ति का नाम',
      'companyWorkplaceName': 'कंपनी / कार्यस्थल का नाम',
      'incidentDateDdMmYyyy': 'घटना की तारीख (DD/MM/YYYY)',
      'incidentLocation': 'घटना का स्थान',
      'witnessesIfAny': 'गवाह (यदि कोई हों)',
      'detailedIncidentDescription': 'घटना का विस्तृत विवरण',
      'submitting': 'सबमिट किया जा रहा है...',
      'submitComplaint': 'शिकायत सबमिट करें',
      'guideIntro':
          'यह मार्गदर्शिका शिक्षण और संचालन के लिए है। यह भारत में POSH ढांचे के तहत प्रक्रिया, सीमाएं, दस्तावेजीकरण और आगे की कार्रवाई समझाती है।',
      'legalDisclaimer':
          'कानूनी अस्वीकरण: Suraksha केवल शैक्षणिक POSH मार्गदर्शन देता है—कानूनी सलाह या आधिकारिक दाखिल नहीं। यहाँ ड्राफ्ट/रिकॉर्ड सहेजना IC, नियोक्ता या सरकार को जमा नहीं करता। महत्वपूर्ण मामलों में योग्य वकील, HR-POSH विशेषज्ञ या सक्षम प्राधिकारी से सलाह लें।',
      'poshLegalSourceLabel': 'कानूनी स्रोत',
      'poshLegalSourceNote':
          'POSH अधिनियम, 2013 और प्रकाशित कार्यस्थल अनुपालन मार्गदर्शन पर आधारित शैक्षणिक सारांश। आधिकारिक सरकारी दाखिल चैनल नहीं।',
      'poshLastReviewed': 'सामग्री अंतिम समीक्षा: {date}',
      'poshHubEducationTitle': 'शिक्षा',
      'poshHubEducationSubtitle':
          'POSH की बुनियाद पढ़ें और विस्तृत अधिनियम गाइड खोलें।',
      'poshHubQuizTitle': 'क्विज़',
      'poshHubQuizSubtitle':
          'प्रमाणपत्र के लिए तीन क्विज़ स्तर पूरे करें।',
      'poshHubComplaintTitle': 'शिकायत तैयारी',
      'poshHubComplaintSubtitle':
          'घटना विवरण सुरक्षित रूप से ड्राफ्ट करें—Suraksha आधिकारिक पोर्टल नहीं है।',
      'poshHubCertificateTitle': 'प्रमाणपत्र',
      'poshHubCertificateSubtitle':
          'सभी क्विज़ स्तर पूरे करने के बाद POSH जागरूकता प्रमाणपत्र देखें।',
      'poshFilingBoundaryTitle': 'आधिकारिक दाखिल नहीं',
      'poshFilingBoundaryMessage':
          'ड्राफ्ट या Suraksha में सहेजना केवल इस ऐप में निजी रिकॉर्ड रखता है। यह IC, नियोक्ता या किसी सरकारी पोर्टल पर दाखिल नहीं होता। आधिकारिक रूप से अपने कार्यस्थल IC या सक्षम प्राधिकारी के माध्यम से जमा करें।',
      'poshSaveDraft': 'ड्राफ्ट सहेजें',
      'poshDraftSaved': 'ड्राफ्ट इस डिवाइस पर सुरक्षित रूप से सहेजा गया।',
      'poshSaveToSuraksha': 'Suraksha में सहेजें (आधिकारिक दाखिल नहीं)',
      'poshSavedToSurakshaNotice':
          'Suraksha में आपके रिकॉर्ड के लिए सहेजा गया। यह आधिकारिक IC या सरकारी जमा नहीं है।',
      'poshDangerDetectedTitle': 'तत्काल खतरा पहचाना गया',
      'poshDangerDetectedMessage':
          'आपके नोट्स से लगता है आप तत्काल खतरे में हो सकते हैं। अभी आपात सेवाओं को कॉल करें या डैशबोर्ड से SOS खोलें।',
      'poshCall112': '112 पर कॉल करें',
      'poshOpenSos': 'SOS खोलें',
      'poshGuideContents': 'विषय सूची',
      'poshGuideSearchHint': 'गाइड अनुभाग खोजें',
      'poshGuideNoSearchResults': 'आपकी खोज से कोई अनुभाग मेल नहीं खाता।',
      'poshGuideBookmark': 'अनुभाग बुकमार्क करें',
      'poshGuideBookmarked': 'बुकमार्क किया',
      'poshGuideFontSize': 'टेक्स्ट आकार',
      'poshCertificateNotReady':
          'प्रमाणपत्र अनलॉक करने के लिए तीनों क्विज़ स्तर पूरे करें।',
      'poshComplaintDraftRestored': 'आपका सहेजा ड्राफ्ट पुनर्स्थापित किया गया।',
      'guide1Title': '1. पृष्ठभूमि और उद्देश्य',
      'guide1Body':
          'कार्यस्थल पर महिलाओं का यौन उत्पीड़न (निवारण, निषेध और प्रतितोष) अधिनियम, 2013 — जिसे सामान्यतः POSH अधिनियम कहते हैं — कार्यस्थलों पर यौन उत्पीड़न रोकने, उसे प्रतिबंधित करने और निष्पक्ष निवारण व्यवस्था देने का कानूनी दायित्व स्पष्ट करता है।\n\n'
          'यह सुप्रीम कोर्ट के विशाखा दिशानिर्देशों (1997) पर आधारित है और उन्हें वैधानिक ढाँचे में बदलता है। मुख्य उद्देश्य हैं: (1) कार्यस्थल पर यौन उत्पीड़न की रोकथाम, (2) नीति और जवाबदेही द्वारा निषेध, और (3) सुलभ शिकायत व जाँच तंत्र।\n\n'
          'आच्छादित प्रत्येक नियोक्ता को सुरक्षित कार्य-वातावरण देना, शिकायत प्रक्रिया की जानकारी प्रदर्शित करना, कर्मचारियों को संवेदनशील बनाना, और प्रतिशोध के बिना Internal Committee (IC) या Local Committee (LC) की प्रक्रिया में सहयोग करना आवश्यक है।\n\n'
          'Suraksha की यह गाइड केवल शैक्षणिक है। यह प्रक्रिया समझने और रिकॉर्ड तैयार करने में मदद करती है। यह कानूनी सलाह का विकल्प नहीं है, और Suraksha का उपयोग अपने आप IC, नियोक्ता या सरकार के पास शिकायत दाखिल नहीं करता।',
      'guide2Title': '2. यह कहाँ लागू होता है',
      'guide2Body':
          'अधिनियम भारत में संगठित और कई असंगठित कार्यस्थल सेटिंग्स पर व्यापक रूप से लागू होता है। “कार्यस्थल” केवल पारंपरिक ऑफिस डेस्क तक सीमित नहीं। इसमें सरकारी व निजी कार्यालय, कारखाना, दुकान, अस्पताल, शैक्षणिक संस्थान, NGO, खेल संस्थान, स्टेडियम और अन्य प्रतिष्ठान शामिल हो सकते हैं।\n\n'
          'रोजगार के दौरान देखे गए स्थान भी आ सकते हैं — जैसे क्लाइंट साइट, प्रशिक्षण स्थल, सम्मेलन और कार्य-यात्रा। घरेलू-काम के कुछ संदर्भों सहित निवास-स्थान जब कार्यस्थल के रूप में प्रयुक्त हों, वैधानिक शर्तें पूरी होने पर अधिनियम की परिधि में आ सकते हैं।\n\n'
          'रिमोट या हाइब्रिड काम सुरक्षा हटाता नहीं। ऑफिस ईमेल, आधिकारिक चैट, वीडियो मीटिंग या कार्य-संबंधी डिजिटल माध्यमों से आचरण भी कार्यस्थल-संबंधी हो सकता है यदि वह रोजगार से जुड़ा हो।\n\n'
          'यदि संगठन में 10 से कम कर्मचारी हैं, तो शिकायत सामान्यतः जिला अधिकारी द्वारा गठित Local Committee (LC) के माध्यम से होती है, Internal Committee के बजाय।',
      'guide3Title': '3. कौन संरक्षित है',
      'guide3Body':
          'अधिनियम मुख्य रूप से कार्यस्थल के संबंध में “व्यथित महिला” की रक्षा करता है। सुरक्षा केवल पेरोल पर स्थायी कर्मचारियों तक सीमित नहीं। इसमें नियमित, अस्थायी, तदर्थ, दैनिक मजदूरी, संविदा कर्मचारी, प्रशिक्षु, अप्रेंटिस, इंटर्न, और कई व्यवहारिक संदर्भों में कार्य से जुड़ी महिला आगंतुक भी आ सकती हैं।\n\n'
          'प्रतिवादी (जिसके विरुद्ध शिकायत है) कर्मचारी, नियोक्ता या कार्यस्थल से जुड़ा अन्य व्यक्ति हो सकता है। पदक्रम — कनिष्ठ बनाम वरिष्ठ, ठेकेदार बनाम फुल-टाइम — मात्र शिकायत को निरस्त नहीं करता।\n\n'
          'POSH महिलाओं की कार्यस्थल सुरक्षा का क़ानून है। अन्य लिंगों से संबंधित उत्पीड़न अन्य क़ानूनों/संगठनात्मक नीतियों से जुड़ सकता है; वे मार्ग यहाँ वर्णित POSH ढाँचे से अलग हैं।\n\n'
          'यदि संदेह हो कि आपका रोल कवर है या नहीं, अपना नियोजन प्रकार, स्थान और घटना का कार्य-संबंध नोट करें — फिर IC/LC संपर्क, POSH-जागरूक HR, या वकील से मार्गदर्शन लें।',
      'guide4Title': '4. यौन उत्पीड़न क्या है',
      'guide4Body':
          'अधिनियम के अंतर्गत यौन उत्पीड़न में यौन प्रकृति के एक या अधिक अवांछित कृत्य/व्यवहार शामिल हैं, चाहे प्रत्यक्ष हों या निहित। उदाहरण: अवांछित शारीरिक संपर्क और अग्रसरता; यौन अनुग्रह की माँग/अनुरोध; यौन रंग की टिप्पणियाँ; अश्लील सामग्री दिखाना; तथा यौन प्रकृति का अन्य अवांछित शारीरिक, मौखिक या गैर-मौखिक आचरण।\n\n'
          'उत्पीड़न एक गंभीर घटना या श्रृंखला हो सकता है। यह आमने-सामने या डिजिटल माध्यमों (संदेश, कॉल, ईमेल, सोशल मीडिया, डीपफेक, मॉर्फ्ड छवियाँ) से भी हो सकता है जब कार्यस्थल संबंध से जुड़ा हो।\n\n'
          'मुख्य बात यह है कि आचरण अवांछित हो। मौन, पुरानी मित्रता या पदक्रम से सहमति नहीं मानी जा सकती। क्विड प्रो क्वो (यौन अनुग्रह से जुड़े लाभ/धमकियाँ) और यौन आचरण से बनी शत्रुतापूर्ण कार्य-स्थिति दोनों गंभीर हैं।\n\n'
          'हर कार्यस्थल विवाद यौन उत्पीड़न नहीं होता। अशिष्ट परंतु गैर-यौन व्यवहार अन्य नीतियों का उल्लंघन हो सकता है। POSH के लिए ध्यान दें: क्या आचरण यौन प्रकृति का और अवांछित है — तिथियाँ, शब्द/कृत्य, प्रभाव और गवाह दर्ज करें।',
      'guide5Title': '5. आंतरिक समिति (IC) आवश्यकताएँ',
      'guide5Body':
          '10 या अधिक कर्मचारियों वाले प्रत्येक कार्यस्थल पर Internal Committee (IC) गठित करनी आवश्यक है। सामान्यतः इसमें शामिल हैं: वरिष्ठ महिला कर्मचारी के रूप में Presiding Officer; कम से कम दो कर्मचारी सदस्य (अधिमानतः महिला मुद्दों/सामाजिक कार्य/कानूनी ज्ञान से जुड़े); और NGO/संगठन से बाहरी सदस्य या यौन उत्पीड़न मुद्दों से परिचित व्यक्ति।\n\n'
          'कुल सदस्यों में कम से कम आधी महिलाएँ होनी चाहिए। सदस्यों का कार्यकाल सामान्यतः अधिकतम तीन वर्ष का होता है। नियोक्ता को सुनिश्चित करना चाहिए कि IC वास्तव में काम कर रही हो — केवल कागज़ पर नाम पर्याप्त नहीं।\n\n'
          'जहाँ IC नहीं है (10 से कम कर्मचारियों वाले कार्यस्थल सहित), जिला स्तर की Local Committee (LC) मंच होती है। आवश्यक होने पर IC न बनाने पर अधिनियम के तहत जुर्माना और बार-बार अवहेलना पर और परिणाम हो सकते हैं।\n\n'
          'व्यावहारिक रूप से: HR/प्रशासन से वर्तमान IC सूची, शिकायत ईमेल/ड्रॉप-बॉक्स और नीति दस्तावेज़ माँगें। उस जानकारी की प्रति अपने रिकॉर्ड में रखें।',
      'guide6Title': '6. शिकायत समयसीमा और प्रारूप',
      'guide6Body':
          'वर्तमान क़ानून (POSH अधिनियम, 2013) के अनुसार व्यथित महिला को सामान्यतः घटना के तीन महीने के भीतर IC/LC को लिखित शिकायत देनी चाहिए। घटनाओं की श्रृंखला में तीन महीने आमतौर पर अंतिम घटना से गिने जाते हैं।\n\n'
          'IC/LC समय को अधिकतम और तीन महीने तक बढ़ा सकती है (वर्तमान ढाँचे में कुल अधिकतम छह महीने), यदि संतुष्ट हो कि परिस्थितियों ने समय पर दाखिल नहीं होने दिया, और कारण लिखित दर्ज करने होंगे। सार्वजनिक चर्चा में प्रस्तावित संशोधन (लंबी समयसीमा सहित) लागू होने तक वर्तमान वैधानिक नियम का विकल्प नहीं हैं — अपनी समयसीमा का पालन करें और सीमा के पास/बाद में कानूनी सलाह लें।\n\n'
          'मजबूत शिकायत में आमतौर पर होते हैं: शिकायतकर्ता व प्रतिवादी की पहचान; कार्यस्थल विवरण; तिथि/समय/स्थान; स्पष्ट तथ्य-कथन; गवाहों के नाम; साक्ष्य सूची; काम/स्वास्थ्य/सुरक्षा पर प्रभाव; और मांगी गई राहत (जैसे संपर्क-निषेध, स्थानांतरण, जाँच, अंतरिम उपाय)।\n\n'
          'यदि लिखना कठिन हो, अधिनियम सहायता का प्रावधान करता है ताकि शिकायत लेखबद्ध कर हस्ताक्षर/सत्यापित की जा सके। जो जमा करें उसकी दिनांकित प्रति अपने पास रखें।',
      'guide7Title': '7. सुलह और जाँच',
      'guide7Body':
          'पूर्ण जाँच से पहले, व्यथित महिला के अनुरोध पर IC सुलह का प्रयास कर सकती है। सुलह स्वैच्छिक है। अधिनियम के सुलह ढाँचे में मौद्रिक समझौता आधार के रूप में अनुमत नहीं। सफल सुलह पर IC समझौता दर्ज करती है और सामान्यतः उन शर्तों पर आगे जाँच नहीं करती; प्रतियाँ नियोक्ता और पक्षों को यथावश्यक जाती हैं।\n\n'
          'यदि सुलह नहीं माँगी गई, विफल हुई या अनुपयुक्त है, तो IC जाँच आगे बढ़ाती है। प्रतिवादी को सूचित कर लिखित जवाब का अवसर दिया जाता है। दोनों पक्ष सुने जाते हैं; प्राकृतिक न्याय लागू होता है। अधिनियम के अंतर्गत IC के पास कुछ प्रयोजनों के लिए सिविल न्यायालय जैसी शक्तियाँ हैं (जैसे शपथ पर बुलाकर जाँच, दस्तावेज़ माँगना)।\n\n'
          'जाँच सामान्यतः 90 दिनों में पूरी होनी चाहिए। पूर्ण होने के 10 दिनों के भीतर IC नियोक्ता (या LC मामलों में जिला अधिकारी) को रिपोर्ट देती है और संबंधित पक्षों को उपलब्ध कराती है।\n\n'
          'केवल मौखिक अपडेट पर निर्भर न रहें। लिखित पावती, सुनवाई तिथियाँ और जिन प्रतियों के आप हकदार हैं, माँगें।',
      'guide8Title': '8. प्रक्रिया के दौरान अंतरिम राहत',
      'guide8Body':
          'जाँच के दौरान IC शिकायतकर्ता की सुरक्षा और निष्पक्ष प्रक्रिया के लिए अंतरिम उपाय सुझा सकती है। सामान्य उदाहरण: किसी पक्ष का स्थानांतरण; व्यथित महिला को छुट्टी (वैधानिक सीमाओं के अधीन, अन्य हक के अतिरिक्त); रिपोर्टिंग संबंध बदलना; प्रतिवादी को शिकायतकर्ता के कार्य का मूल्यांकन करने से रोक; संपर्क/संचार प्रतिबंध; तथा कार्यस्थल सुरक्षा सहायता।\n\n'
          'अंतरिम राहत दोष सिद्ध होने का अंतिम निष्कर्ष नहीं है। यह सुरक्षा और प्रक्रिया-अखंडता का कदम है। लगातार संपर्क, धमकी, प्रदर्शन-प्रतिशोध या असुरक्षित निकटता हो तो अंतरिम उपाय लिखित में माँगें।\n\n'
          'अंतरिम सिफारिशें होने पर नियोक्ता को लागू करना चाहिए। वास्तव में लागू हुईं या नहीं, ट्रैक करें। प्रतिशोध जारी रहे तो प्रत्येक घटना तिथि, समय, व्यक्ति और संदेश/ईमेल के साथ दर्ज करें।\n\n'
          'तत्काल शारीरिक खतरे में पहले 112 / स्थानीय पुलिस कॉल करें। POSH अंतरिम उपाय कार्यस्थल प्रक्रिया के उपकरण हैं — आपात प्रतिक्रिया का विकल्प नहीं।',
      'guide9Title': '9. जाँच परिणाम और नियोक्ता की कार्रवाई',
      'guide9Body':
          'जाँच के बाद IC निष्कर्ष देती है। यदि आरोप सिद्ध नहीं होते, प्रतिवादी के विरुद्ध कार्रवाई आवश्यक न होने की सिफारिश हो सकती है। सिद्ध होने पर सेवा नियमों / लागू अनुशासन नियमों के तहत कार्रवाई सुझाई जा सकती है — चेतावनी, लिखित माफी, परामर्श, प्रमोशन/वेतन वृद्धि रोकना, बर्खास्तगी या अन्य वैध अनुशासनिक कदम।\n\n'
          'IC व्यथित महिला को मुआवज़े की सिफारिश भी कर सकती है, जो अधिनियम/नियमों के अनुसार जहाँ लागू हो प्रतिवादी के वेतन से वसूली योग्य हो सकता है।\n\n'
          'नियोक्ता को IC की सिफारिशें प्राप्त होने के 60 दिनों के भीतर लागू करनी होती हैं। लागू न करना स्वयं नियोक्ता के लिए अनुपालन जोखिम बना सकता है।\n\n'
          'आप पर लागू लिखित परिणाम माँगें, कार्यान्वयन समयसीमा नोट करें, और क्या कार्रवाई हुई (या नहीं हुई) इसका प्रमाण रखें।',
      'guide10Title': '10. पुलिस शिकायत और आपराधिक कानून',
      'guide10Body':
          'POSH कार्यस्थल का नागरिक/प्रशासनिक निवारण ढाँचा है। यह आपराधिक क़ानून को रद्द नहीं करता। यदि तथ्य भारतीय न्याय संहिता (या घटना तिथि के अनुसार पहले के IPC प्रावधान), सूचना प्रौद्योगिकी अधिनियम या अन्य आपराधिक क़ानूनों के अपराध दर्शाते हैं, तो समानांतर या अलग से पुलिस शिकायत / FIR संभव है।\n\n'
          'अक्सर आपराधिक मूल्यांकन चाहने वाली स्थितियाँ (मामला-विशिष्ट): यौन हमला, स्टॉकिंग, आपराधिक धमकी, वॉययरिज़्म, गैर-सहमति अंतरंग छवियाँ, ब्लैकमेल, और कुछ ऑनलाइन यौन अपराध।\n\n'
          'जहाँ उपयुक्त हो IC प्रक्रिया और आपराधिक उपाय साथ चल सकते हैं। पुलिस मामला हो तो IC को बताएँ क्योंकि समन्वय और साक्ष्य महत्वपूर्ण हो सकते हैं। पुलिस/फॉरेंसिक के लिए आवश्यक उपकरण या मूल फ़ाइलें नष्ट न करें।\n\n'
          'तत्काल खतरे में 112 कॉल करें, संभव हो तो सुरक्षित सार्वजनिक स्थान पर जाएँ, और Suraksha SOS से विश्वसनीय संपर्कों को सूचित करें। कार्यस्थल POSH कदम तब उठाएँ जब पर्याप्त सुरक्षित हों।',
      'guide11Title': '11. गोपनीयता नियम',
      'guide11Body':
          'गोपनीयता POSH का केंद्रीय कर्तव्य है। व्यथित महिला, प्रतिवादी और गवाहों की पहचान व पते; सुलह व जाँच संबंधी जानकारी; तथा शिकायत और निष्कर्षों की सामग्री को अधिनियम का उल्लंघन करते हुए सार्वजनिक, प्रेस या मीडिया में प्रकाशित/संप्रेषित नहीं करना चाहिए।\n\n'
          'सीमित प्रकटीकरण क़ानून द्वारा आवश्यक हो सकता है (जैसे कार्यान्वयन के लिए नियोक्ता, निष्पक्ष सुनवाई के लिए पक्ष, या वैध प्राधिकार)। चल रहे मामलों पर गossip, ग्रुप चैट और सोशल मीडिया पोस्ट कानूनी व सुरक्षा जोखिम पैदा कर सकते हैं।\n\n'
          'नियोक्ता और IC सदस्यों को दस्तावेज़ सुरक्षित रखने चाहिए। शिकायतकर्ता भी प्रतियाँ सुरक्षित रखें (एन्क्रिप्टेड वॉल्ट, सीमित फ़ोल्डर) और केवल विश्वसनीय सलाहकार/वकील से साझा करें।\n\n'
          'यदि कोई आपकी पहचान या केस विवरण लीक करे, क्या लीक हुआ, किसने, कब और कहाँ — दर्ज करें और IC/नियोक्ता तथा आवश्यकता पर कानूनी सलाहकार के पास उठाएँ।',
      'guide12Title': '12. झूठी शिकायत: सही कानूनी स्थिति',
      'guide12Body':
          'जो शिकायत सिद्ध नहीं होती वह अपने आप “झूठी” या “दुर्भावनापूर्ण” नहीं बन जाती। पीड़ितों के पास साक्ष्य सीमाएँ, भय, गवाहों की कमी या आघात संबंधी अंतराल हो सकते हैं। क़ानून अप्रमाणित मामले और जानबूझकर झूठे आरोप/जाली साक्ष्य वाले मामले में अंतर करता है।\n\n'
          'दुर्भावनापूर्ण/झूठी शिकायत पर कार्रवाई तब सोची जाती है जब IC यह निष्कर्ष निकाले कि आरोप जानते हुए झूठा लगाया गया, या जाली/भ्रामक साक्ष्य प्रस्तुत किए गए। यह उच्च और विशिष्ट मानक है — हर खारिज शिकायत का डिफ़ॉल्ट लेबल नहीं।\n\n'
          '“शिकायत करोगे तो झूठे केस का उल्टा मुकदमा” जैसी धमकियाँ कभी-कभी डराने के लिए प्रयुक्त होती हैं। ऐसी धमकियाँ दर्ज करें। दबाव में वास्तविक शिकायत वापस लेने से पहले स्वतंत्र कानूनी सलाह लें।\n\n'
          'सद्भावपूर्ण शिकायतकर्ता सटीक तथ्यों, सुरक्षित साक्ष्य और सुसंगत बयानों पर ध्यान दें। तिथियाँ बढ़ा-चढ़ाकर या विवरण गढ़कर न लिखें — विश्वसनीयता सत्य पर टिकी है।',
      'guide13Title': '13. अधिनियम का दुरुपयोग कैसे न करें',
      'guide13Body':
          'POSH यौन उत्पीड़न से निपटने और कार्यस्थल गरिमा की रक्षा के लिए है। दुरुपयोग वास्तविक पीड़ितों को नुकसान पहुँचाता है और तंत्र पर भरोसा घटाता है। असंबंधित हिसाब-किताब (केवल प्रदर्शन विवाद, यौन उत्पीड़न तथ्यों के बिना निजी संबंध विच्छेद, या ऑफिस राजनीति) के लिए शिकायत न करें।\n\n'
          'गवाहों को झूठ बोलने के लिए प्रभावित न करें, गुमराह करने हेतु चैट निर्यात चुनिंदा न बदलें, नकली स्क्रीनशॉट न बनाएँ, और असुविधाजनक साक्ष्य नष्ट न करें। जिन सहयोगियों ने अनुभव नहीं किया उन्हें शिकायत में जबरदस्ती शामिल न करें।\n\n'
          'प्रतिवादी भी प्रक्रिया का दुरुपयोग न करें: प्रतिशोध नहीं, गवाह डराना नहीं, गोपनीय शिकायत विवरण लीक नहीं, और निष्पक्ष सुनवाई रोकने हेतु पदक्रम शक्ति का उपयोग नहीं।\n\n'
          'यदि चिंता गंभीर है पर यौन उत्पीड़न नहीं, सही चैनल उपयोग करें (शिकायत निवारण, श्रम प्राधिकरण, आपराधिक क़ानून, या सिविल उपाय) — तथ्यों को जबरदस्ती POSH में न ठूँसें।',
      'guide14Title': '14. नियोक्ता अनुपालन सूची',
      'guide14Body':
          'अनुपालनशील नियोक्ता सामान्यतः: (1) 10+ कर्मचारी होने पर सही संरचना की IC गठित करे, (2) IC नामांकन व संपर्क अधिसूचित करे, (3) POSH नीति प्रकाशित व परिचालित करे, (4) यौन उत्पीड़न के परिणाम और शिकायत विधि पर स्पष्ट सूचनाएँ लगाए, (5) कर्मचारियों व IC सदस्यों के लिए नियमित जागरूकता/क्षमता निर्माण करे, (6) शिकायत प्रक्रिया में सहायता दे और IC/LC को सुविधाएँ उपलब्ध कराए, (7) समयबद्ध जाँच व सिफारिशों का वैधानिक समय में कार्यान्वयन सुनिश्चित करे, और (8) अधिनियम/नियमों के अनुसार आवश्यक रिपोर्ट/रिटर्न जमा करे।\n\n'
          'नियोक्ता को शिकायतकर्ता और गवाहों के विरुद्ध प्रतिशोध रोकना व संबोधित करना भी आवश्यक है। शिकायत के बाद डर का माहौल बनाना “तटस्थता” नहीं, अनुपालन विफलता है।\n\n'
          'अपने कार्यस्थल से माँगें: नीति PDF, IC सूची, प्रशिक्षण रिकॉर्ड, और शिकायत जमा विधि। बुनियादी अनुपालन जानकारी से इनकार हो तो उसे निजी रिकॉर्ड में नोट करें और LC/कानूनी सलाह मार्ग सोचें।\n\n'
          'सरकारी व निजी दोनों नियोक्ताओं से अधिनियम लागू होने पर मूल कर्तव्य पूरे करने की अपेक्षा है; आकार और क्षेत्र उन्हें मिटाते नहीं।',
      'guide15Title': '15. व्यावहारिक साक्ष्य सूची',
      'guide15Body':
          'साक्ष्य जल्दी सुरक्षित रखें। उपयोगी सामग्री अक्सर: दिनांक और हैंडल दिखते चैट/ईमेल/DM स्क्रीनशॉट; मूल संदेश निर्यात; कॉल लॉग; मीटिंग आमंत्रण/कैलेंडर; CCTV अनुरोध संदर्भ; निकटता दिखाने वाले एक्सेस-कार्ड/उपस्थिति लॉग; गवाहों के नाम और उन्होंने क्या देखा/सुना; प्रबंधक/HR को पूर्व लिखित शिकायतें; प्रासंगिक मेडिकल/परामर्श रिकॉर्ड (यदि आप साझा करना चुनें); तथा घटनाओं के तुरंत बाद लिखा व्यक्तिगत टाइमलाइन।\n\n'
          'संभव हो तो मूल रखें। मेटाडेटा मिटाने वाले संपादन से बचें। बैकअप एक से अधिक सुरक्षित जगह रखें। प्रक्रिया चलते हुए साक्ष्य सार्वजनिक रूप से पोस्ट न करें।\n\n'
          'कालक्रम नोट लिखें: तिथि → स्थान → क्या हुआ → कौन मौजूद था → आपने क्या कहा/किया → तत्काल प्रभाव → कोई आगे उत्पीड़न। नई घटनाओं पर अपडेट करें।\n\n'
          'Suraksha ड्राफ्ट रिकॉर्ड व्यवस्थित करने में मदद कर सकता है, पर आधिकारिक जमा अभी भी आपके IC/LC या अन्य सक्षम प्राधिकारी के पास जाना चाहिए। खतरे में सही दस्तावेज़ से पहले सुरक्षा और आपात सहायता प्राथमिकता दें।',
      'guide16Title': '16. अपील और अन्य उपाय',
      'guide16Body':
          'यदि आप IC/LC की सिफारिशों से व्यथित हैं, अधिनियम अधिसूचित न्यायालय/ट्रिब्यूनल में अपील का प्रावधान करता है — सामान्यतः समान अनुशासन मामलों के सेवा नियमों के अपीलीय मार्ग से जुड़ा। अपील समयबद्ध होती है (सामान्यतः सिफारिशों से 90 दिनों के भीतर, आपके मामले पर लागू अधिनियम/नियमों के अधीन)।\n\n'
          'POSH अपील से अलग, तथ्यों के अनुसार अन्य उपाय हो सकते हैं: आपराधिक अपराधों के लिए पुलिस/FIR; श्रम/सेवा-क़ानून चुनौतियाँ; सिविल दावे; उच्च प्रशासनिक प्राधिकरणों को शिकायत; या जहाँ उपयुक्त हो राष्ट्रीय/राज्य महिला आयोग।\n\n'
          'यदि नियोक्ता IC सिफारिशें लागू नहीं करता, चूक दर्ज करें और प्रवर्तन/अनुपालन शिकायत पर कानूनी सलाह लें।\n\n'
          'अपीलीय रणनीति मामला-विशिष्ट होती है, इसलिए लिखित परिणाम मिलते ही वकील से परामर्श करें ताकि परिसीमा अवधि न छूटे।',
      'guide17Title': '17. POSH पोर्टल का सद्भावपूर्ण उपयोग',
      'guide17Body':
          'Suraksha के इस POSH अनुभाग का सद्भाव से उपयोग करें: ढाँचा सीखें, सटीक ड्राफ्ट तैयार करें, साक्ष्य सूची व्यवस्थित करें, और IC बनाम आपराधिक मार्ग समझें। Suraksha में ड्राफ्ट या रिकॉर्ड सहेजना Internal Committee, Local Committee, नियोक्ता या सरकारी पोर्टल पर केस दाखिल नहीं करता।\n\n'
          'आधिकारिक कार्रवाई के लिए तैयार होने पर अपने कार्यस्थल IC/LC प्रक्रिया (या अन्य सक्षम प्राधिकारी) से जमा करें। Suraksha प्रतियाँ अपनी व्यक्तिगत तैयारी फ़ाइल के रूप में रखें।\n\n'
          'यदि नोट्स या स्थिति तत्काल खतरा दर्शाए, पहले 112 / आपात सेवाएँ कॉल करें, संभव हो तो सुरक्षित स्थान जाएँ, और Suraksha SOS से विश्वसनीय संपर्कों को सूचित करें। सुरक्षित होने के बाद कार्यस्थल शिकायत तैयारी जारी रख सकते हैं।\n\n'
          'केवल सत्य जानकारी साझा करें। पोर्टल का उपयोग दूसरों को परेशान करने, झूठे आरोप गढ़ने या गोपनीय केस विवरण फैलाने के लिए न करें। सद्भावपूर्ण उपयोग आपको और इस तंत्र की ज़रूरत वाले सभी को सुरक्षित रखता है।',
      'safeRouteChanged': 'सुरक्षित मार्ग बदल गया',
      'dailyRouteGuard': 'दैनिक मार्ग सुरक्षा',
      'routeGuardDialogTitle': 'दैनिक मार्ग बदल गया',
      'routeGuardDialogMessage':
          'आप अपने सामान्य मार्ग से हट गए हैं। कृपया पुष्टि करें कि आप सुरक्षित हैं।',
      'routeGuardConfirmWithin': '{seconds} सेकंड के भीतर पुष्टि करें।',
      'routeGuardDeviationMeters':
          'आपके सामान्य मार्ग से लगभग {meters} मीटर दूर।',
      'routeGuardLearningRoute': 'मार्ग सीख रहा है',
      'routeGuardRoutinesLearned': '{count} दिनचर्या सीखी गई',
      'routeGuardIntelligenceLimited': 'क्षेत्र डेटा सीमित',
      'routeGuardMapRouteActive': 'मानचित्र मार्ग सक्रिय',
      'safetyVerdictSafe': 'कम देखे गए जोखिम',
      'safetyVerdictSafeSummary':
          'उपलब्ध संकेतों के अनुसार यहाँ अभी कम देखा गया जोखिम है। यह सुरक्षा की गारंटी नहीं है—सतर्क रहें।',
      'safetyVerdictCaution': 'सावधानी बरतें',
      'safetyVerdictCautionSummary':
          'यहां अतिरिक्त सावधानी बरतें—आसपास कुछ जोखिम संकेत मिले हैं।',
      'safetyVerdictHighRisk': 'उच्च चिंता',
      'safetyVerdictHighRiskSummary':
          'यह क्षेत्र अभी सुरक्षित नहीं लग सकता, विशेषकर महिलाओं और बुजुर्ग उपयोगकर्ताओं के लिए।',
      'safetyVerdictLimitedDataSummary':
          'इस क्षेत्र के लिए अभी सीमित सत्यापित जानकारी है। सतर्क रहें और सामान्य दिन की सावधानियाँ बरतें।',
      'safetyVerdictSafeWithEmergencySummary':
          '1 किमी के भीतर आपातकालीन सहायता उपलब्ध है। देखा गया जोखिम कम लगता है, पर सुरक्षा की गारंटी नहीं है।',
      'safetyVerdictNoCoreEmergencySummary':
          '1 किमी के भीतर कोई पुलिस स्टेशन या अस्पताल नहीं मिला। इस क्षेत्र में सतर्क रहें।',
      'safetyEmergencyWithin1kmTitle': '1 किमी के भीतर आपातकालीन सेवाएँ',
      'safetyReasonNoCoreEmergency1km':
          '1 किमी के भीतर कोई पुलिस स्टेशन या अस्पताल उपलब्ध नहीं है।',
      'safetyReasonPoliceWithin1km':
          '1 किमी के भीतर {count} पुलिस स्टेशन।',
      'safetyReasonHospitalWithin1km':
          '1 किमी के भीतर {count} अस्पताल।',
      'safetyReasonPharmacyWithin1km':
          '1 किमी के भीतर {count} फार्मेसी।',
      'safetyReasonPetrolWithin1km':
          '1 किमी के भीतर {count} पेट्रोल पंप।',
      'safetyReasonWashroomWithin1km':
          '1 किमी के भीतर {count} शौचालय।',
      'safetyReasonBloodBankWithin1km':
          '1 किमी के भीतर {count} ब्लड बैंक।',
      'safetyVerdictMonitoring': 'अभी सीख रहा है',
      'safetyVerdictMonitoringSummary':
          'लाइव क्षेत्र जानकारी अभी बन रही है। आसपास सीखते समय सतर्क रहें।',
      'safetyWhySafeTitle': 'देखा गया जोखिम कम क्यों लगता है',
      'safetyWhyNotSafeTitle': 'यह क्षेत्र सुरक्षित क्यों नहीं लग सकता',
      'safetyWhatToDo': 'क्या करें',
      'safetyUpdatingAreaIntelligence': 'क्षेत्र सुरक्षा जानकारी अपडेट हो रही है...',
      'safetyActionSafe': 'सतर्क रहें और विश्वसनीय संपर्कों को पास रखें।',
      'safetyActionCaution':
          'रोशनी वाले क्षेत्रों में रहें और परिवार को सूचित रखें।',
      'safetyActionHighRisk':
          'एकांत रास्तों से बचें और लाइव लोकेशन किसी भरोसेमंद व्यक्ति के साथ साझा करें।',
      'safetyScoreDisclaimer':
          'स्कोर केवल देखे गए संकेतों पर आधारित हैं और क्षेत्र सुरक्षित होने की गारंटी नहीं देते।',
      'safetySourceGoogle': 'Google',
      'mapOfflineBannerTitle': 'ऑफ़लाइन — सीमित मानचित्र सुविधाएँ',
      'mapOfflineBannerBody':
          'अंतिम ज्ञात स्थान दिखाया जा रहा है। नज़दीकी सेवाएँ, रूटिंग और ताज़ा सुरक्षा डेटा के लिए इंटरनेट चाहिए।',
      'mapOfflinePlacesUnavailable':
          'नज़दीकी स्थानों के लिए इंटरनेट चाहिए। आपातकालीन कॉल अभी भी काम करती है।',
      'mapOfflineEmergencyHint':
          'मानचित्र डेटा के बिना भी आपातकालीन कार्रवाई उपलब्ध है:',
      'mapNearbyPlacesListTitle': 'नज़दीकी सुरक्षा स्थान',
      'mapTapToOpenPlace': 'यह स्थान खोलने के लिए दो बार टैप करें।',
      'routeGuardMonitoringActive': 'निगरानी सक्रिय',
      'routeGuardMonitoringInactive': 'निगरानी निष्क्रिय',
      'routeGuardLastChecked': 'अंतिम जाँच {time}',
      'routeGuardDataConfidence': 'डेटा विश्वास: {level}',
      'routeGuardConfidenceHigh': 'उच्च',
      'routeGuardConfidenceMedium': 'बन रहा है',
      'routeGuardConfidenceLow': 'सीमित',
      'routeGuardRouteLearned': 'मार्ग सीखा गया',
      'routeGuardRouteNotLearned': 'मार्ग नहीं सीखा',
      'liveLocationSharingWith': 'लाइव लोकेशन साझा की गई',
      'stopLiveLocationSharing': 'साझा करना बंद करें',
      'aiSafetyIntelligence': 'एआई सुरक्षा इंटेलिजेंस',
      'refreshIntelligence': 'इंटेलिजेंस रीफ्रेश करें',
      'couldNotOpenGoogleMaps': 'Google Maps नहीं खोला जा सका।',
      'listView': 'सूची दृश्य',
      'mapView': 'मानचित्र दृश्य',
      'nearbyCleanToilets': 'नज़दीकी स्वच्छ शौचालय',
      'toiletsRefresh': 'रीफ्रेश',
      'toiletsIncreaseRadius': 'त्रिज्या बढ़ाएँ',
      'toiletsOpenMap': 'मानचित्र खोलें',
      'toiletsTryAgain': 'फिर कोशिश करें',
      'toiletsViewOnMap': 'मानचित्र पर देखें',
      'toiletsNavigate': 'नेविगेट करें',
      'toiletsReportIssue': 'समस्या रिपोर्ट करें',
      'toiletsOpenNowOnly': 'केवल अभी खुले',
      'toiletsFemaleFacility': 'महिला सुविधा',
      'toiletsAccessible': 'सुगम्य',
      'toiletsWaterAvailable': 'पानी उपलब्ध',
      'toiletsResults': 'परिणाम',
      'toiletsRadiusLabel': 'त्रिज्या',
      'toiletsScopeLabel': 'दायरा',
      'toiletsAllRegistered': 'सभी शौचालय',
      'toiletsAllRegisteredShort': 'सभी',
      'toiletsQualityLabel': 'गुणवत्ता',
      'toiletsCleanOnly': 'केवल स्वच्छ',
      'toiletsCleanAndUsable': 'स्वच्छ + उपयोगी',
      'mapTraffic': 'ट्रैफ़िक',
      'mapTrafficSubtitle': 'सड़क ट्रैफ़िक ओवरले दिखाएँ',
      'mapPublicToilets': 'सार्वजनिक शौचालय',
      'mapLayers': 'मानचित्र परतें',
      'mapTypeNormal': 'सामान्य',
      'mapTypeHybrid': 'हाइब्रिड',
      'mapTypeTerrain': 'भूभाग',
      'couldNotFindLocation': 'वह स्थान नहीं मिला।',
      'couldNotOpenPlace': 'यह स्थान नहीं खोला जा सका।',
      'unableToOpenIssueReporting': 'समस्या रिपोर्टिंग नहीं खोली जा सकी।',
      'impactDetected': 'प्रभाव का पता चला',
      'cancelSos': 'SOS रद्द करें',
      'sendSosNow': 'अभी SOS भेजें',
      'later': 'बाद में',
      'openContacts': 'संपर्क खोलें',
      'servicePolice': 'पुलिस',
      'serviceHospitals': 'अस्पताल',
      'servicePharmacies': 'फार्मेसी',
      'servicePetrolPumps': 'पेट्रोल पंप',
      'serviceWashrooms': 'शौचालय',
      'serviceBloodBanks': 'ब्लड बैंक',
      'openNow': 'अभी खुला',
      'closedNow': 'अभी बंद',
      'hoursUnavailable': 'समय उपलब्ध नहीं',
      'currentLocationLabel': 'वर्तमान स्थान',
      'safetyScoreLabel': 'सुरक्षा स्कोर {score}',
      'policeCountLabel': '{count} पुलिस',
      'hospitalsCountLabel': '{count} अस्पताल',
      'pharmaciesCountLabel': '{count} फार्मेसी',
      'petrolPumpsCountLabel': '{count} पेट्रोल पंप',
      'washroomsCountLabel': '{count} शौचालय',
      'bloodBanksCountLabel': '{count} ब्लड बैंक',
      'toiletsCleanlinessLabel': 'स्वच्छता',
      'toiletsAvailabilityLabel': 'उपलब्धता',
      'toiletsLastUpdated': 'अंतिम अपडेट',
      'toiletsLastUpdatedNotAvailable': 'अंतिम अपडेट उपलब्ध नहीं',
      'toiletsNotAvailable': 'उपलब्ध नहीं',
      'toiletsStatusNotVerified': 'स्थिति सत्यापित नहीं',
      'toiletsFacilityFemale': 'महिला',
      'toiletsFacilityMale': 'पुरुष',
      'toiletsFacilityAccessible': 'सुगम्य',
      'toiletsFacilityWater': 'पानी',
      'toiletsCleanlinessScore': 'स्वच्छता स्कोर',
      'toiletsCleanlinessStatus': 'स्वच्छता स्थिति',
      'toiletsAvailability': 'उपलब्धता',
      'toiletsAddress': 'पता',
      'toiletsAddressNotAvailable': 'पता उपलब्ध नहीं',
      'toiletsFacilities': 'सुविधाएँ',
      'impactDetectedMessage':
          'आपका SOS काउंटडाउन सक्रिय है। यदि यह गलती से हुआ हो तो अभी कार्रवाई करें।',
      'saveEmergencyContactFirst': 'पहले आपातकालीन संपर्क सहेजें',
      'saveEmergencyContactFirstMessage':
          'कृपया पहले आपातकालीन संपर्क सहेजें, ताकि किसी भी आपात में आपके प्रियजनों को सबसे पहले पता चले।',
      'sosCountdownActiveMessage':
          'SOS काउंटडाउन सक्रिय है। यदि यह गलती से हुआ हो तो अभी रद्द करें।',
      'sosWillBeSentIn': 'SOS {seconds} सेकंड में भेजा जाएगा।',
      'screamDetected': 'चीख या तेज़ संकट ध्वनि का पता चला',
      'savingLastKnownLocation': 'अंतिम ज्ञात स्थान सहेजा जा रहा है...',
      'lastLocationSavedForHelp': 'आपातकालीन मदद के लिए अंतिम स्थान सहेजा गया।',
      'assessmentLimited': 'आकलन सीमित',
      'aiConfidenceLabel': 'एआई विश्वास {score}%',
      'riskLabelVerySafe': 'बहुत सुरक्षित',
      'riskLabelSafe': 'सुरक्षित',
      'riskLabelModerate': 'मध्यम जोखिम',
      'riskLabelHighRisk': 'उच्च जोखिम',
      'riskLabelCritical': 'गंभीर जोखिम',
      'riskLabelMonitoring': 'निगरानी',
      'riskLabelLocationOff': 'लोकेशन बंद',
      'riskLabelLearning': 'सीख रहा है',
      'statusInitializing': 'सुरक्षा मॉनिटर शुरू हो रहा है...',
      'statusGpsOff':
          'GPS बंद है। लाइव क्षेत्र डेटा के लिए लोकेशन चालू करें।',
      'statusLocationDeniedForever':
          'लोकेशन अनुमति स्थायी रूप से अस्वीकृत है। ऐप सेटिंग में सक्षम करें।',
      'statusLocationPermissionRequired':
          'रीयलटाइम सुरक्षा निगरानी के लिए लोकेशन अनुमति आवश्यक है।',
      'statusGpsConnected': 'GPS जुड़ा। रीयलटाइम सुरक्षा डेटा कैप्चर हो रहा है।',
      'statusFetchingIntelligence': 'क्षेत्र सुरक्षा जानकारी लाई जा रही है...',
      'statusLiveStreamPaused': 'लाइव लोकेशन स्ट्रीम रुकी हुई है।',
      'statusLiveIntelligenceActive':
          'आपके क्षेत्र के लिए लाइव सुरक्षा इंटेलिजेंस सक्रिय है।',
      'statusNearbyServicesLoaded':
          'नज़दीकी आपातकालीन सेवाएँ लाइव मैप डेटा से लोड हुईं।',
      'statusAreaAssessedLocal':
          'क्षेत्र सुरक्षा लाइव लोकेशन और स्थानीय संकेतों से आंकी गई।',
      'statusCannotReachServer':
          'Suraksha सर्वर से कनेक्ट नहीं हो सका। .env में LAN_BASE_URL अपने PC IP पर सेट करें।',
      'statusLearningDailyRoute':
          'लाइव GPS से दैनिक मार्ग पैटर्न सीखा जा रहा है।',
      'statusMapRouteCleared':
          'मानचित्र मार्ग साफ़। दैनिक मार्ग सुरक्षा जारी है।',
      'statusSafetyConfirmed':
          'सुरक्षा पुष्टि। मार्ग निगरानी जारी है।',
      'statusRouteHistoryReset':
          'मार्ग इतिहास रीसेट। सीखना अब फिर शुरू।',
      'statusSafeRouteChanged':
          'सुरक्षित मार्ग बदला। क्या आप सुरक्षित हैं?',
      'statusMonitoringMapRouteTo':
          '{name} तक सबसे सुरक्षित मानचित्र मार्ग की निगरानी।',
      'statusFollowingMapRoute': 'चयनित सबसे सुरक्षित मानचित्र मार्ग पर।',
      'statusFollowingMapRouteTo':
          '{name} तक चयनित सबसे सुरक्षित मानचित्र मार्ग पर।',
      'statusMovedAwayMapRoute':
          'आप चयनित सुरक्षित मानचित्र मार्ग से हट गए। क्या आप सुरक्षित हैं?',
      'statusLearningTravelRoutines':
          'आपकी दैनिक यात्रा दिनचर्या सीखी जा रही है।',
      'statusWatchingCommutePattern':
          'ज्ञात आवागमन पैटर्न की निगरानी हो रही है।',
      'statusMovedAwayUsualRoute':
          'आप अपने सामान्य मार्ग से हट गए। क्या आप सुरक्षित हैं?',
      'statusFollowingLearnedRoute':
          'आपके सीखे गए सुरक्षित दैनिक मार्ग पर।',
      'statusSafetyCheckEnded':
          'सुरक्षा जाँच समाप्त। मार्ग निगरानी जारी है।',
      'statusInitializingMap': 'मानचित्र सेवाएँ शुरू हो रही हैं...',
      'statusLocationServiceDisabled': 'लोकेशन सेवा बंद है।',
      'statusLocationPermissionDenied': 'लोकेशन अनुमति अस्वीकृत।',
      'statusDestinationReached': 'गंतव्य पहुँच गया',
      'statusLoadingBestRoute': 'सर्वोत्तम मार्ग लोड हो रहा है...',
      'statusRoadRoutingUnavailable':
          'सड़क मार्ग अनुपलब्ध (Maps API कुंजी गायब)।',
      'statusRoadRouteFallback':
          'सड़क मार्ग अनुपलब्ध, सीधी रेखा दिखा रहे हैं।',
      'routeFactorSelectedMapRoute': 'चयनित सबसे सुरक्षित मानचित्र मार्ग',
      'routeFactorStrongCommute': 'मजबूत आवागमन पैटर्न',
      'routeFactorRepeatedDaily': 'दोहराया गया दैनिक पैटर्न',
      'routeFactorNoMatchingRoutine':
          'इस यात्रा के लिए अभी कोई मेल खाती दिनचर्या नहीं',
      'routeProgressStrongCommute':
          'मजबूत आवागमन पैटर्न ({trips} यात्राएँ सीखीं)',
      'routeProgressProvisional':
          'अस्थायी पैटर्न ({trips}/{need} यात्राएँ)',
      'routeProgressRecordingTrip':
          'यात्रा रिकॉर्ड हो रही है · {need} और GPS बिंदु चाहिए',
      'routeProgressTakeUsualRoute':
          'सुरक्षा पैटर्न बनाने के लिए अपना सामान्य मार्ग दो बार लें',
      'routeProgressSavedTrips':
          '{trips} यात्राएँ सहेजीं · समय और मार्ग मेल चाहिए',
      'routeProgressRoutinesWaiting':
          '{count} दिनचर्या सहेजी · मेल की प्रतीक्षा',
      'routeChangedNotificationTitle': 'मार्ग बदला — क्या आप सुरक्षित हैं?',
      'routeChangedNotificationBody':
          'आप सामान्य मार्ग छोड़ गए। Suraksha खोलें और {seconds} सेकंड में मैं सुरक्षित हूँ टैप करें।',
      'cyberReasonCredentialRequest': 'संवेदनशील क्रेडेंशियल अनुरोध मिला।',
      'cyberReasonPaymentPressure':
          'भुगतान या खाता दबाव के संकेत मिले।',
      'cyberReasonBlackmail': 'ब्लैकमेल/जबरन वसूली के संकेत मिले।',
      'cyberThreatNoIndicators': 'कोई मजबूत स्थानीय संकेत नहीं मिले।',
      'cyberActionNoOtp': 'OTP/पासवर्ड साझा न करें',
      'cyberActionSaveEvidence': 'सबूत सहेजें',
      'cyberActionVerifyOfficial': 'आधिकारिक स्रोत से सत्यापित करें',
      'cyberTipNeverPayBlackmail': 'ब्लैकमेलरों को कभी पैसे न दें',
      'cyberTipReport1930': 'वित्तीय धोखाधड़ी 1930 पर रिपोर्ट करें',
      'cyberTipBlockSenders': 'संदिग्ध प्रेषकों को ब्लॉक करें',
      'cyberRiskHigh': 'उच्च',
      'cyberRiskMedium': 'मध्यम',
      'cyberRiskLow': 'कम',
      'learnPasswordTitle': 'पासवर्ड सुरक्षा',
      'learnPasswordSummary':
          'मजबूत पासवर्ड बनाएँ और रिकवरी चैनल सुरक्षित रखें।',
      'learnPasswordTip1': 'पासवर्ड मैनेजर उपयोग करें।',
      'learnPasswordTip2': 'दो-कारक प्रमाणीकरण सक्षम करें।',
      'learnPasswordTip3': 'पासवर्ड दोबारा उपयोग न करें।',
      'learnPasswordQuiz': 'क्या पासवर्ड दोबारा उपयोग सुरक्षित है?',
      'learnDatingTitle': 'ऑनलाइन डेटिंग सुरक्षा',
      'learnDatingSummary':
          'जबरदस्ती, नकली पहचान और छवि-आधारित दुरुपयोग जोखिम पहचानें।',
      'learnDatingTip1': 'वीडियो से सावधानी से सत्यापित करें।',
      'learnDatingTip2': 'अंतरंग मीडिया साझा न करें।',
      'learnDatingTip3': 'केवल सार्वजनिक स्थानों पर मिलें।',
      'learnDatingQuiz':
          'क्या आपको नए ऑनलाइन मैच को पैसे भेजने चाहिए?',
      'learnQuizNo': 'नहीं',
      'learnQuizYes': 'हाँ',
      'deepfakeTitle': 'डीपफेक और मॉर्फ्ड छवि आपातकालीन सहायता',
      'deepfakeSectionWhatTitle': 'डीपफेक क्या हैं?',
      'deepfakeSectionWhatBody':
          'हेरफेर किया मीडिया जो किसी व्यक्ति को नकली फोटो, ऑडियो या वीडियो में गलत दिखा सकता है।',
      'deepfakeSectionDoTitle': 'तुरंत क्या करें',
      'deepfakeSectionDoBody':
          'स्क्रीनशॉट, URL और प्रेषक ID सहेजें। पैसे न दें और बातचीत न करें। cybercrime.gov.in पर रिपोर्ट करें।',
      'deepfakeSectionEvidenceTitle': 'सबूत संरक्षण',
      'deepfakeSectionEvidenceBody':
          'मूल फ़ाइलें, समय-चिह्न, प्लेटफ़ॉर्म लिंक और लेनदेन विवरण रखें।',
      'helplineCyberCrime': 'साइबर क्राइम हेल्पलाइन',
      'helplinePoliceEmergency': 'पुलिस आपातकाल',
      'notAvailableShort': 'उपलब्ध नहीं',
      'contributingFactorsTitle': 'योगदान देने वाले कारक',
      'recommendedActionsTitle': 'अनुशंसित कार्रवाई',
      'priorityCritical': 'गंभीर',
      'priorityCaution': 'सावधानी',
      'priorityInfo': 'जानकारी',
      'timeJustNow': 'अभी',
      'timeMinutesAgo': '{count} मि पहले',
      'timeHoursAgo': '{count} घं पहले',
      'timeDaysAgo': '{count} दि पहले',
      'alertCategoryUpcomingRisk': 'आगामी जोखिम क्षेत्र',
      'alertCategoryVerifiedIncident': 'सत्यापित घटना रिपोर्ट',
      'alertCategoryAreaIncidentStatus': 'क्षेत्र घटना स्थिति',
      'alertCategoryRoadLighting': 'सड़क रोशनी',
      'alertCategoryCrowdActivity': 'भीड़ गतिविधि',
      'alertCategoryGridRisk': 'ग्रिड जोखिम मॉडल',
      'alertCategoryDistrictCrime': 'ज़िला अपराध संदर्भ',
      'alertCategoryEmergencyInfra': 'आपातकालीन अवसंरचना',
      'alertCategoryCommunitySafeRoute': 'समुदाय सुरक्षित मार्ग',
      'alertCategoryAreaSafety': 'क्षेत्र सुरक्षा',
      'alertCategoryPublicTransport': 'सार्वजनिक परिवहन',
      'alertCategoryPublicTransportNetwork': 'सार्वजनिक परिवहन नेटवर्क',
      'alertCategoryPedestrianActivity': 'पैदल गतिविधि',
      'alertCategoryRegionNotice': 'क्षेत्र सूचना',
      'alertSummaryUpcomingRisk': 'आगे बढ़े जोखिम की स्थिति अपेक्षित है।',
      'alertActionUpcomingRisk':
          'गति कम करें, सतर्क रहें, और वैकल्पिक मार्ग सोचें।',
      'alertSummaryIncidentCategory':
          '{region} में पास {category} की रिपोर्ट दर्ज हुई।',
      'alertSummaryIncidentGeneric':
          'पास हाल की सत्यापित घटना दर्ज हुई।',
      'alertActionVerifiedIncident':
          'सामान पास रखें, एकांत में फोन उपयोग से बचें, और सतर्क रहें।',
      'alertDisclaimerSurakshaReports':
          'सत्यापित Suraksha उपयोगकर्ता रिपोर्ट पर आधारित। आधिकारिक पुलिस रिकॉर्ड नहीं।',
      'alertSummaryNoIncidents':
          '{region} में इस स्थान के पास पिछले 72 घंटों में कोई सत्यापित Suraksha घटना रिपोर्ट नहीं।',
      'alertActionNoIncidents':
          'पास हाल की ऐप-रिपोर्ट घटनाएँ नहीं। निगरानी जारी रखें और कम ट्रैफ़िक क्षेत्रों में सतर्क रहें।',
      'alertDisclaimerNoIncidents':
          'ऐप रिपोर्ट न होना शून्य अपराध की गारंटी नहीं। आधिकारिक डेटा भिन्न हो सकता है।',
      'alertSunsetCivilTwilight': 'नागरिक गोधूलि के बाद',
      'alertSunsetNightHours': 'रात के घंटों में',
      'alertSummaryUnlitNearby':
          'OpenStreetMap {meters} मी के भीतर बिना रोशनी वाले सड़क खंड दिखाता है। स्थितियाँ {sunset} हैं।',
      'alertSummaryMostlyLit':
          'OpenStreetMap रोशनी टैग पास अधिकतर रोशन गलियारे सुझाते हैं। फिर भी दृश्यता कम है {sunset}।',
      'alertSummaryDarkLimited':
          '{region} में अंधेरा है। इस हिस्से के लिए सड़क रोशनी डेटा सीमित है।',
      'alertActionRoadLighting':
          'रोशन मुख्य सड़कों पर रहें। ज़रूरत हो तो टॉर्च उपयोग करें और छायादार रास्तों से बचें।',
      'alertDisclaimerLighting':
          'सूर्यास्त समय से अनुमानित रोशनी। OSM सड़क रोशनी टैग अधूरे हो सकते हैं।',
      'alertSummaryCrowdHigh':
          'पास ऊँची अनाम ऐप गतिविधि ({pings} पिंग, 2 घंटे, {cells} सेल)।',
      'alertSummaryCrowdModerate':
          'पास मध्यम अनाम ऐप गतिविधि ({pings} पिंग, 2 घंटे)।',
      'alertSummaryCrowdVeryLow':
          'पिछले 2 घंटों में पास बहुत कम अनाम ऐप गतिविधि।',
      'alertSummaryCrowdLow':
          'पास कम अनाम ऐप गतिविधि ({pings} पिंग, 2 घंटे)।',
      'alertActionCrowdVeryLowDark':
          'आसपास कम लोग हो सकते हैं। आबाद और रोशन मार्ग चुनें।',
      'alertActionCrowdGeneral':
          'भीड़ पैटर्न कई संकेतों में से एक है—परिस्थिति के प्रति सजग रहें।',
      'alertDisclaimerCrowd':
          'अनाम Suraksha ऐप गतिविधि पिंग पर आधारित—लाइव फुटफॉल सेंसर नहीं।',
      'alertSummaryGridRisk':
          'इस ~1 किमी ग्रिड के लिए {label} (30 दिन में {count30d} घटना, 7 दिन में {count7d})।',
      'alertActionGridElevated':
          'इस ग्रिड में ऐतिहासिक घटना पैटर्न ऊँचे हैं—सतर्क रहें और मुख्य सड़कें चुनें।',
      'alertActionGridModerate':
          'ग्रिड इतिहास मध्यम है। लाइव अलर्ट की निगरानी जारी रखें।',
      'alertDisclaimerGrid':
          'ऐतिहासिक घटना पैटर्न पर आधारित सांख्यिकीय ग्रिड मॉडल।',
      'alertSummaryDistrictCrime':
          'नाशिक ज़िला ओपन-डेटा संदर्भ ({period}): प्रति 100k जनसंख्या पर ~{rate} रिपोर्टेड घटनाएँ। केवल क्षेत्र-स्तरीय संदर्भ।',
      'alertActionDistrictCrime':
          'इसे क्षेत्रीय पृष्ठभूमि मानें—आपके सटीक स्थान का लाइव अपराध अलर्ट नहीं।',
      'alertDisclaimerDistrictCrime': 'केवल ज़िला-स्तरीय ओपन डेटा संदर्भ।',
      'alertSummaryEmergencyInfra':
          'नज़दीकी सहायता स्कैन: {police} पुलिस, {hospitals} अस्पताल/क्लिनिक, और {fuel} ईंधन स्टेशन सुविधाएँ आपके {radius} किमी के भीतर।',
      'alertActionEmergencySparse':
          'यहाँ आपातकालीन सहायता कम है। SOS तैयार रखें और लाइव लोकेशन साझा करें।',
      'alertActionEmergencyAvailable':
          'मैप की गई आपातकालीन अवसंरचना पास उपलब्ध है।',
      'alertDisclaimerEmergencyInfra':
          'OSM, Google Places और Suraksha प्राधिकरण मैपिंग से संयुक्त। उपलब्धता बदल सकती है।',
      'alertSummaryEmergencyLimited':
          'नाशिक में इस स्थान के पास सीमित मैप पुलिस, अस्पताल या रेस्पॉन्डर कवरेज।',
      'alertActionEmergencyLimited':
          'SOS तैयार रखें। आगे बढ़ने से पहले आपातकालीन संपर्क को अपना स्थान बताएँ।',
      'alertDisclaimerEmergencyLimited':
          'Suraksha + OpenStreetMap कवरेज से प्राप्त। सभी सुविधाएँ सूचीबद्ध नहीं हो सकतीं।',
      'alertSummarySafeCorridor':
          'आपके मार्ग के पास {count} समुदाय-सत्यापित सुरक्षित गलियारा।',
      'alertActionSafeCorridor':
          'हाइलाइट समुदाय-सत्यापित पथ के लिए सुरक्षा मानचित्र खोलें।',
      'alertActionAreaHighRisk':
          'SOS सक्रिय करें, भरोसेमंद संपर्क से लाइव लोकेशन साझा करें, और वैकल्पिक मार्ग सोचें।',
      'alertActionAreaReview':
          'नीचे दिए कारण देखें और अनुशंसित कार्रवाई अपनाएँ।',
      'alertActionAreaManageable':
          'स्थितियाँ संभालने योग्य लगती हैं। नज़दीकी अपडेट की निगरानी जारी रखें।',
      'alertActionAreaStayAlert':
          'सतर्क रहें, लाइव लोकेशन साझा करें, और SOS तैयार रखें।',
      'alertActionAreaSafe':
          'कोई मजबूत जोखिम संकेत नहीं। सामान्य सजगता जारी रखें।',
      'alertSummaryAreaSafeVerified':
          'लाइव संकेतों के आधार पर यह क्षेत्र अभी सुरक्षित लगता है।',
      'alertSummaryPublicTransport':
          'ऑटो रिक्शा, MSRTC बसें और टैक्सी आमतौर पर नाशिक के मुख्य गलियारों पर चलती हैं। उपलब्धता समय और मार्ग के अनुसार बदलती है।',
      'alertActionPublicTransport':
          'ऑटो, बस या टैक्सी के लिए मुख्य सड़कें और व्यस्त चौराहे उपयोग करें।',
      'alertDisclaimerPublicTransport':
          'सामान्य नाशिक परिवहन मार्गदर्शन—लाइव ट्रांज़िट API डेटा नहीं। वर्तमान सेवा स्थानीय रूप से जाँचें।',
      'alertSummaryPublicTransportNetwork':
          'आपके वर्तमान स्थान के आसपास ऑटो रिक्शा, बस, टैक्सी और अन्य स्थानीय परिवहन उपलब्ध हैं।',
      'alertActionPublicTransportNetwork':
          'सबसे तेज़ पिकअप के लिए मुख्य सड़क या व्यस्त चौराहे पर जाएँ।',
      'alertSummaryLightingLateNight':
          'आधी रात के बाद आपके क्षेत्र में सड़कें कम रोशन हो सकती हैं।',
      'alertSummaryLightingEvening':
          'शाम 7 बजे के बाद दृश्यता कम। पास सड़क रोशनी असंगत हो सकती है।',
      'alertSummaryPedestrianLateNight':
          'आधी रात के बाद इस क्षेत्र में बहुत कम पैदल गतिविधि अपेक्षित है।',
      'alertSummaryPedestrianNight':
          'इस गलियारे में शाम 8 बजे के बाद पैदल यातायात आमतौर पर कम होता है।',
      'alertSummaryPedestrianDay':
          'दिन के समय आपके पास सामान्य पैदल गतिविधि अपेक्षित है।',
      'alertActionPedestrianNight':
          'एकांत मार्गों से बचें और जहाँ लोग दिखें वहाँ रहें।',
      'alertActionPedestrianDay':
          'क्षेत्र गतिविधि सामान्य लगती है। मानक सावधानियाँ जारी रखें।',
      'alertSummaryOutsideRegion':
          'चरण 1 सुरक्षा इंटेलिजेंस {region} के लिए अनुकूलित है। आप मैप क्षेत्र से बाहर लगते हैं—कुछ संकेत सीमित हो सकते हैं।',
      'alertActionOutsideRegion':
          'पूर्ण OSM, भीड़ और घटना फ़्यूज़न कवरेज के लिए नाशिक में रहें।',
      'alertDisclaimerNashik':
          'नाशिक क्षेत्र के लिए सुरक्षा इंटेलिजेंस। संकेत अधूरे हो सकते हैं।',
      'alertReasonSeriousViolentCrime':
          'पास गंभीर हिंसक अपराध रिपोर्ट हुआ है।',
      'alertReasonCrimeSignalsElevated':
          'इस स्थान के पास अपराध-संबंधी संकेत ऊँचे हैं।',
      'safetyReasonSupportNearby':
          'आसपास विश्वसनीय आपातकालीन सहायता उपलब्ध है।',
      'safetyReasonPlentyEmergencyServices':
          'इस क्षेत्र में पर्याप्त आपातकालीन सेवाएँ मौजूद हैं।',
      'safetyReasonNoCrimesReported':
          'अभी इस क्षेत्र में कोई अपराध दर्ज नहीं है।',
      'safetyReasonGoodDaytimeFootfall':
          'आसपास की सड़कों पर काफी भीड़ और चहल-पहल है, जिससे दिन में यह क्षेत्र सुरक्षित महसूस होता है।',
      'safetyReasonRegisteredMurder':
          'इस क्षेत्र में दर्ज हत्या के मामले रिपोर्ट हुए हैं।',
      'safetyReasonRegisteredHalfMurder':
          'इस क्षेत्र में दर्ज हाफ मर्डर या हत्या के प्रयास के मामले रिपोर्ट हुए हैं।',
      'safetyReasonRegisteredDrug':
          'इस क्षेत्र में दर्ज नशीले पदार्थ से जुड़े मामले रिपोर्ट हुए हैं।',
      'safetyReasonRegisteredRobbery':
          'इस क्षेत्र में दर्ज लूट के मामले रिपोर्ट हुए हैं।',
      'safetyReasonRegisteredTheft':
          'इस क्षेत्र में दर्ज चोरी के मामले रिपोर्ट हुए हैं।',
      'safetyReasonRegisteredChainSnatching':
          'इस क्षेत्र में दर्ज चेन-स्नैचिंग के मामले रिपोर्ट हुए हैं।',
      'safetyReasonRegisteredAssault':
          'इस क्षेत्र में दर्ज हमले या उत्पीड़न के मामले रिपोर्ट हुए हैं।',
      'safetyReasonNightTraffic':
          'सड़क यातायात और गतिविधि पैटर्न शाम 7 बजे के बाद अतिरिक्त सावधानी का संकेत देते हैं।',
      'safetyReasonNormalFootfall':
          'सामान्य पैदल गतिविधि से लगता है क्षेत्र एकांत नहीं है।',
      'safetyReasonGoodLighting':
          'इस क्षेत्र में रोशनी और बुनियादी ढाँचे के संकेत स्थिर लगते हैं।',
      'safetyReasonLowRiskSignals':
          'अभी कोई मजबूत जोखिम संकेत नहीं मिल रहे।',
      'safetyReasonDrugActivity':
          'इस क्षेत्र में हाल ही में नशीले पदार्थ से जुड़ी गतिविधि रिपोर्ट हुई है।',
      'safetyReasonChainSnatching':
          'आसपास चेन-snatching के मामले दर्ज हुए हैं।',
      'safetyReasonTheftProne':
          'यह हिस्सा चोरी से जुड़ी घटनाओं के लिए जाना जाता है।',
      'safetyReasonHarassmentReports':
          'आसपास उत्पीड़न या हमले की रिपोर्ट दर्ज हुई हैं।',
      'safetyReasonPoorLighting':
          'खराब सड़क रोशनी से यहां दृश्यता कम हो सकती है।',
      'safetyReasonLowFootfall':
          'कम पैदल यातायात से यह क्षेत्र अलग-थलग महसूस हो सकता है।',
      'safetyReasonCrimeActivity':
          'आसपास की घटनाएं अभी भी बढ़ी हुई हैं।',
      'safetyReasonLimitedSupport':
          'आसपास सीमित आपातकालीन सहायता बिंदु त्वरित मदद में देरी कर सकते हैं।',
      'safetyReasonNightRisk':
          'रात के समय दृश्यता और सार्वजनिक गतिविधि कम हो जाती है।',
      'safetyReasonGpsLimited':
          'लाइव स्थान सटीकता सीमित है; GPS सुधरने पर आकलन अपडेट हो सकता है।',
      'safetyReasonUnsafeNightlife':
          'असुरक्षित नाइटलाइफ या red-light गतिविधि यहां जोखिम बढ़ा सकती है।',
      'safetyReasonGeneralCaution':
          'इस क्षेत्र में अतिरिक्त सावधानी की सलाह है।',
      'safetyReasonLimitedData':
          'सत्यापित लाइव क्षेत्र डेटा सीमित है — यहां अतिरिक्त सतर्क रहें।',
      'routeVerdictChanged': 'मार्ग बदला',
      'routeVerdictChangedSummary':
          'आप अपने सामान्य मार्ग से हट गए हैं। कृपया पुष्टि करें कि आप सुरक्षित हैं।',
      'routeVerdictLearning': 'मार्ग सीख रहा है',
      'routeVerdictLearningSummary':
          'दैनिक मार्ग सुरक्षा आपके लाइव GPS से यात्रा पैटर्न सीख रही है।',
      'routeVerdictOnTrack': 'सामान्य मार्ग पर',
      'routeVerdictOnTrackSummary':
          'आप अपने सीखे हुए सुरक्षित दैनिक मार्ग पर हैं।',
      'routeVerdictCaution': 'मार्ग सावधानी',
      'routeVerdictCautionSummary':
          'कुछ मार्ग स्थितियों पर अभी अतिरिक्त ध्यान देना जरूरी है।',
      'routeVerdictAlert': 'मार्ग चेतावनी',
      'routeVerdictAlertSummary':
          'आपका वर्तमान मार्ग आपके सामान्य सुरक्षित पैटर्न से मेल नहीं खाता।',
      'refresh': 'रीफ़्रेश',
      'openMap': 'मानचित्र खोलें',
      'resetHomeWorkplaceRouteLearning': 'घर-कार्यस्थल मार्ग सीखना रीसेट करें',
      'homeWorkplaceRouteLearningReset':
          'घर-कार्यस्थल मार्ग सीखना रीसेट हो गया।',
      'safetyCheckEndsIn': 'सुरक्षा जांच समाप्त होगी',
      'unlessYouConfirm': 'जब तक आप पुष्टि नहीं करते।',
      'imSafe': 'मैं सुरक्षित हूँ',
      'routeGuardNeedHelp': 'मदद चाहिए',
      'statusRouteGuardEscalated':
          'सुरक्षा पुष्टि नहीं मिली। आपातकालीन SOS शुरू किया गया।',
      'statusRouteGuardHelpRequested':
          'मार्ग सुरक्षा से आपातकालीन SOS शुरू किया गया।',
      'pleaseFillAllRequiredDetails': 'कृपया सभी आवश्यक विवरण भरें।',
      'complaintSubmittedSuccessfully': 'शिकायत सफलतापूर्वक सबमिट की गई।',
      'submissionFailedTryAgain': 'सबमिशन विफल रहा। कृपया पुनः प्रयास करें।',
      'openDetailedPoshActGuide': 'विस्तृत POSH अधिनियम मार्गदर्शिका खोलें',
      'clearPreviousQuizToUnlockThisLevel':
          'इस स्तर को अनलॉक करने के लिए पिछला क्विज़ साफ़ करें।',
      'previous': 'पिछला',
      'retryQuiz': 'क्विज़ फिर से प्रयास करें',
      'pleaseAnswerEveryQuestionFirst': 'कृपया पहले हर प्रश्न का उत्तर दें।',
      'pleaseAnswerThisQuestionBeforeContinuing':
          'कृपया जारी रखने से पहले इस प्रश्न का उत्तर दें।',
      'currentLevel': 'वर्तमान स्तर',
      'detailedPoshActGuide': 'विस्तृत POSH अधिनियम मार्गदर्शिका',
      'cyberLawHubTitle': 'साइबर क्राइम कानून पुस्तकालय',
      'cyberLawDeepfakeFullGuide': 'पूर्ण डीपफेक कानूनी गाइड',
      'cyberLawHubSubtitle': 'अपने अधिकार जानें। कानून जानें। लड़ना सीखें।',
      'cyberLawHelplineTitle': 'आपातकालीन हेल्पलाइन',
      'cyberLawHelplineDesc': 'साइबर क्राइम: 1930  |  महिला: 181  |  बाल: 1098  |  पुलिस: 112',
      'cyberLawOverviewHeader': 'अवलोकन',
      'cyberLawActsHeader': 'लागू कानून एवं धाराएं',
      'cyberLawPunishmentHeader': 'कानूनी दंड',
      'cyberLawWhatToDoHeader': 'यदि आप पीड़ित हैं तो क्या करें',
      'cyberLawReportHeader': 'शिकायत कहाँ करें',
      'authEnterEmailPhonePassword': 'कृपया ईमेल/फोन और पासवर्ड दर्ज करें।',
      'authLoginFailed': 'लॉगिन विफल। कृपया पुनः प्रयास करें।',
      'authVerificationFailed': 'सत्यापन विफल। पुनः प्रयास करें।',
      'authFillRequiredFields':
          'कृपया सभी आवश्यक फ़ील्ड भरें (पासवर्ड कम से कम 8 अक्षर)।',
      'authSignupFailed': 'साइन अप विफल। कृपया पुनः प्रयास करें।',
      'logoutBeforeNewSignup':
          'नया खाता बनाने से पहले अपने वर्तमान खाते से लॉग आउट करें।',
      'authPasswordMinLength': 'पासवर्ड कम से कम 8 अक्षर का होना चाहिए।',
      'authResetPasswordFailed': 'पासवर्ड रीसेट नहीं हो सका। पुनः प्रयास करें।',
      'authRequestTimedOut':
          'अनुरोध समय समाप्त। अपना कनेक्शन जाँचें और पुनः प्रयास करें।\nसर्वर: {server}',
      'authCouldNotReachServer':
          'सर्वर {server} तक नहीं पहुँचा जा सका। सुनिश्चित करें कि बैकएंड चल रहा है।',
      'networkRequestFailed': 'नेटवर्क अनुरोध विफल',
      'invalidDetails': 'अमान्य विवरण।',
      'networkRequestTimedOut': 'अनुरोध समय समाप्त। कृपया पुनः प्रयास करें।',
      'profileUserNamePlaceholder': 'उपयोगकर्ता नाम',
      'profileEmailPlaceholder': 'email@example.com',
      'emergencyContactDefault': 'आपातकालीन संपर्क',
      'routeGuardMetersFromPattern': 'पैटर्न से {meters} मी',
      'routeGuardMapPoints': '{count} मानचित्र बिंदु',
      'routeGuardRouteLogs': '{count} मार्ग लॉग',
      'countdownMinutesSeconds': '{minutes}मि {seconds}से',
      'distressPhraseDetected': 'संकट वाक्यांश का पता चला',
      'distressMatchedPhrase': 'मेल: {phrase}',
      'distressScreamConfidence': 'चीख विश्वास: {percent}%',
      'emergencyFetchingLocation': 'स्थान प्राप्त किया जा रहा है...',
      'emergencyLiveFeedActive': 'लाइव फ़ीड सक्रिय ({time})',
      'emergencyLiveTransmissionStarting': 'लाइव प्रसारण शुरू हो रहा है...',
      'emergencyLiveTransmissionPaused': 'लाइव प्रसारण रोका गया',
      'dashboardSosLabel': 'SOS',
      'a11yOpenEmergencyMode': 'आपातकालीन मोड खोलें। SOS सक्रिय है।',
      'a11ySendMessage': 'संदेश भेजें',
      'mapHeatmapLegend':
          'रंगीन मानचित्र क्षेत्र सापेक्ष जोखिम दिखाते हैं। केवल रंग नहीं — नीचे स्कोर, जोखिम लेबल और कारण देखें।',
      'featureUnavailable': 'यह सुविधा अभी उपलब्ध नहीं है।',
      'featureFlagDisabledHint': 'इस बिल्ड में यह क्षमता बंद है।',
      'partialDeliveryBanner':
          'आंशिक सफलता: कुछ आपातकालीन अलर्ट पहुँचे।',
      'dashboardPoshLabel': 'POSH',
      'communityAlertStayAwareFallback':
          'मानचित्र पर नज़दीकी स्थिति देखें और चलते समय सतर्क रहें।',
      'poshQuizStudySubtitle':
          'पहले पूरा ढाँचा पढ़ें, फिर प्रमाणपत्र के लिए तीन क्विज़ स्तर पूरे करें।',
      'poshQuizAllLevelsCleared': 'सभी स्तर पूरे। आपका प्रमाणपत्र तैयार है।',
      'poshQuizQuestionsCount': '{count} प्रश्न',
      'poshQuizMixedMcq': 'मिश्रित MCQ',
      'poshQuizSingleChoice': 'एक विकल्प',
      'poshQuizQuestionProgress': 'प्रश्न {current} / {total}',
      'poshQuizAnsweredCount': '{count} उत्तर दिए',
      'poshQuizCertificateEarned':
          'आपने तीनों क्विज़ स्तर पूरे कर प्रमाणपत्र अर्जित किया।',
      'poshQuizNextLevelUnlocked': 'बढ़िया। अगला स्तर अब अनलॉक है।',
      'poshQuizReviewScore':
          'आपका स्कोर {score}/{total}। अध्ययन अनुभाग देखें और इस स्तर को फिर से करें।',
      'poshComplaintTimedOut': 'शिकायत अनुरोध समय समाप्त। पुनः प्रयास करें।',
      'poshComplaintNetworkUnavailable':
          'नेटवर्क उपलब्ध नहीं। इंटरनेट जाँचें और पुनः प्रयास करें।',
      'poshComplaintSessionExpired':
          'सत्र समाप्त। शिकायत भेजने के लिए फिर साइन इन करें।',
      'poshComplaintTitle': 'POSH कार्यस्थल शिकायत',
      'poshComplaintComplainant': 'शिकायतकर्ता: {name}',
      'poshComplaintPhone': 'फोन: {phone}',
      'poshComplaintEmail': 'ईमेल: {email}',
      'poshComplaintAccused': 'आरोपी: {name}',
      'poshComplaintWorkplace': 'कार्यस्थल: {name}',
      'poshComplaintIncidentDate': 'घटना तिथि: {date}',
      'poshComplaintIncidentLocation': 'घटना स्थान: {location}',
      'poshComplaintWitnesses': 'गवाह: {witnesses}',
      'poshComplaintDetails': 'शिकायत विवरण: {details}',
      'cyberNoSummaryAvailable': 'कोई सारांश उपलब्ध नहीं।',
      'cyberReportGenerated': 'रिपोर्ट तैयार की गई।',
      'cyberReportDefaultTitle': 'साइबर रिपोर्ट',
      'cyberReportedStatus': 'रिपोर्ट की गई',
      'cyberEvidenceLabel': 'साक्ष्य',
      'cyberOtherCategory': 'अन्य',
      'cyberDeepfakeAwareness': 'डीपफेक जागरूकता',
      'cyberHelpline': 'हेल्पलाइन',
      'cyberInformation': 'जानकारी',
      'cyberShareComplaintSubject': 'सुरक्षा साइबर अपराध शिकायत',
      'cyberShareComplaintBody': 'सुरक्षा द्वारा तैयार साइबर अपराध PDF।',
      'cyberShareEvidenceSubject': 'सुरक्षा साइबर साक्ष्य',
      'cyberShareEvidenceBody': 'सुरक्षा से निर्यात साइबर साक्ष्य।',
      'cyberSharePackageSubject': 'सुरक्षा साक्ष्य पैकेज',
      'cyberSharePackageBody': 'सुरक्षा वॉल्ट से निर्यात साक्ष्य पैकेज।',
      'medicalDefaultBloodGroup': 'O पॉज़िटिव',
      'medicalDefaultAllergies': 'मूंगफली, पेनिसिलिन',
      'medicalDefaultConditions': 'अस्थमा',
      'medicalDefaultMedications': 'इनहेलर (आवश्यकतानुसार)',
      'mapInitializingServices': 'मानचित्र सेवाएँ प्रारंभ हो रही हैं...',
      'mapLocationServiceDisabled': 'स्थान सेवा अक्षम है।',
      'mapLocationPermissionDenied': 'स्थान अनुमति अस्वीकृत।',
      'mapUpcomingElevatedRisk': 'आगामी बढ़ा हुआ जोखिम',
      'mapLoadingBestRoute': 'सर्वोत्तम मार्ग लोड हो रहा है...',
      'mapRoadRoutingUnavailable': 'सड़क मार्ग उपलब्ध नहीं (Maps API key गायब)।',
      'mapNearbyServicesPartialIssues':
          'नज़दीकी सेवाएँ आंशिक रूप से लोड हुईं: {errors}',
      'mapNearbyServicesLoadFailed':
          'नज़दीकी सेवाएँ लोड नहीं हो सकीं। पुनः प्रयास करें।',
      'mapPoliceStationFallback': 'पुलिस स्टेशन',
      'mapPoliceStationsLabel': 'पुलिस स्टेशन',
      'mapHospitalsLabel': 'अस्पताल',
      'mapSelectedDestinationFallback': 'चयनित गंतव्य',
      'mapDirectFallbackRouteReason': 'Google रूटिंग के बिना सीधा फ़ॉलबैक मार्ग',
      'nearbyGpsUnavailable': 'लाइव GPS उपलब्ध नहीं। स्थान ON रखें।',
      'nearbyGoogleMapsKeyMissing':
          'नज़दीकी स्थान उपलब्ध नहीं हैं। Suraksha बैकएंड पर GOOGLE_MAPS_API_KEY सेट करें।',
      'nearbyPlacesApiError': 'Places API त्रुटि: {status}',
      'nearbyUnnamedPlace': 'अनाम स्थान',
      'nearbyAddressUnavailable': 'पता उपलब्ध नहीं',
      'nearbyFetchFailed': 'अभी नज़दीकी स्थान लोड नहीं हो सके। पुनः प्रयास करें।',
      'safetyEmergencyServicesWithin1Km': '1 किमी के भीतर आपातकालीन सेवाएँ',
      'distressMonitorNotificationTitle': 'सुरक्षा संकट मॉनिटर सक्रिय',
      'distressMonitorNotificationText':
          'ऑफ़लाइन चीख और मदद वाक्यांश सुन रहा है।',
      'distressMonitorTestModeNotification': 'टेस्ट मोड — SOS नहीं भेजा जाएगा।',
      'smsLastKnownLocation': 'अंतिम ज्ञात स्थान: {url}',
      'smsTrackLiveLocation': 'लाइव स्थान ट्रैक करें: {url}',
      'sosActivatedSmsPermissionNeeded':
          'SOS सक्रिय। आपातकालीन संपर्कों को सूचित करने के लिए SMS अनुमति चाहिए।',
      'sosRealtimeConnectionFailed':
          'रीयलटाइम कनेक्शन विफल। SOS सहेजा गया; संपर्कों को सूचना मिल सकती है।',
      'sosMicrophonePermissionNeeded': 'चीख पहचान के लिए माइक्रोफोन अनुमति चाहिए।',
      'communityAlertGoogleMapsKeyMissing': 'Google Maps API key गायब है।',
      'communityAlertLoadFailed': 'अभी लाइव सामुदायिक अलर्ट लोड नहीं हो सके।',
      'communityAlertTrafficDataLimited': 'नज़दीक ट्रैफ़िक डेटा सीमित',
      'communityAlertTrafficSampleFailed':
          'Google Maps से नज़दीकी ड्राइविंग मार्ग नहीं लिए जा सके।',
      'communityAlertHeavyTraffic': 'आपके पास भारी ट्रैफ़िक',
      'communityAlertHeavyTrafficDetail':
          'Google Maps नज़दीकी मार्गों पर सामान्य से धीमा समय दिखाता है।',
      'communityAlertTrafficNormal': 'नज़दीक ट्रैफ़िक सामान्य लग रहा है',
      'communityAlertTrafficNormalDetail':
          'नमूना मार्गों पर समय इस समय के लिए सामान्य लगता है।',
      'communityAlertRouteBlockage': 'संभावित रोड ब्लॉक या डिटूर',
      'communityAlertRouteBlockageDetail':
          'कुछ मार्गों पर असामान्य देरी है — रुकावट संभव।',
      'communityAlertTransportAvailable': 'सार्वजनिक परिवहन उपलब्ध',
      'communityAlertTransportAvailableDetail':
          'आपके पास बस स्टॉप, मेट्रो या रेल स्टेशन मिले।',
      'communityAlertLowActivity': 'कम गतिविधि वाला क्षेत्र',
      'communityAlertLowActivityDetail':
          'आपके आसपास अभी कम सार्वजनिक स्थान सक्रिय हैं।',
      'communityAlertSilentZone': 'नज़दीक शांत क्षेत्र संदर्भ',
      'communityAlertSilentZoneDetail':
          'आपके आसपास {count} अस्पताल, स्कूल या कोर्ट स्थान मिले।',
      'communityAlertLightingStrong': 'नज़दीक रोशनी मजबूत लगती है',
      'communityAlertLightingStrongDetail':
          'इस क्षेत्र में सड़क/सार्वजनिक रोशनी संकेत मजबूत हैं।',
      'communityAlertLightingModerate': 'नज़दीक रोशनी मध्यम लगती है',
      'communityAlertLightingModerateDetail':
          'रोशनी मध्यम है; रात में सतर्क रहें।',
      'communityAlertLightingLimited': 'नज़दीक रोशनी सीमित हो सकती है',
      'communityAlertLightingCoverageLimited': 'रोशनी कवरेज सीमित लगता है',
      'communityAlertLightingLimitedDetail':
          'सीमित रोशनी — रात में अतिरिक्त सावधानी बरतें।',
      'communityAlertJustNow': 'अभी अभी',
      'communityAlertMinsAgo': '{minutes} मिनट पहले',
      'communityAlertHoursAgo': '{hours} घंटे पहले',
    },
    'mr': {
      'appTitle': 'सुरक्षा',
      'greetingHello': 'नमस्कार',
      'welcomeBack': 'परत स्वागत आहे',
      'signInToContinue': 'आपली सुरक्षा यात्रा सुरू ठेवण्यासाठी साइन इन करा',
      'emailOrPhone': 'ईमेल किंवा फोन नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'createAccount': 'खाते तयार करा',
      'signUpToContinue': 'आपली सुरक्षा यात्रा सुरू करण्यासाठी साइन अप करा',
      'signUpStep1of2': 'पायरी 1 / 2',
      'signUpStep2of2': 'पायरी 2 / 2',
      'signUpVerifyPhone': 'आपला ईमेल पडताळा',
      'signUpVerifyPhoneSubtitle':
          'आपले नाव, ईमेल आणि मोबाइल नंबर प्रविष्ट करा. आम्ही ईमेलवर एक वेळचा कोड पाठवू.',
      'signUpVerifyEmail': 'आपला ईमेल पडताळा',
      'signUpVerifyEmailSubtitle':
          'नाव, ईमेल आणि मोबाइल टाका. SEND OTP दाबा, नंतर ईमेलमधील 6 अंकी कोड खाली लिहा.',
      'signUpCompleteProfile': 'आपली प्रोफाइल पूर्ण करा',
      'signUpCompleteProfileSubtitle':
          'खाते तयार करण्यासाठी पासवर्ड सेट करा.',
      'continueToAccountDetails': 'पुढे जा',
      'fullName': 'पूर्ण नाव',
      'fullNameRequired': 'कृपया आपले पूर्ण नाव प्रविष्ट करा.',
      'phoneNumber': 'फोन नंबर',
      'phoneNumberInvalid': 'वैध 10 अंकी मोबाइल नंबर प्रविष्ट करा.',
      'emailOptional': 'ईमेल',
      'emailInvalid': 'वैध ईमेल पत्ता प्रविष्ट करा.',
      'confirmPassword': 'पासवर्डची पुष्टी करा',
      'signUp': 'साइन अप',
      'alreadyHaveAccount': 'आधीपासून खाते आहे? साइन इन करा',
      'dontHaveAccount': 'खाते नाही? साइन अप करा',
      'passwordsDoNotMatch': 'पासवर्ड जुळत नाहीत.',
      'forgotPassword': 'पासवर्ड विसरलात?',
      'forgotPasswordTitle': 'पासवर्ड रीसेट करा',
      'forgotPasswordSubtitle':
          'तुमचा नोंदणीकृत ईमेल टाका. आम्ही 6 अंकी OTP पाठवू.',
      'sendOtp': 'OTP पाठवा',
      'resendOtp': 'OTP पुन्हा पाठवा',
      'resendOtpIn': '{seconds}s मध्ये OTP पुन्हा पाठवा',
      'enterOtp': '6 अंकी OTP',
      'otpEnterHint':
          'ईमेलमधील 6 अंकी कोड इथे लिहा. कोड आधीच आला असेल तर इथे टाकून पुढे जा.',
      'verifyOtp': 'OTP पडताळा',
      'otpSent': 'OTP तुमच्या ईमेलवर पाठवला. खाली लिहा.',
      'otpSendFailed': 'OTP पाठवता आला नाही. तपशील तपासून पुन्हा प्रयत्न करा.',
      'otpSendCheckInbox':
          'ईमेलमध्ये कोड आला असेल तर खाली लिहा. नसेल तर थोडे थांबून Resend दाबा.',
      'otpInvalid': '6 अंकी OTP टाका.',
      'phoneVerified': 'ईमेल पडताळला.',
      'verifyPhoneFirst': 'पुढे जाण्यापूर्वी OTP ने ईमेल पडताळा.',
      'verifyEmailFirst': 'साइन अप करण्यापूर्वी OTP ने ईमेल पडताळा.',
      'newPassword': 'नवीन पासवर्ड',
      'resetPassword': 'पासवर्ड रीसेट करा',
      'passwordResetSuccess': 'पासवर्ड अपडेट झाला. तुम्ही साइन इन आहात.',
      'authSessionExpired': 'आपले सत्र संपले. कृपया पुन्हा साइन इन करा.',
      'emergencyContactsInformed': 'आपत्कालीन संपर्कांना सूचित केले',
      'liveLocationSharedWith': 'लाइव्ह स्थान शेअर केले गेले आहे:',
      'fetchingLocation': 'स्थान शोधत आहे...',
      'liveFeedActive': 'लाइव्ह फीड सक्रिय ({time})',
      'startingLiveTransmission': 'लाइव्ह ट्रान्समिशन सुरू केले जात आहे...',
      'liveTransmissionPaused': 'लाइव्ह ट्रान्समिशन थांबलं आहे',
      'emergencyModeActive': 'आपत्कालीन मोड सक्रिय',
      'helpOnTheWay': 'मदत येत आहे. तुमचं लाइव्ह स्थान शेअर केलं जात आहे.',
      'currentLocation': 'सध्याचे स्थान',
      'status': 'स्थिती',
      'iAmSafeCancelSos': 'मी सुरक्षित आहे - SOS रद्द करा',
      'myProfile': 'माझे प्रोफाइल',
      'profileSubtitle': 'तुमची सुरक्षा ओळख, भाषा आणि आपत्कालीन तयारी सांभाळा.',
      'profileOverview': 'प्रोफाइल सारांश',
      'profileStatsTitle': 'तुमचा सुरक्षा स्नॅपशॉट',
      'profileHeroCta': 'जलद मदतीसाठी प्रोफाइल वैयक्तिक बनवा.',
      'languageSelectionTitle': 'ॲपची भाषा निवडा',
      'darkMode': 'डार्क मोड',
      'darkModeSubtitleOn': 'डार्क ब्लू थीम',
      'darkModeSubtitleOff': 'हलकी शांत थीम',
      'language': 'भाषा',
      'contentLanguage': 'अॅपमधील मजकुराची भाषा',
      'english': 'इंग्रजी',
      'hindi': 'हिंदी',
      'marathi': 'मराठी',
      'editProfile': 'प्रोफाइल संपादित करा',
      'editPhoneNumber': 'फोन नंबर संपादित करा',
      'addEmergencyContactTitle': 'आपत्कालीन संपर्क जोडा',
      'editEmergencyContactTitle': 'आपत्कालीन संपर्क संपादित करा',
      'editProfileDetails': 'प्रोफाइल तपशील संपादित करा',
      'editMedicalProfile': 'मेडिकल प्रोफाइल संपादित करा',
      'email': 'ईमेल',
      'phone': 'फोन नंबर',
      'relation': 'नाते',
      'loadingNearbySafetyPoints': 'जवळचे सुरक्षा बिंदू लोड होत आहेत...',
      'unableToFetchLocation':
          'स्थान मिळवता आले नाही. खुल्या आकाशाखाली जा आणि पुन्हा प्रयत्न करा.',
      'couldNotFetchYourLocation': 'तुमचे स्थान मिळवता आले नाही.',
      'youAreHere': 'तुम्ही येथे आहात',
      'surakshaLiveLocationNotificationTitle': 'सुरक्षा लाइव्ह लोकेशन',
      'surakshaLiveLocationNotificationText':
          'सुरक्षा वैशिष्ट्यांसाठी लाइव्ह लोकेशन ट्रॅक केले जात आहे.',
      'journeyStopped': 'प्रवास थांबवला',
      'totalRoute': 'एकूण मार्ग',
      'stop': 'थांबवा',
      'start': 'सुरू करा',
      'name': 'नाव',
      'bloodGroup': 'ब्लड ग्रुप',
      'bloodGroupSelect': 'ब्लड ग्रुप निवडा',
      'allergies': 'अॅलर्जी',
      'medicalConditions': 'आरोग्यविषयक स्थिती',
      'currentMedications': 'सध्याची औषधे',
      'notProvided': 'उपलब्ध नाही',
      'emergencyContacts': 'आपत्कालीन संपर्क',
      'contactsSaved': 'संपर्क जतन केले',
      'emergencyContactList': 'आपत्कालीन संपर्क यादी',
      'activityLogsTitle': 'लॉग्स',
      'activityLogsTileValue': 'एन्क्रिप्टेड क्रियाकलाप इतिहास (७ दिवस)',
      'activityLogsSubtitle':
          'फक्त वाचण्यायोग्य, एन्क्रिप्टेड नोंदी. ७ दिवसांपेक्षा जुने नोंद काढले जातात. पासवर्ड आणि OTP कधीही साठवले जात नाहीत.',
      'activityLogsFrom': 'पासून',
      'activityLogsTo': 'पर्यंत',
      'activityLogsLast24h': 'मागील २४ तास',
      'activityLogsYesterday': 'काल',
      'activityLogsExport': '.txt निर्यात',
      'activityLogsEmpty': 'या कालावधीत कोणतेही लॉग नाहीत.',
      'activityLogsLoadFailed': 'लॉग लोड करता आले नाहीत.',
      'activityLogsUnlockReason': 'Suraksha क्रियाकलाप लॉग पाहण्यासाठी अनलॉक करा.',
      'activityLogsExportUnlock': 'क्रियाकलाप लॉग निर्यात करण्यासाठी अनलॉक करा.',
      'activityLogsUnlockCancelled': 'लॉग्स उघडण्यासाठी फोन अनलॉक करा.',
      'activityLogsUnlockAction': 'अनलॉक',
      'activityLogsLockMissing': 'लॉग्स उघडण्यासाठी फोनवर स्क्रीन लॉक सेट करा.',
      'activityLogsTampered': 'ही ओळ अखंडता तपासणीत अयशस्वी झाली.',
      'activityLogsEncryptedBadge': 'एन्क्रिप्टेड',
      'activityLogsRetentionBadge': '७-दिवस व्हॉल्ट',
      'activityLogsEventCount': '{count} घटना',
      'activityLogsUnlockTitle': 'संरक्षित क्रियाकलाप व्हॉल्ट',
      'activityLogsEmptyHint': 'कालावधी वाढवा किंवा नवीन क्रियाकलापाची वाट पहा.',
      'addEmergencyContact': 'आपत्कालीन संपर्क जोडा',
      'addNewContact': 'नवीन संपर्क जोडा',
      'logoutSession': 'लॉगआउट',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'ok': 'ठीक आहे',
      'done': 'झाले',
      'saving': 'जतन करत आहे...',
      'saved': 'जतन झाले',
      'screamDetection': 'चिघाड ओळख',
      'screamDetectionEnabled': 'चिघाड ओळख सुरू केली.',
      'screamDetectionDisabled': 'चिघाड ओळख बंद केली.',
      'screamDetectionEnableFailed': 'चिघाड ओळख सुरू करता आली नाही.',
      'distressSensitivity': 'ओळख संवेदनशीलता',
      'distressSensitivitySubtitle':
          'उच्च = हळuva चिघाड; निम्न = कमी चुकीचे अलर्ट.',
      'distressSensitivity_low': 'निम्न',
      'distressSensitivity_medium': 'मध्यम',
      'distressSensitivity_high': 'उच्च',
      'distressTestMode': 'चाचणी मोड (SOS नाही)',
      'distressTestModeSubtitle':
          'चिघाड/शब्द ओळखा पण SOS पाठवू नका. अचूकता तपासण्यासाठी.',
      'distressLastHeard': 'शेवटी ऐकले',
      'microphoneSafetyMonitorActive': 'मायक्रोफोन सुरक्षा मॉनिटर सुरू आहे.',
      'microphoneSafetyMonitorInactive': 'हे बंद असताना मायक्रोफोन बंद राहतो.',
      'impactDetection': 'आघात ओळख',
      'impactDetectionEnabled': 'आघात ओळख सुरू केली.',
      'impactDetectionDisabled': 'आघात ओळख बंद केली.',
      'impactDetectionEnableFailed': 'आघात ओळख सुरू करता आली नाही.',
      'motionSensorsActive': 'मोशन सेन्सर अचानक आघातासाठी लक्ष ठेवत आहेत.',
      'motionSensorsInactive': 'हे बंद असताना मोशन सेन्सर बंद राहतात.',
      'phoneNumberRequired': 'फोन नंबर आवश्यक आहे.',
      'nameAndPhoneRequired': 'नाव आणि फोन नंबर आवश्यक आहेत.',
      'duplicatePhoneNumberTitle': 'नंबर आधीच जतन केला आहे',
      'duplicatePhoneNumber': 'हा नंबर आधीच जतन केला आहे.',
      'savedLocallyRetryLater':
          'स्थानिकरित्या जतन केले. सर्व्हर सिंक नंतर पुन्हा प्रयत्न करेल.',
      'photoSavedLocally': 'फोटो स्थानिकरित्या जतन केला.',
      'profilePhotoUnlockReason':
          'प्रोफाइल फोटो बदलण्यासाठी तुमचा फोन अनलॉक करा.',
      'profilePhotoUnlockCancelled':
          'गॅलरी उघडण्यापूर्वी PIN, पासवर्ड, फिंगरप्रिंट किंवा फेस लॉकने फोन अनलॉक करा.',
      'profilePhotoDeviceLockMissing':
          'आधी तुमच्या फोनवर स्क्रीन लॉक (PIN, पासवर्ड, फिंगरप्रिंट किंवा फेस) सेट करा. Suraksha यासाठी वेगळा PIN तयार करत नाही.',
      'profilePhotoCropTitle': 'फोटो क्रॉप करा',
      'profilePhotoCropHint':
          'झूम करण्यासाठी पिंच करा आणि प्रोफाइल फोटोचा भाग निवडण्यासाठी ड्रॅग करा.',
      'profilePhotoCropFailed':
          'हा फोटो क्रॉप करता आला नाही. दुसरी प्रतिमा वापरून पहा.',
      'serverSyncWillRetryLater': 'सर्व्हर सिंक नंतर पुन्हा प्रयत्न करेल.',
      'profileSavedTitle': 'प्रोफाइल जतन झाले',
      'profileSavedMessage': 'तुमची माहिती सुरक्षितपणे जतन झाली आहे.',
      'medicalSavedTitle': 'मेडिकल प्रोफाइल जतन झाले',
      'medicalSavedMessage': 'तुमची मेडिकल माहिती यशस्वीरित्या अपडेट झाली आहे.',
      'contactSavedTitle': 'संपर्क जतन झाला',
      'contactSavedMessage':
          'आपत्कालीन संपर्क तपशील यशस्वीरित्या अपडेट झाले आहेत.',
      'draftSavedTitle': 'ड्राफ्ट जतन झाला',
      'draftSavedMessage': 'तुमचा ड्राफ्ट या डिव्हाइसवर सुरक्षित झाला आहे.',
      'emergencyServices': 'आपत्कालीन सेवा',
      'communityAlerts': 'समुदाय सूचना',
      'safetyRegionLabel': 'प्रदेश',
      'safetyDataDisclaimerTitle': 'डेटा स्रोत',
      'safetyConfidenceSuffix': 'विश्वास',
      'safetySourceOpenStreetMap': 'OpenStreetMap',
      'safetySourceSunset': 'सूर्यास्त API',
      'safetySourceCrowd': 'अनाम गर्दी',
      'safetySourceSurakshaReports': 'Suraksha अहवाल',
      'safetySourceSurakshaEngine': 'Suraksha इंजिन',
      'safetySourceSurakshaCommunity': 'समुदाय प्रमाणित',
      'safetySourceRegionalGuidance': 'प्रादेशिक मार्गदर्शन',
      'safetyDimCrime': 'गुन्हे',
      'safetyDimInfrastructure': 'प्रकाश',
      'safetyDimSupport': 'मदत',
      'safetyDimVisibility': 'दृश्यमानता',
      'safetyDimTemporal': 'वेळ',
      'safetySourceGridModel': 'ग्रिड मॉडेल',
      'safetySourceOpenDataDistrict': 'जिल्हा ओपन डेटा',
      'safetyUpdatedAgo': 'अपडेट',
      'aiSummaryFromGemini': 'AI सारांश (Gemini)',
      'aiSummaryFromTemplate': 'AI सारांश (ऑफलाइन)',
      'journeySafetyAlerts': 'प्रवास सुरक्षा सूचना',
      'journeySafetyAlertsSubtitle':
          'नेव्हिगेशन दरम्यान उच्च जोखीम क्षेत्रात प्रवेश केल्यावर पुश आणि इन-अॅप सूचना.',
      'notifPrefSos': 'SOS सूचना',
      'notifPrefSosSubtitle': 'गंभीर SOS आणि धोक्यासंबंधी सूचना.',
      'notifPrefRoute': 'मार्ग इशाऱ्या',
      'notifPrefRouteSubtitle': 'दैनिक मार्ग रक्षक विचलन सूचना.',
      'notifPrefCommunity': 'समुदाय सूचना',
      'notifPrefCommunitySubtitle': 'जवळपासच्या समुदाय सुरक्षा सूचना.',
      'notifPrefReminders': 'सुरक्षा स्मरणपत्रे',
      'notifPrefRemindersSubtitle': 'पर्यायी चेक-इन आणि तयारी स्मरणपत्रे.',
      'notifOnboardingTitle': 'आपत्कालीन वेळी संपर्क ठेवा',
      'notifOnboardingBody':
          'Suraksha वेळ-संवेदनशील सुरक्षा सूचनांसाठी नोटिफिकेशन वापरते. श्रेण्या प्रोफाइलमध्ये बदलता येतात.',
      'notifOnboardingBulletSos': 'SOS आणि गंभीर धोका सूचना',
      'notifOnboardingBulletRoute': 'मार्ग विचलन इशाऱ्या',
      'notifOnboardingBulletCommunity': 'जवळपास समुदाय सुरक्षा सूचना',
      'notifOnboardingBulletReminders': 'पर्यायी सुरक्षा स्मरणपत्रे',
      'notifEnableNotifications': 'सूचना सक्षम करा',
      'notifOpenSettings': 'सिस्टम सेटिंग्ज उघडा',
      'notifSkipForNow': 'आत्ता वगळा',
      'notifPermissionDeniedHint':
          'परवानगी बंद आहे. सूचना परवानगी देण्यासाठी सिस्टम सेटिंग्ज उघडा.',
      'pleaseWait': 'कृपया थांबा…',
      'notifDeliveryStatusLabel': 'डिलिव्हरी: {status}',
      'notifExpiredHandled': 'ही सूचना कालबाह्य झाली आहे आणि काढली गेली.',
      'notifInboxTitle': 'सुरक्षा सूचना इनबॉक्स',
      'notifInboxEmpty': 'सध्या कोणतीही सक्रिय सुरक्षा सूचना नाही.',
      'notifInboxOpenSubtitle': 'गंभीर आणि अलीकडील सूचनांची डिलिव्हरी स्थिती पहा.',
      'journeyRerouteHint': 'अधिक सुरक्षित मार्ग उपलब्ध',
      'tapForAlerts': 'अलर्ट पाहण्यासाठी टॅप करा',
      'tapRefreshTryAgain': 'पुन्हा प्रयत्न करण्यासाठी रिफ्रेश टॅप करा',
      'loadingLiveAreaAlerts': 'लाईव्ह परिसर अलर्ट लोड होत आहेत...',
      'checkingTrafficTransportNearbyActivity':
          'वाहतूक, परिवहन आणि जवळची हालचाल तपासत आहोत',
      'liveAlertsWillAppearHere': 'लाईव्ह अलर्ट इथे दिसतील',
      'keepGpsOnForRealtimeCommunityUpdates':
          'रीअलटाइम community updates साठी GPS चालू ठेवा',
      'locationRequiredTitle': 'स्थान आवश्यक आहे',
      'locationRequiredMessage':
          'Suraksha वापरण्यासाठी GPS आणि स्थान परवानगी आवश्यक आहे. सुरू ठेवण्यासाठी त्यांना सक्षम करा.',
      'locationAutoRefreshMessage':
          'स्थान सक्षम केल्यावर सेवा स्वयंचलितपणे रीफ्रेश होतील.',
      'retryLocation': 'स्थान सेटअप पुन्हा प्रयत्न करा',
      'womenHelpline': 'महिला हेल्पलाइन',
      'nearbyServices': 'जवळच्या सेवा',
      'nearbyHospitals': 'जवळची रुग्णालये',
      'policeStations': 'पोलीस ठाणे',
      'nearbyWashrooms': 'जवळचे वॉशरूम',
      'nearbyBloodBanks': 'जवळच्या रक्तपेढ्या',
      'nearbyPharmacies': 'जवळच्या फार्मसी',
      'nearbyPetrolPumps': 'जवळचे पेट्रोल पंप',
      'tapToLoadNearby': 'जवळच्या सेवा लोड करण्यासाठी बटण दाबा.',
      'noNearbyPlaces': '5 किमी परिसरात कोणतीही जागा सापडली नाही.',
      'safeZoneActive': 'सुरक्षा प्राधान्य',
      'helloKaveri': 'नमस्कार, कावेरी',
      'openSafetyMap': 'सुरक्षा नकाशा उघडा',
      'openSafetyMapConfirm': 'हे ठिकाण नकाशावर पाहायचे आहे का?',
      'mapOpenChoiceTitle': 'ठिकाण उघडा',
      'mapOpenChoiceMessage': 'हे ठिकाण कसे उघडायचे ते निवडा.',
      'mapOpenChoiceSuraksha': 'सुरक्षा नकाशा',
      'mapOpenChoiceGoogle': 'गुगल मॅप्स',
      'yes': 'हो',
      'no': 'नाही',
      'couldNotOpenDialer': 'डायलर उघडता आला नाही',
      'policeEmergency': 'पोलीस अपातकालीन',
      'scanningNearbyPlaces': 'जवळच्या ठिकाणांची स्कॅनिंग केली जात आहे...',
      'nearbyResultsCount': '{count} जवळचे परिणाम',
      'toiletsNoToiletsInArea': 'या परिसरात कोणतेही शौचालय सापडले नाही.',
      'toiletsNoToiletsInAreaHint':
          'या परिसरात कोणतेही शौचालय सापडले नाही. शोध त्रिज्या वाढवा किंवा फिल्टर सैल करा.',
      'toiletsSanitationRegistryEmpty':
          'सॅनिटेशन नोंदवहीने या ठिकाणी कोणतेही प्रकाशित शौचालय दिले नाही.',
      'toiletsSanitationRegistryEmptyHint':
          'टॉयलेट सेवा जोडलेली आहे, पण या स्थानासाठी सार्वजनिक API मध्ये सॅनिटेशन शौचालये प्रकाशित नाहीत. सॅनिटेशन अॅडमिनकडून GPS सह नोंदी प्रकाशित करण्यास सांगा.',
      'toiletsSanitationMissingCoordinates':
          'सॅनिटेशन शौचालये आहेत, पण नकाशा निर्देशांक गहाळ आहेत.',
      'toiletsSanitationMissingCoordinatesHint':
          'सॅनिटेशन प्लॅटफॉर्मने वैध अक्षांश/रेखांशशिवाय शौचालये परत केली, म्हणून ती नकाशावर दिसू शकत नाहीत. अॅडमिन पॅनेलमध्ये GPS अपडेट करा.',
      'toiletsSanitationClosedPermissionHint':
          'लक्ष द्या: हे एकीकरण फक्त उघडी शौचालये दाखवू शकते. बंद शौचालयांसाठी सॅनिटेशनमध्ये Open स्थिती किंवा बंद शौचालये वाचण्याची परवानगी असलेली API की हवी.',
      'toiletsLocationUnavailable':
          'स्थान उपलब्ध नाही. GPS चालू करा आणि स्थान परवानगी द्या.',
      'toiletsConnectionError':
          'शौचालय सेवेशी संपर्क होऊ शकला नाही. कृपया पुन्हा प्रयत्न करा.',
      'toiletsRefreshing': 'स्वच्छ आणि वापरण्यायोग्य सार्वजनिक शौचालये रीफ्रेश केली जात आहेत...',
      'toiletsFoundCount': 'सध्याच्या फिल्टरसह {count} शौचालये सापडली',
      'toiletsOnMapCount': 'नकाशावर {count} शौचालये',
      'toiletsLoadingNearby': 'जवळची शौचालये लोड होत आहेत...',
      'chooseServiceToScanYourArea':
          'तुमचा सध्याचा परिसर स्कॅन करण्यासाठी खाली एक सेवा निवडा.',
      'cyberCrimeProtection': 'सायबर क्राइम संरक्षण',
      'aiAssist': 'एआय सहाय्य',
      'report': 'रिपोर्ट',
      'vault': 'वॉल्ट',
      'learn': 'शिका',
      'deepfake': 'डीपफेक',
      'aiScamFraudAssistantTitle': 'एआय घोटाळा व फसवणूक ओळख सहाय्यक',
      'pasteEvidenceContext':
          'संदिग्ध संदेश, दुवे, चाट किंवा प्रश्न पेस्ट करा. प्रमाणासाठी स्क्रीनशॉट जोडाः',
      'suspiciousMessageLabel': 'संदिग्ध संदेश, ईमेल किंवा चाट',
      'pasteFullMessageHereHint': 'पूर्ण संदेश इथे पेस्ट करा...',
      'suspiciousLinksLabel': 'संदिग्ध दुवे',
      'urlHint': 'https://example.com, bit.ly/...',
      'askQuestionLabel': 'एक प्रश्न विचारावा',
      'scamQuestionHint': 'हे स्वरूप फसवणूक आहे का? ही प्रोफाइल खोटी आहे का?',
      'attachScreenshot': 'स्क्रीनशॉट जोडा',
      'analyze': 'विश्लेषण करा',
      'selectIncidentType': 'घटनेचा प्रकार निवडा',
      'attachScreenshotsOrProof': 'स्क्रीनशॉट किंवा व्यवहार पुरावा जोडा',
      'incidentDescription': 'घटनेचे वर्णन',
      'incidentDetailsHint':
          'काय घडले ते, वापरकर्तानावे, रक्कम, धमक्या आणि प्लॅटफॉर्म वर्णन करा.',
      'suspectContactLabel': 'फोन/ईमेल/प्रोफाइल दुवा',
      'suspectContactHint': 'शंकित संपर्क किंवा प्रोफाइल URL',
      'transactionIdLabel': 'व्यवहार आयडी',
      'transactionIdHint': 'आर्थिक फसवणुकीसाठी UPI/ref क्र. असल्यास',
      'incidentTime': 'घटनेचा वेळ: {time}',
      'pdfReady': 'PDF तयार',
      'newReport': 'नवी रिपोर्ट',
      'saveDraft': 'ड्राफ्ट जतन करा',
      'reportGenerated': 'रिपोर्ट तयार झाली.',
      'draftSavedOnline': 'ड्राफ्ट ऑनलाइन साठवला.',
      'couldNotSubmitOnline': 'ऑनलाइन सबमिट करू शकले नाही. पुन्हा प्रयत्न करा.',
      'secureEvidenceVault': 'सुरक्षित साक्ष्य वॉल्ट',
      'uploadTagSearchPackageEvidence':
          'साइबर साक्ष्य अपलोड करा, टॅग करा, शोधा आणि पॅकेज करा. बॅकएंड फाइल AES एन्क्रिप्टेड आहेत.',
      'takeQuiz': 'क्विझ घ्या',
      'progressBadge': '{percent}% पूर्ण | बॅज: {badge}',
      'cyberDefender': 'सायबर डिफेंडर',
      'cyberLearner': 'सायबर लर्नर',
      'deepfakeSubtitle':
          'जागरूकता, आपत्कालीन प्रतिक्रिया, कायदेशीर मार्गदर्शन आणि हेल्पलाइन प्रवेश.',
      'deepfakeWarning':
          'कोणीतरी मॉर्फ/खाजगी मीडिया लीक करण्याची धमकी देत असल्यास, पैसे देऊ नका किंवा वाटाघाटी करू नका. पुरावे जतन करा आणि लवकर रिपोर्ट करा.',
      'emergencyActions': 'आपत्कालीन क्रिया',
      'call1930': '1930 कॉल करा',
      'police100': 'पोलीस 100',
      'cyberPortal': 'सायबर पोर्टल',
      'reportStatusDraft': 'मसुदा',
      'reportStatusReported': 'नोंदवले',
      'reportStatusUnderInvestigation': 'तपास सुरू',
      'reportStatusResolved': 'निराकरण झाले',
      'reportStatusLabel': 'स्थिती',
      'cyberPortalGuideTitle': 'cybercrime.gov.in वर नोंदवा',
      'cyberPortalGuideSubtitle':
          'तुमची Suraksha तक्रार तयार आहे. राष्ट्रीय पोर्टलवर नोंदणी करण्यासाठी आणि पावती क्रमांक येथे जतन करण्यासाठी हे चरण अनुसरा.',
      'cyberPortalGuideStep1':
          'खालील बटणाने Suraksha तक्रार PDF जतन करा किंवा शेअर करा.',
      'cyberPortalGuideStep2':
          'cybercrime.gov.in उघडा आणि नागरिक म्हणून साइन इन करा.',
      'cyberPortalGuideStep3':
          'त्याच घटनेचे तपशील आणि पुरावे संलग्न करून नवीन सायबर गुन्हा तक्रार नोंदवा.',
      'cyberPortalGuideStep4':
          'सरकारी पावती क्रमांक कॉपी करा आणि पुढील तपासणीसाठी खाली जतन करा.',
      'cyberPortalCopyComplaint': 'तक्रार मजकूर कॉपी करा',
      'cyberPortalComplaintCopied': 'तक्रार मजकूर क्लिपबोर्डवर कॉपी झाला.',
      'cyberPortalAckLabel': 'सरकारी पावती क्रमांक',
      'cyberPortalAckHint': 'cybercrime.gov.in वरून क्रमांक प्रविष्ट करा',
      'cyberPortalAckTooShort': 'वैध पावती क्रमांक प्रविष्ट करा.',
      'cyberPortalSaveAck': 'पावती जतन करा',
      'cyberPortalAckSaved': 'पावती क्रमांक जतन झाला.',
      'cyberPortalAckSavedOn': '{number} हा {date} रोजी जतन केला.',
      'cyberPortalFiledBadge': 'पोर्टलवर नोंदवले',
      'uploadEncryptedEvidence': 'एन्क्रिप्टेड पुरावा अपलोड करा',
      'noFilesSelectedYet': 'अद्याप कोणत्याही फाईल्स निवडल्या नाहीत.',
      'generate': 'निर्माण करा',
      'generatedComplaint': 'निर्मित तक्रार',
      'reportSummaryUnavailable': 'रिपोर्ट सारांश उपलब्ध नाही.',
      'pdfPayloadGenerated':
          'PDF पेलोड तयार. निर्यात एकीकरण बॅकएंड प्रतिसादापासून साठवू/शेअर करू शकते.',
      'evidenceTitleLabel': 'साक्ष्य शीर्षक',
      'evidenceTitleHint': 'धमकी स्क्रीनशॉट, UPI पुरावा...',
      'category': 'श्रेणी',
      'private': 'खाजगी',
      'tags': 'टॅग',
      'tagsHint': 'ब्लॅकमेल, इंस्टाग्राम, पेमेंट',
      'finish': 'पूर्ण',
      'searchVault': 'वॉल्ट शोधा',
      'searchByTitle': 'शीर्षकानुसार शोधा',
      'noEvidenceFound':
          'कोणतेही साक्ष्य सापडले नाही. आपले सुरक्षित वॉल्ट सुरू करण्यासाठी साक्ष्य अपलोड करा.',
      'sessionExpiredSignIn': 'सत्र संपले. कृपया पुन्हा साइन इन करा.',
      'loginRequiredCyber': 'सुरक्षित सायबर वैशिष्ट्यांसाठी पुन्हा लॉगिन करा.',
      'fileTooLarge10Mb': 'फाइल खूप मोठी आहे. कमाल 10 MB.',
      'networkServerIssue': 'नेटवर्क किंवा सर्व्हर समस्या. पुन्हा प्रयत्न करा.',
      'cyberEvidenceDecryptFailed':
          'ही एन्क्रिप्टेड फाइल उघडता आली नाही. पुन्हा अपलोड करा.',
      'cyberEvidenceServerMissing':
          'सर्व्हरवर पुरावा फाइल सापडली नाही. कृपया पुन्हा अपलोड करा.',
      'couldNotSharePdf': 'PDF शेअर होऊ शकले नाही.',
      'couldNotExportEvidence': 'साक्ष्य पॅकेज निर्यात होऊ शकले नाही.',
      'riskLevel': 'धोका पातळी',
      'recommendedActions': 'शिफारस केलेली कृती',
      'safetyTips': 'सुरक्षा टिपा',
      'encrypted': 'एन्क्रिप्टेड',
      'notEncrypted': 'एन्क्रिप्टेड नाही',
      'linkedToReport': 'अहवालाशी जोडले',
      'preview': 'पूर्वावलोकन',
      'download': 'डाउनलोड',
      'delete': 'हटवा',
      'edit': 'संपादित करा',
      'noUnlinkedEvidence': 'वॉल्टमध्ये अनलिंक्ड साक्ष्य नाही.',
      'minDescriptionChars': 'किमान 10 अक्षरे वर्णन जोडा.',
      'draftPendingDetails': 'ड्राफ्ट अहवालाचे तपशील प्रलंबित.',
      'evidenceFilesSecured': '{count} साक्ष्य फाइल(स) वॉल्टमध्ये सुरक्षित.',
      'vaultEvidenceLinked': '{count} वॉल्ट आयटम अहवालाशी जोडले.',
      'summaryStep': 'सारांश',
      'myReports': 'माझे अहवाल',
      'noSubmittedReportsYet': 'अद्याप कोणतेही अहवाल नाहीत.',
      'draft': 'ड्राफ्ट',
      'pickFromGallery': 'गॅलरी',
      'pickFile': 'फाइल निवडा',
      'attachFromVault': 'वॉल्टमधून',
      'vaultItemsSelected': '{count} वॉल्ट आयटम निवडले',
      'uploadingEvidence': 'साक्ष्य अपलोड होत आहे {current}/{total}…',
      'selectVaultEvidence': 'वॉल्ट साक्ष्य निवडा',
      'analyzeInputRequired': 'संदेश, लिंक, प्रश्न पेस्ट करा किंवा स्क्रीनशॉट जोडा.',
      'clearScreenshot': 'स्क्रीनशॉट काढा',
      'screenshotTextExtracted': 'स्क्रीनशॉटमधून मजकूर काढला',
      'evidenceEncryptedSaved': 'साक्ष्य एन्क्रिप्ट करून जतन केले.',
      'uploadFailed': 'अपलोड अयशस्वी.',
      'previewFailed': 'पूर्वावलोकन अयशस्वी.',
      'downloadFailed': 'डाउनलोड अयशस्वी.',
      'deleteEvidenceTitle': 'साक्ष्य हटवायचे?',
      'deleteEvidenceConfirm': '"{title}" वॉल्टमधून काढायचे?',
      'evidenceDeleted': 'साक्ष्य हटवले.',
      'deleteFailed': 'हटवणे अयशस्वी.',
      'exportFailed': 'निर्यात अयशस्वी.',
      'exportEvidencePackage': 'साक्ष्य पॅकेज निर्यात',
      'cyberAiResultDisclaimer':
          'हे केवळ संभाव्य जोखीम मूल्यांकन आहे — कायदेशीर पुरावा, पोलिस सल्ला किंवा अंतिम निर्णय नाही. नेहमी अधिकृत स्रोतांकडून पडताळा.',
      'cyberEvidencePrivacyNotice':
          'तुम्ही अपलोड केलेल्या फाइल्स Suraksha च्या सुरक्षित सर्व्हर वॉल्टमध्ये साठवल्या जातात (तुमच्या खात्याखाली डिस्कवर AES-एन्क्रिप्टेड). मेटाडेटा (शीर्षक, श्रेणी, टॅग) तुमच्या खात्यासोबत जतन होतो. जोपर्यंत तुम्ही अधिकृत सायबर गुन्हा पोर्टलवर स्वतः तक्रार दाखल करत नाही तोपर्यंत साक्ष्य तिथे पाठवले जात नाही.',
      'cyberEvidenceConfirmTitle': 'साक्ष्य अपलोडची पुष्टी करा',
      'cyberEvidenceConfirmMessage':
          'फाइल: {name}\nआकार: {size}\nश्रेणी: {category}\nखाजगी: {private}\n\nही फाइल Suraksha वॉल्टमध्ये अपलोड करायची?',
      'cyberEvidenceInvalidType':
          'असमर्थित फाइल प्रकार. JPG, PNG, WEBP, PDF, MP3, WAV किंवा M4A वापरा.',
      'cyberEvidenceFileMissing': 'निवडलेली फाइल वाचता आली नाही.',
      'cyberEvidenceUploadCancel': 'अपलोड रद्द करा',
      'cyberUploadCancelled': 'अपलोड रद्द केले.',
      'cyberVaultLockTitle': 'वॉल्ट पाहण्याचे लॉक',
      'cyberVaultLockSubtitle':
          'साक्ष्य पाहण्यापूर्वी किंवा डाउनलोड करण्यापूर्वी ऐच्छिक PIN किंवा बायोमेट्रिक.',
      'cyberVaultEnableLock': 'व्यूइंग लॉक सक्षम करा',
      'cyberVaultDisableLock': 'व्यूइंग लॉक अक्षम करा',
      'cyberVaultUnlockTitle': 'साक्ष्य वॉल्ट अनलॉक करा',
      'cyberVaultUnlockAction': 'अनलॉक',
      'cyberVaultBiometricReason': 'Suraksha साक्ष्य वॉल्ट अनलॉक करा',
      'cyberVaultPinIncorrect': 'चुकीचा PIN.',
      'cyberVaultLockEnabled': 'साक्ष्य व्यूइंग लॉक सक्षम.',
      'cyberVaultLockDisabled': 'साक्ष्य व्यूइंग लॉक अक्षम.',
      'cyberVaultSetPinTitle': 'वॉल्ट PIN सेट करा',
      'cyberVaultConfirmPinLabel': 'PINची पुष्टी करा',
      'cyberVaultPinMismatch': 'PIN जुळत नाहीत.',
      'cyberAcknowledgementHistory': 'पावती इतिहास',
      'cyberAcknowledgementHistoryEmpty': 'अद्याप कोणताही पोर्टल पावती क्रमांक जतन नाही.',
      'cyberAckSavedAt': 'जतन केले {when}',
      'filterAll': 'सर्व',
      'filterLinked': 'जोडलेले',
      'filterUnlinked': 'अनलिंक्ड',
      'reportDetails': 'अहवाल तपशील',
      'linkedEvidence': 'जोडलेले साक्ष्य',
      'noLinkedEvidence': 'या अहवालाशी साक्ष्य जोडलेले नाही.',
      'digitalSafetyLearningHub': 'डिजिटल सुरक्षा शिक्षण केंद्र',
      'learningHubSubtitle': 'फिशिंग, UPI, गोपनीयता आणि डीपफेक कौशल्ये विकसित करा.',
      'cyberSafetyScore': 'सायबर सुरक्षा स्कोअर',
      'cyberSafetyScoreUpdated': 'सायबर सुरक्षा स्कोअर: {score}',
      'catFinancialFraud': 'आर्थिक फसवणूक',
      'catCyberStalking': 'सायबर स्टॉकिंग',
      'catOnlineBullying': 'ऑनलाइन बुलिंग',
      'catIdentityTheft': 'ओळख चोरी',
      'catSocialMediaHarassment': 'सोशल मीडिया छळ',
      'catHarassment': 'छळ',
      'catBlackmail': 'ब्लॅकमेल',
      'catFakeProfile': 'बनावट प्रोफाइल',
      'catDeepfakeThreat': 'डीपफेक धमकी',
      'catDeepfakeScam': 'डीपफेक फसवणूक',
      'catFakeJobScam': 'बनावट नोकरी फसवणूक',
      'catUpiFraud': 'UPI फसवणूक',
      'catOther': 'इतर',
      'evidenceCatAll': 'सर्व',
      'evidenceCatScreenshot': 'स्क्रीनशॉट',
      'evidenceCatAudio': 'ऑडिओ',
      'evidenceCatThreatMessage': 'धमकी संदेश',
      'evidenceCatImage': 'प्रतिमा',
      'evidenceCatTransactionProof': 'व्यवहार पुरावा',
      'evidenceCatDocument': 'दस्तऐवज',
      'evidenceCatOther': 'इतर',
      'multiSelectNone': 'काहीही निवडले नाही',
      'multiSelectCount': '{count} निवडले',
      'filterCategories': 'श्रेणी फिल्टर',
      'filterLinkStatus': 'लिंक स्थिती',
      'additionalCategoriesNote': 'अतिरिक्त घटना प्रकार',
      'configureServer': 'सर्व्हर कॉन्फिगर करा',
      'configureServerHint':
          'PC IP प्रविष्ट करा जिथे backend चालत आहे. उदा: http://192.168.1.5:5000/api',
      'serverUrlHint': 'http://192.168.1.5:5000/api',
      'serverUrlSaved': 'सर्व्हर URL जतन केला. कनेक्शन पुन्हा प्रयत्न...',
      'cannotReachServer':
          'सर्व्हरशी कनेक्ट होता आले नाही. कृपया इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.',
      'fixConnection': 'पुन्हा प्रयत्न करा',
      'deepfakeEmergencySupportTitle': 'डीपफेक व मोर्फ्ड इमेज तातडीची मदत',
      'medicalHealthVault': 'मेडिकल हेल्थ वॉल्ट',
      'surakshaAi': 'सुरक्षा AI',
      'surakshaAiSubtitle': 'तुमचा वैयक्तिक सुरक्षा सहाय्यक',
      'surakshaAiWelcome':
          'नमस्कार, मी सुरक्षा AI आहे. SOS, मार्ग सुरक्षा, सायबर फसवणूक, POSH किंवा वैद्यकीय आपत्कालीन तयारीबद्दल विचारा. तात्काळ धोक्यात 112 वर कॉल करा.',
      'surakshaAiPlaceholder': 'सुरक्षा, मार्ग, SOS विषयी विचारा...',
      'surakshaAiThinking': 'विचार करत आहे...',
      'surakshaAiQuickPrompt1': 'SOS कसा वापरायचा?',
      'surakshaAiQuickPrompt2': 'प्रवासात असुरक्षित वाटत आहे',
      'surakshaAiQuickPrompt3': 'कोणीतरी ऑनलाइन छळ करत आहे',
      'surakshaAiLimitedOfflineGuidance': 'मर्यादित ऑफलाइन मार्गदर्शन',
      'surakshaAiPrivacyWarning':
          'गोपनीयता सूचना: या चॅटमध्ये पासवर्ड, OTP, बँकिंग तपशील, आधार/पॅन किंवा अनावश्यक ओळख माहिती शेअर करू नका.',
      'surakshaAiNewConversation': 'नवीन संभाषण',
      'surakshaAiClearChat': 'चॅट साफ करा',
      'surakshaAiClearChatConfirm':
          'ही चॅट साफ करून नव्याने सुरू करायची? Suraksha AI चा सर्व्हर इतिहासही रीसेट होईल.',
      'surakshaAiConversationCleared': 'संभाषण साफ केले.',
      'surakshaAiFeedbackHelpful': 'उपयुक्त',
      'surakshaAiFeedbackIrrelevant': 'असंबंधित',
      'surakshaAiFeedbackUnsafe': 'असुरक्षित',
      'surakshaAiFeedbackThanks': 'फीडबॅकसाठी धन्यवाद.',
      'surakshaAiFeedbackFailed': 'फीडबॅक आत्ता जतन होऊ शकले नाही.',
      'surakshaAiActionCall112': '112 कॉल करा',
      'surakshaAiActionSos': 'SOS पाठवा',
      'surakshaAiActionSafetyMap': 'सेफ्टी मॅप',
      'surakshaAiActionCyber': 'सायबर संरक्षण',
      'surakshaAiActionPosh': 'POSH',
      'surakshaAiSosTriggered': 'Suraksha AI मधून SOS सक्रिय केला.',
      'surakshaAiIntentDanger': 'ओळखलेला हेतू: तातडीचा धोका',
      'surakshaAiIntentCyber': 'ओळखलेला हेतू: सायबर / ब्लॅकमेल',
      'surakshaAiIntentPosh': 'ओळखलेला हेतू: कार्यस्थळ छळ',
      'surakshaAiIntentMedical': 'ओळखलेला हेतू: वैद्यकीय आपत्काल',
      'surakshaAiIntentGreeting': 'ओळखलेला हेतू: अभिवादन',
      'surakshaAiIntentGeneral': 'ओळखलेला हेतू: सामान्य प्रश्न',
      'keepEmergencyMedicalInformationOrganized':
          'आपातकालीन वैद्यकीय माहिती जलद वापरासाठी व्यवस्थित ठेवा.',
      'emergencyMedicalId': 'आपत्कालीन वैद्यकीय आयडी',
      'scanInCaseOfMedicalEmergency': 'वैद्यकीय आपातकाळाच्या बाबतीत स्कॅन करा',
      'medicalProfileSaved': 'वैद्यकीय प्रोफाइल जतन केली गेली',
      'medicalDetailsReady':
          'आपली वैद्यकीय माहिती आपत्कालीन वापरासाठी तयार आहे.',
      'savedLocallyOnThisDevice': 'हे डिव्हाइसवर स्थानिकपणे जतन केले.',
      'medicalProfileSavedLocallySyncRetryLater':
          'वैद्यकीय प्रोफाइल स्थानिकपणे जतन केली गेली. सिंक नंतर पुन्हा प्रयत्न करेल.',
      'certificateDetails': 'प्रमाणपत्र तपशील',
      'issuedOn': '{date} ला जारी करण्यात आले',
      'poshCertifiedMessage':
          'आपण सर्व तीन क्विझ पातळ्या पूर्ण केल्या आहेत आणि मजबूत POSH कायदा ज्ञान दर्शविले आहे.',
      'validForPoshCertificate':
          'वैध: POSH कायदा जागरूकता आणि कार्यस्थळ सुरक्षितता प्रशिक्षणासाठी',
      'safeZoneUpdatedNearby': 'जवळ सुरक्षित क्षेत्र अपडेट झाले',
      'crowdedAreaWarning': 'गर्दीच्या भागाची चेतावणी',
      'minsAgo2': '2 मिनिटांपूर्वी',
      'minsAgo15': '15 मिनिटांपूर्वी',
      'map': 'नकाशा',
      'medical': 'मेडिकल',
      'cyber': 'सायबर',
      'poshPortal': 'POSH पोर्टल',
      'liveSafetyMapTitle': 'लाइव्ह सुरक्षा नकाशा',
      'locating': 'स्थान शोधत आहे...',
      'myLocation': 'माझे स्थान',
      'refreshNearby': 'जवळपास रिफ्रेश करा',
      'retryLiveLocation': 'लाइव्ह लोकेशन पुन्हा प्रयत्न',
      'safetyIntelligenceMap': 'सुरक्षा इंटेलिजन्स नकाशा',
      'couldNotFindThatLocation': 'ते स्थान सापडले नाही.',
      'couldNotOpenThisPlace': 'हे स्थान उघडता आले नाही.',
      'tryAgain': 'पुन्हा प्रयत्न करा',
      'longPressDropPinPreviewRoute':
          'पिन टाकण्यासाठी लांब दाबा. मार्ग पाहण्यासाठी मार्कर टॅप करा.',
      'fetchingYourLocation': 'तुमचे सध्याचे स्थान मिळवत आहे...',
      'mapWillOpenAroundYou':
          'GPS तयार झाल्यावर नकाशा थेट तुमच्या सभोवताल उघडेल.',
      'searchLocation': 'स्थान शोधा...',
      'liveTrackingActive': 'लाइव्ह ट्रॅकिंग सक्रिय',
      'journeyTrackingActive': 'प्रवास ट्रॅकिंग सक्रिय',
      'destinationReached': 'गंतव्य गाठले',
      'selectedDestination': 'निवडलेले गंतव्य',
      'calculatingRoute': 'मार्ग मोजत आहे',
      'remaining': 'शिल्लक',
      'routePreview': 'मार्ग पूर्वावलोकन',
      'liveNavigation': 'लाइव्ह नेव्हिगेशन',
      'followingYourRoute': 'लाइव्ह प्रगतीसह तुमच्या मार्गाचे अनुसरण',
      'readyWithDistanceAndEstimatedTravelTime':
          'अंतर आणि अंदाजित वेळेसह तयार',
      'calculatingRouteDistance': 'मार्ग अंतर मोजत आहे',
      'covered': 'कव्हर केले',
      'eta': 'अंदाजित वेळ',
      'selectedLocation': 'निवडलेले स्थान',
      'customPin': 'सानुकूल पिन',
      'study': 'अभ्यास',
      'quizzes': 'क्विझ',
      'complaint': 'तक्रार',
      'poshActLearningHub': 'POSH कायदा अभ्यास केंद्र',
      'poshStudy1Title': 'POSH कायदा काय कव्हर करतो',
      'poshStudy1Bullet1':
          'POSH कायदा कार्यस्थळी महिला विरोधी लैंगिक छळ (2013) यांचा अंतर्भाव करतो.',
      'poshStudy1Bullet2':
          'हा सन्मान, समानता आणि सुरक्षित कामाच्या अटींचे रक्षण करतो.',
      'poshStudy1Bullet3':
          'हा सार्वजनिक व खासगी कार्यस्थळे, कार्यालये, दुकाने, रुग्णालये, शाळा, NGO आणि नियोक्ता प्रदान केलेले प्रवास यावर लागू होतो.',
      'poshStudy1Bullet4':
          'कायदा कर्मचारी, प्रशिक्षार्थी, इंटर्न, करार कर्मचारी, स्वयंसेवक आणि कार्यस्थलावर येणाऱ्या अभ्यागतांना कव्हर करतो.',
      'poshStudy1Bullet5':
          'लैंगिक स्वरूपाचा अनिच्छित वागणूक मौखिक, लिखित, डिजिटल किंवा शारीरिक असू शकतो.',
      'poshStudy1Bullet6':
          'उदाहरण: अनिच्छित स्पर्श, लैंगिक टिप्पणी, संदेश, सतत छळ किंवा अश्लील सामग्री दाखवणे.',
      'poshStudy2Title': 'तक्रार प्रक्रिया आणि आंतरिक समिती (IC)',
      'poshStudy2Bullet1':
          'तक्रार सामान्यतः घटना घडल्यापासून 3 महिन्यांमध्ये लेखी स्वरूपात नोंदवावी.',
      'poshStudy2Bullet2':
          '10 किंवा अधिक कर्मचारी असलेल्या कार्यस्थळी आंतरिक समिती योग्य रचनेनुसार असावी.',
      'poshStudy2Bullet3':
          'समितीत सामान्यतः वरिष्ठ महिला अध्यक्ष, कर्मचारी सदस्य आणि बाह्य सदस्य समाविष्ट असतात.',
      'poshStudy2Bullet4':
          'समेट फक्त तक्रारकर्त्याने हवे असल्यास वापरता येतो; हे जबरदस्तीचे नसावे.',
      'poshStudy2Bullet5':
          'जर समेट झाले नाही तर IC निष्पक्ष चौकशी करते जिथे दोन्ही बाजू ऐकल्या जातात.',
      'poshStudy2Bullet6': 'प्रक्रिया गोपनीय, लेखी आणि दस्तऐवजीकृत राहावी.',
      'poshStudy3Title': 'पुरावे, सुरक्षा आणि नियोक्त्याचे कर्तव्य',
      'poshStudy3Bullet1':
          'चॅट, ईमेल, स्क्रीनशॉट, कॉल लॉग, साक्षीदारांची नावे, तारखा आणि ठिकाणे नोंद ठेवा.',
      'poshStudy3Bullet2':
          'अंतरिम मदत म्हणून बदली, रजा, संपर्क-निषेध किंवा रिपोर्टिंग-लाइन बदल समाविष्ट असू शकतो.',
      'poshStudy3Bullet3':
          'जर तथ्यांनी गुन्हे दाखवले तर POSH प्रक्रियेव्यतिरिक्त पोलिस तक्रार/FIR नोंदवता येऊ शकते.',
      'poshStudy3Bullet4':
          'नियोक्त्यांनी धोरण प्रदर्शित करावे, कर्मचारी प्रशिक्षण द्यावा, IC ला समर्थन द्यावे आणि शिफारसी लागू कराव्यात.',
      'poshStudy3Bullet5':
          'गोपनीयता तक्रारकर्ता, प्रतिवादी, साक्षीदार आणि कार्यवाहीवर लागू होते.',
      'poshStudy3Bullet6':
          'एक तक्रार फक्त म्हणून खोटी नाही की ती सिद्ध केली जाऊ शकली नाही; जानबूझून खोटेपणा वेगळा प्रकरण आहे.',
      'poshStudy4Title': 'महत्वाचे POSH मर्यादा',
      'poshStudy4Bullet1':
          'अनावश्यक वैयक्तिक वाद किंवा जाणूनबुजून बनवलेल्या आरोपांसाठी यंत्रणा वापरू नका.',
      'poshStudy4Bullet2':
          'पुरावे नष्ट करू नका आणि साक्षीदारांवर दबाव आणू नका.',
      'poshStudy4Bullet3':
          'लहान परंतु सतत घडणाऱ्या घटनांकडे दुर्लक्ष करू नका; नमुने महत्त्वाचे आहेत.',
      'poshStudy4Bullet4':
          'तथ्यात्मक, तारीख-निहायत आणि तपशीलवार रिपोर्टिंग वापरा.',
      'poshStudy4Bullet5':
          'तत्काळ धोक्यात असाल तर प्रथम आपत्कालीन सेवा कॉल करा.',
      'poshStudy4Bullet6':
          'POSH पोर्टल शिकण्यासाठी, दस्तऐवजीकरणासाठी आणि संरचित तक्रार तयारीसाठी आहे.',
      'studyFirst': 'आधी अभ्यास करा',
      'readAllSectionsBeforeQuiz1': 'क्विझ 1 पूर्वी सर्व विभाग वाचा',
      'threeLevels': 'तीन स्तर',
      'twentyMcqsEachQuiz': 'प्रत्येक क्विझमध्ये 20 MCQ',
      'quizCertificationTrack': 'क्विझ प्रमाणपत्र ट्रॅक',
      'studyFirstThenClearQuizzesInOrder':
          'आधी अभ्यास करा, मग क्विझ क्रमाने पूर्ण करा.',
      'level': 'स्तर',
      'levelPassed': 'स्तर पूर्ण',
      'passed': 'पूर्ण',
      'available': 'उपलब्ध',
      'locked': 'लॉक',
      'submitQuiz': 'क्विझ सबमिट करा',
      'next': 'पुढे',
      'unlocked': 'अनलॉक',
      'quizNotClearedYet': 'क्विझ अद्याप साफ झालेले नाही',
      'reviewStudy': 'अभ्यास पहा',
      'retry': 'पुन्हा प्रयत्न',
      'viewCertificate': 'प्रमाणपत्र पहा',
      'continueLabel': 'सुरू ठेवा',
      'poshCertified': 'POSH प्रमाणित',
      'fileWorkplaceComplaint': 'कार्यस्थळी तक्रार नोंदवा',
      'fileWorkplaceComplaintSubtitle':
          'तुमच्या संदर्भासाठी तपशीलवार घटना नोंद तयार करा. हे अधिकृत IC, नियोक्ता किंवा सरकारी दाखल नाही. तातडीच्या धोक्यात 112 वर कॉल करा.',
      'keepRecordsFactual':
          'तुमची नोंद तथ्यात्मक ठेवा आणि शक्य असल्यास पुरावा जोडा.',
      'yourFullName': 'तुमचे पूर्ण नाव',
      'yourPhoneNumber': 'तुमचा फोन नंबर',
      'yourEmailAddress': 'तुमचा ईमेल पत्ता',
      'accusedPersonName': 'आरोपी व्यक्तीचे नाव',
      'companyWorkplaceName': 'कंपनी / कार्यस्थळाचे नाव',
      'incidentDateDdMmYyyy': 'घटनेची तारीख (DD/MM/YYYY)',
      'incidentLocation': 'घटनेचे ठिकाण',
      'witnessesIfAny': 'साक्षीदार (असल्यास)',
      'detailedIncidentDescription': 'घटनेचे सविस्तर वर्णन',
      'submitting': 'सबमिट करत आहे...',
      'submitComplaint': 'तक्रार सबमिट करा',
      'guideIntro':
          'हे मार्गदर्शक शैक्षणिक आणि कार्यात्मक आहे. हे भारतातील POSH चौकटीतील प्रक्रिया, मर्यादा, दस्तऐवजीकरण आणि पुढील पावले समजावते.',
      'legalDisclaimer':
          'कायदेशीर अस्वीकरण: Suraksha फक्त शैक्षणिक POSH मार्गदर्शन देते—कायदेशीर सल्ला किंवा अधिकृत दाखल नाही. येथे ड्राफ्ट/नोंद जतन केल्याने IC, नियोक्ता किंवा सरकारला सबमिट होत नाही. महत्त्वाच्या बाबींमध्ये पात्र वकील, HR-POSH तज्ज्ञ किंवा सक्षम प्राधिकरणाचा सल्ला घ्या.',
      'poshLegalSourceLabel': 'कायदेशीर स्रोत',
      'poshLegalSourceNote':
          'POSH कायदा, 2013 आणि प्रकाशित कार्यस्थळ अनुपालन मार्गदर्शनावर आधारित शैक्षणिक सारांश. अधिकृत सरकारी दाखल चॅनेल नाही.',
      'poshLastReviewed': 'सामग्री शेवटचे पुनरावलोकन: {date}',
      'poshHubEducationTitle': 'शिक्षण',
      'poshHubEducationSubtitle':
          'POSH मूलभूत माहिती वाचा आणि तपशीलवार कायदा मार्गदर्शक उघडा.',
      'poshHubQuizTitle': 'क्विझ',
      'poshHubQuizSubtitle':
          'प्रमाणपत्रासाठी तीन क्विझ स्तर पूर्ण करा.',
      'poshHubComplaintTitle': 'तक्रार तयारी',
      'poshHubComplaintSubtitle':
          'घटना तपशील सुरक्षितपणे ड्राफ्ट करा—Suraksha अधिकृत पोर्टल नाही.',
      'poshHubCertificateTitle': 'प्रमाणपत्र',
      'poshHubCertificateSubtitle':
          'सर्व क्विझ स्तर पूर्ण केल्यानंतर POSH जागरूकता प्रमाणपत्र पहा.',
      'poshFilingBoundaryTitle': 'अधिकृत दाखल नाही',
      'poshFilingBoundaryMessage':
          'ड्राफ्ट किंवा Suraksha मध्ये जतन केल्याने फक्त या अॅपमध्ये खाजगी नोंद राहते. हे IC, नियोक्ता किंवा कोणत्याही सरकारी पोर्टलवर दाखल होत नाही. अधिकृतपणे कार्यस्थळ IC किंवा सक्षम प्राधिकरणाद्वारे सबमिट करा.',
      'poshSaveDraft': 'ड्राफ्ट जतन करा',
      'poshDraftSaved': 'ड्राफ्ट या डिव्हाइसवर सुरक्षितपणे जतन केला.',
      'poshSaveToSuraksha': 'Suraksha मध्ये जतन करा (अधिकृत दाखल नाही)',
      'poshSavedToSurakshaNotice':
          'तुमच्या नोंदीसाठी Suraksha मध्ये जतन केले. हे अधिकृत IC किंवा सरकारी सबमिशन नाही.',
      'poshDangerDetectedTitle': 'तातडीचा धोका ओळखला',
      'poshDangerDetectedMessage':
          'तुमच्या नोंदींमुळे तातडीचा धोका असू शकतो. आता आपत्कालीन सेवांना कॉल करा किंवा डॅशबोर्डवरून SOS उघडा.',
      'poshCall112': '112 वर कॉल करा',
      'poshOpenSos': 'SOS उघडा',
      'poshGuideContents': 'अनुक्रमणिका',
      'poshGuideSearchHint': 'मार्गदर्शक विभाग शोधा',
      'poshGuideNoSearchResults': 'तुमच्या शोधाशी कोणताही विभाग जुळत नाही.',
      'poshGuideBookmark': 'विभाग बुकमार्क करा',
      'poshGuideBookmarked': 'बुकमार्क केले',
      'poshGuideFontSize': 'मजकूर आकार',
      'poshCertificateNotReady':
          'प्रमाणपत्र अनलॉक करण्यासाठी तीनही क्विझ स्तर पूर्ण करा.',
      'poshComplaintDraftRestored': 'तुमचा जतन केलेला ड्राफ्ट पुनर्स्थापित केला.',
      'guide1Title': '1. पार्श्वभूमी आणि उद्देश',
      'guide1Body':
          'कार्यस्थळी महिलांचे लैंगिक छळ (प्रतिबंध, प्रतिबंध आणि निवारण) अधिनियम, 2013 — सामान्यतः POSH कायदा — कार्यस्थळांना लैंगिक छळ रोखणे, तो प्रतिबंधित करणे आणि निष्पक्ष निवारण यंत्रणा देण्याचे स्पष्ट कायदेशीर कर्तव्य देतो.\n\n'
          'तो सर्वोच्च न्यायालयाच्या विशाखा मार्गदर्शक तत्त्वांवर (1997) आधारित असून त्यांना वैधानिक चौकटीत आणतो. मुख्य उद्देश: (1) कामाच्या ठिकाणी लैंगिक छळाची प्रतिबंधक कारवाई, (2) धोरण व जबाबदारीद्वारे निषेध, आणि (3) सुलभ तक्रार व चौकशी यंत्रणा.\n\n'
          'आच्छादित प्रत्येक नियोक्त्याने सुरक्षित कामाचे वातावरण द्यावे, तक्रार प्रक्रियेची माहिती प्रदर्शित करावी, कर्मचाऱ्यांना संवेदनशील करावे आणि सूड न घेता Internal Committee (IC) किंवा Local Committee (LC) प्रक्रियेत सहकार्य करावे.\n\n'
          'Suraksha चे हे मार्गदर्शक फक्त शैक्षणिक आहे. ते प्रक्रिया समजून घेण्यास आणि नोंदी तयार करण्यास मदत करते. हे कायदेशीर सल्ल्याचा पर्याय नाही आणि Suraksha वापरल्याने आपोआप IC, नियोक्ता किंवा सरकारकडे तक्रार दाखल होत नाही.',
      'guide2Title': '2. कुठे लागू होते',
      'guide2Body':
          'हा कायदा भारतातील संघटित आणि अनेक असंघटित कार्यस्थळ सेटिंग्जवर व्यापक लागू होतो. “कार्यस्थळ” फक्त पारंपरिक ऑफिस डेस्कपुरते मर्यादित नाही. त्यात सरकारी व खासगी कार्यालये, कारखाने, दुकाने, रुग्णालये, शैक्षणिक संस्था, NGO, क्रीडा संस्था, स्टेडियम आणि इतर प्रतिष्ठाने येऊ शकतात.\n\n'
          'नोकरीदरम्यान भेट दिलेली ठिकाणेही येऊ शकतात — उदा. क्लायंट साइट, प्रशिक्षण स्थळे, परिषदा आणि कामाच्या प्रवासा. घरकामाच्या काही संदर्भांसह निवासस्थाने जेव्हा कार्यस्थळ म्हणून वापरली जातात, वैधानिक अटी पूर्ण झाल्यास कायद्याच्या कक्षेत येऊ शकतात.\n\n'
          'रिमोट किंवा हायब्रिड काम संरक्षण काढून टाकत नाही. ऑफिस ईमेल, अधिकृत चॅट, व्हिडिओ मीटिंग किंवा कामाशी संबंधित डिजिटल माध्यमांतील वर्तनही नोकरीशी जोडलेले असल्यास कार्यस्थळ-संबंधित असू शकते.\n\n'
          'संस्थेत 10 पेक्षा कमी कर्मचारी असल्यास तक्रारी सामान्यतः जिल्हा अधिकाऱ्याने स्थापन केलेल्या Local Committee (LC) मार्फत जातात, Internal Committee ऐवजी.',
      'guide3Title': '3. कोण संरक्षित आहे',
      'guide3Body':
          'कायदा मुख्यतः कार्यस्थळाच्या संदर्भात “व्यथित स्त्री”चे संरक्षण करतो. संरक्षण फक्त पेरोलवरील कायम कर्मचाऱ्यांपुरते मर्यादित नाही. नियमित, तात्पुरते, तदर्थ, रोजंदारी, करार कर्मचारी, प्रशिक्षणार्थी, अप्रेंटिस, इंटर्न आणि अनेक व्यावहारिक संदर्भात कामाशी संबंधित महिला अभ्यागतही येऊ शकतात.\n\n'
          'प्रतिवादी (ज्याच्याविरुद्ध तक्रार आहे) कर्मचारी, नियोक्ता किंवा कार्यस्थळाशी संबंधित अन्य व्यक्ती असू शकतो. पदाचा फरक — कनिष्ठ विरुद्ध वरिष्ठ, कंत्राटदार विरुद्ध फुल-टाइम — केवळ तक्रार रद्द करत नाही.\n\n'
          'POSH हा महिलांच्या कार्यस्थळ सुरक्षेचा कायदा आहे. इतर लिंगांसंबंधी छळ इतर कायदे/संस्थात्मक धोरणांशी जोडला जाऊ शकतो; ते मार्ग येथे वर्णन केलेल्या POSH चौकटीपेक्षा वेगळे आहेत.\n\n'
          'तुमची भूमिका कव्हर होते का याबाबत शंका असल्यास नियोजन प्रकार, ठिकाण आणि घटनेचा कामाशी संबंध नोंदवा — नंतर IC/LC संपर्क, POSH-जागरूक HR किंवा वकिलाचा सल्ला घ्या.',
      'guide4Title': '4. लैंगिक छळ म्हणजे काय',
      'guide4Body':
          'कायद्यानुसार लैंगिक छळात लैंगिक स्वरूपाचे एक किंवा अधिक अनिष्ट कृत्य/वर्तन येते, थेट असो वा निहित. उदाहरणे: अनिष्ट शारीरिक संपर्क व प्रगती; लैंगिक अनुग्रहाची मागणी/विनंती; लैंगिक रंगाच्या टिप्पण्या; अश्लील सामग्री दाखवणे; तसेच लैंगिक स्वरूपाचे अन्य अनिष्ट शारीरिक, मौखिक किंवा अमौखिक वर्तन.\n\n'
          'छळ एक गंभीर घटना किंवा मालिका असू शकतो. तो समोरासमोर किंवा डिजिटल माध्यमांनी (संदेश, कॉल, ईमेल, सोशल मीडिया, डीपफेक, मॉर्फ्ड प्रतिमा)ही होऊ शकतो जेव्हा तो कार्यस्थळ संबंधाशी जोडलेला असतो.\n\n'
          'मुख्य मुद्दा म्हणजे वर्तन अनिष्ट आहे. मौन, जुनी मैत्री किंवा पदक्रम यातून संमती गृहीत धरता येत नाही. क्विड प्रो क्वो (लैंगिक अनुग्रहाशी जोडलेले लाभ/धमक्या) आणि लैंगिक वर्तनामुळे निर्माण झालेले शत्रुत्वपूर्ण कामाचे वातावरण दोन्ही गंभीर आहेत.\n\n'
          'प्रत्येक कार्यस्थळ वाद लैंगिक छळ नसतो. उद्धट पण गैर-लैंगिक वर्तन इतर धोरणांचे उल्लंघन असू शकते. POSH साठी लक्ष द्या: वर्तन लैंगिक स्वरूपाचे व अनिष्ट आहे का — तारखा, शब्द/कृत्ये, परिणाम आणि साक्षीदार नोंदवा.',
      'guide5Title': '5. अंतर्गत समिती (IC) आवश्यकता',
      'guide5Body':
          '10 किंवा अधिक कर्मचारी असलेल्या प्रत्येक कार्यस्थळी Internal Committee (IC) स्थापन करणे बंधनकारक आहे. सामान्यतः त्यात: वरिष्ठ महिला कर्मचारी म्हणून Presiding Officer; किमान दोन कर्मचारी सदस्य (अधिमानतः महिला मुद्दे/सामाजिक कार्य/कायदेशीर ज्ञानाशी संबंधित); आणि NGO/संस्थेतील बाह्य सदस्य किंवा लैंगिक छळ मुद्द्यांशी परिचित व्यक्ती.\n\n'
          'एकूण सदस्यांपैकी किमान अर्ध्या महिला असाव्यात. सदस्यांचा कार्यकाळ सामान्यतः जास्तीत जास्त तीन वर्षे असतो. नियोक्त्याने IC प्रत्यक्षात कार्यरत असल्याची खात्री करावी — फक्त कागदावरील नावे पुरेशी नाहीत.\n\n'
          'जिथे IC नाही (10 पेक्षा कमी कर्मचारी असलेली कार्यस्थळे सहित), जिल्हास्तरीय Local Committee (LC) हे मंच असते. आवश्यक असताना IC न स्थापन केल्यास कायद्यानुसार दंड आणि वारंवार अवहेलनेवर अधिक परिणाम होऊ शकतात.\n\n'
          'व्यावहारिकदृष्ट्या: HR/प्रशासनाकडून सद्य IC यादी, तक्रार ईमेल/ड्रॉप-बॉक्स आणि धोरण दस्तऐवज मागा. ती माहिती तुमच्या नोंदीत ठेवा.',
      'guide6Title': '6. तक्रार वेळमर्यादा आणि स्वरूप',
      'guide6Body':
          'सध्याच्या कायद्यानुसार (POSH कायदा, 2013) व्यथित स्त्रीने सामान्यतः घटनेपासून तीन महिन्यांत IC/LC कडे लेखी तक्रार द्यावी. घटनांच्या मालिकेत तीन महिने सामान्यतः शेवटच्या घटनेपासून मोजले जातात.\n\n'
          'IC/LC वेळ आणखी तीन महिन्यांपर्यंत वाढवू शकते (सध्याच्या चौकटीत एकूण जास्तीत जास्त सहा महिने), जर परिस्थितीमुळे वेळेवर दाखल करता आले नाही याबाबत समाधानी असेल आणि कारणे लेखी नोंदवावी लागतात. सार्वजनिक चर्चेतील प्रस्तावित दुरुस्त्या (लांब वेळमर्यादा सहित) लागू होईपर्यंत सध्याच्या वैधानिक नियमाचा पर्याय नाहीत — तुमच्या वेळमर्यादेचे पालन करा आणि मर्यादेजवळ/नंतर कायदेशीर सल्ला घ्या.\n\n'
          'मजबूत तक्रारीत सामान्यतः असते: तक्रारदार व प्रतिवादी ओळख; कार्यस्थळ तपशील; तारीख/वेळ/ठिकाण; स्पष्ट तथ्ये; साक्षीदारांची नावे; पुरावा यादी; काम/आरोग्य/सुरक्षेवरील परिणाम; आणि मागितलेली मदत (उदा. संपर्क-निषेध, बदली, चौकशी, अंतरिम उपाय).\n\n'
          'लिहिणे अवघड असल्यास कायदा सहाय्याची तरतूद करतो जेणेकरून तक्रार लेखबद्ध करून सही/पडताळणी करता येईल. जे सबमिट कराल त्याची दिनांकित प्रत स्वतःकडे ठेवा.',
      'guide7Title': '7. संमती/समेट आणि चौकशी',
      'guide7Body':
          'पूर्ण चौकशीपूर्वी, व्यथित स्त्रीच्या विनंतीनुसार IC समेट/सुलह प्रयत्न करू शकते. समेट स्वैच्छिक आहे. कायद्याच्या समेट चौकटीत आर्थिक समझोता आधार म्हणून परवानगी नाही. यशस्वी समेटानंतर IC समझोता नोंदवते आणि सामान्यतः त्या अटींवर पुढील चौकशी करत नाही; प्रती नियोक्ता व पक्षांना यथायोग्य जातात.\n\n'
          'समेट न मागितल्यास, अयशस्वी झाल्यास किंवा अनुचित असल्यास IC चौकशी पुढे नेते. प्रतिवादीला कळवून लेखी उत्तर देण्याची संधी दिली जाते. दोन्ही बाजू ऐकल्या जातात; नैसर्गिक न्यायाची तत्त्वे लागू होतात. कायद्याच्या चौकटीत IC कडे काही उद्देशांसाठी दिवाणी न्यायालयासारख्या शक्ती आहेत (उदा. शपथेवर बोलावणे, दस्तऐवज मागणे).\n\n'
          'चौकशी सामान्यतः 90 दिवसांत पूर्ण व्हावी. पूर्ण झाल्यानंतर 10 दिवसांत IC नियोक्त्याला (किंवा LC प्रकरणांत जिल्हा अधिकाऱ्याला) अहवाल देते आणि संबंधित पक्षांना उपलब्ध करून देते.\n\n'
          'फक्त तोंडी अपडेटवर अवलंबून राहू नका. लेखी पावती, सुनावणी तारखा आणि तुम्हाला हक्क असलेल्या प्रती मागा.',
      'guide8Title': '8. प्रक्रियेतील अंतरिम मदत',
      'guide8Body':
          'चौकशीदरम्यान IC तक्रारदाराचे संरक्षण आणि निष्पक्ष प्रक्रियेसाठी अंतरिम उपाय सुचवू शकते. सामान्य उदाहरणे: कोणत्याही पक्षाची बदली; व्यथित स्त्रीला रजा (वैधानिक मर्यादेत, अन्य हक्काव्यतिरिक्त); रिपोर्टिंग संबंध बदलणे; प्रतिवादीला तक्रारदाराच्या कामाचे मूल्यांकन करण्यास मनाई; संपर्क/संवाद निर्बंध; आणि कार्यस्थळ सुरक्षा मदत.\n\n'
          'अंतरिम मदत दोष सिद्ध झाल्याचा अंतिम निष्कर्ष नाही. हे संरक्षण व प्रक्रिया-अखंडतेचे पाऊल आहे. सतत संपर्क, धमकी, कामगिरी-सूड किंवा असुरक्षित जवळीक असल्यास अंतरिम उपाय लेखी मागा.\n\n'
          'अंतरिम शिफारशी झाल्यास नियोक्त्याने त्या लागू कराव्यात. प्रत्यक्षात लागू झाल्या का ते ट्रॅक करा. सूड सुरू राहिल्यास प्रत्येक घटना तारीख, वेळ, व्यक्ती आणि संदेश/ईमेलसह नोंदवा.\n\n'
          'तातडीच्या शारीरिक धोक्यात आधी 112 / स्थानिक पोलिसांना कॉल करा. POSH अंतरिम उपाय कार्यस्थळ प्रक्रियेची साधने आहेत — आपत्कालीन प्रतिसादाचा पर्याय नाहीत.',
      'guide9Title': '9. चौकशी निकाल आणि नियोक्त्याची कारवाई',
      'guide9Body':
          'चौकशीनंतर IC निष्कर्ष देते. आरोप सिद्ध न झाल्यास प्रतिवादीविरुद्ध कारवाई आवश्यक नसल्याची शिफारस होऊ शकते. सिद्ध झाल्यास सेवा नियम / लागू शिस्तभंगाच्या नियमांनुसार कारवाई सुचवली जाऊ शकते — इशारा, लेखी माफी, समुपदेशन, पदोन्नती/वेतनवाढ रोखणे, नोकरी समाप्ती किंवा इतर कायदेशीर शिस्तभंगाची पावले.\n\n'
          'IC व्यथित स्त्रीला भरपाईचीही शिफारस करू शकते, जी कायदा/नियमांनुसार लागू असेल तर प्रतिवादीच्या पगारातून वसूल करता येऊ शकते.\n\n'
          'नियोक्त्याने IC च्या शिफारशी मिळाल्यापासून 60 दिवसांत लागू करणे आवश्यक आहे. लागू न करणे स्वतः नियोक्त्यासाठी अनुपालन जोखीम निर्माण करू शकते.\n\n'
          'तुमच्यासाठी लागू लेखी निकाल मागा, अंमलबजावणीची मुदत नोंदवा आणि कोणती कारवाई झाली (किंवा झाली नाही) याचा पुरावा ठेवा.',
      'guide10Title': '10. पोलिस तक्रार आणि फौजदारी कायदा',
      'guide10Body':
          'POSH हे कार्यस्थळाचे नागरी/प्रशासकीय निवारण चौकट आहे. ते फौजदारी कायदा रद्द करत नाही. तथ्यांमधून भारतीय न्याय संहिता (किंवा घटना तारखेनुसार पूर्वीचे IPC प्रावधान), माहिती तंत्रज्ञान कायदा किंवा इतर फौजदारी कायद्यांतील गुन्हे दिसल्यास समांतर किंवा स्वतंत्रपणे पोलिस तक्रार / FIR शक्य आहे.\n\n'
          'वारंवार फौजदारी मूल्यांकनाची गरज असलेल्या परिस्थिती (प्रकरण-विशिष्ट): लैंगिक हल्ला, स्टॉकिंग, फौजदारी धमकी, व्हॉयरिझम, संमतीविना अंतरंग प्रतिमा, ब्लॅकमेल आणि काही ऑनलाइन लैंगिक गुन्हे.\n\n'
          'योग्य असल्यास IC प्रक्रिया आणि फौजदारी उपाय एकत्र चालू शकतात. पोलिस प्रकरण असेल तर IC ला सांगा कारण समन्वय व पुरावा महत्त्वाचे ठरू शकतात. पोलिस/फॉरेन्सिकसाठी लागणारी उपकरणे किंवा मूळ फाइल्स नष्ट करू नका.\n\n'
          'तातडीच्या धोक्यात 112 कॉल करा, शक्य असल्यास सुरक्षित सार्वजनिक ठिकाणी जा आणि Suraksha SOS ने विश्वासू संपर्कांना कळवा. पुरेसे सुरक्षित झाल्यावर कार्यस्थळ POSH पावले उचला.',
      'guide11Title': '11. गोपनीयता नियम',
      'guide11Body':
          'गोपनीयता POSH चे मध्यवर्ती कर्तव्य आहे. व्यथित स्त्री, प्रतिवादी आणि साक्षीदारांची ओळख व पत्ते; समेट व चौकशीसंबंधी माहिती; तसेच तक्रार व निष्कर्षांची सामग्री कायद्याचे उल्लंघन करून सार्वजनिक, प्रेस किंवा मीडियामध्ये प्रकाशित/कळवू नये.\n\n'
          'मर्यादित प्रकटीकरण कायद्याने आवश्यक असू शकते (उदा. अंमलबजावणीसाठी नियोक्ता, निष्पक्ष सुनावणीसाठी पक्ष, किंवा कायदेशीर प्राधिकार). चालू प्रकरणांबद्दल गॉसिप, ग्रुप चॅट आणि सोशल मीडिया पोस्ट कायदेशीर व सुरक्षा जोखीम निर्माण करू शकतात.\n\n'
          'नियोक्ता व IC सदस्यांनी दस्तऐवज सुरक्षित ठेवावेत. तक्रारदारानेही प्रती सुरक्षित ठेवाव्यात (एन्क्रिप्टेड वॉल्ट, मर्यादित फोल्डर) आणि फक्त विश्वासू सल्लागार/वकिलांसोबत शेअर कराव्यात.\n\n'
          'कोणी तुमची ओळख किंवा केस तपशील लीक केल्यास काय लीक झाले, कोणी, केव्हा आणि कुठे — नोंदवा आणि IC/नियोक्ता तसेच गरज असल्यास कायदेशीर सल्लागाराकडे उपस्थित करा.',
      'guide12Title': '12. खोट्या तक्रारी: योग्य कायदेशीर स्थिती',
      'guide12Body':
          'सिद्ध न झालेली तक्रार आपोआप “खोटी” किंवा “द्वेषपूर्ण” ठरत नाही. पीडितांकडे पुराव्याच्या मर्यादा, भीती, साक्षीदारांची कमतरता किंवा आघातजन्य अंतर असू शकतात. कायदा अप्रमाणित प्रकरण आणि जाणूनबुजून खोटे आरोप/बनावट पुरावा असलेल्या प्रकरणात फरक करतो.\n\n'
          'द्वेषपूर्ण/खोट्या तक्रारीवर कारवाई तेव्हा विचारली जाते जेव्हा IC निष्कर्ष काढते की आरोप जाणून खोटा केला गेला, किंवा बनावट/भ्रामक पुरावा सादर झाला. हा उच्च व विशिष्ट निकष आहे — प्रत्येक फेटाळलेल्या तक्रारीचे डिफॉल्ट लेबल नाही.\n\n'
          '“तक्रार केलीत तर खोट्या केसचा उलट खटला” अशा धमक्या कधीकधी घाबरवण्यासाठी वापरल्या जातात. अशा धमक्या नोंदवा. दबावाखाली खरी तक्रार मागे घेण्यापूर्वी स्वतंत्र कायदेशीर सल्ला घ्या.\n\n'
          'सद्भावपूर्ण तक्रारदाराने अचूक तथ्ये, सुरक्षित पुरावे आणि सुसंगत विधाने यावर लक्ष केंद्रित करावे. तारखा फुगवू नका किंवा तपशील बनवू नका — विश्वासार्हता सत्यावर अवलंबून असते.',
      'guide13Title': '13. कायद्याचा गैरवापर कसा करू नये',
      'guide13Body':
          'POSH लैंगिक छळ हाताळण्यासाठी आणि कार्यस्थळ सन्मानाचे रक्षण करण्यासाठी आहे. गैरवापर खऱ्या पीडितांना नुकसान पोहोचवतो आणि यंत्रणेवरील विश्वास कमी करतो. असंबंधित हिसाब चुकते करण्यासाठी (फक्त कामगिरी वाद, लैंगिक छळ तथ्यांशिवाय वैयक्तिक नातेसंबंध संपुष्टात, किंवा ऑफिस राजकारण) तक्रार करू नका.\n\n'
          'साक्षीदारांना खोटे बोलण्यास प्रवृत्त करू नका, दिशाभूल करण्यासाठी चॅट एक्सपोर्ट निवडक बदलू नका, बनावट स्क्रीनशॉट तयार करू नका आणि गैरसोयीचे पुरावे नष्ट करू नका. ज्या सहकाऱ्यांनी अनुभवले नाही त्यांना तक्रारीत जबरदस्ती सामील करू नका.\n\n'
          'प्रतिवादीनेही प्रक्रियेचा गैरवापर करू नये: सूड नाही, साक्षीदार घाबरवणे नाही, गोपनीय तक्रार तपशील लीक नाही, आणि निष्पक्ष सुनावणी रोखण्यासाठी पदक्रम शक्तीचा वापर नाही.\n\n'
          'चिंता गंभीर असूनही लैंगिक छळ नसल्यास योग्य मार्ग वापरा (तक्रार निवारण, श्रम प्राधिकरण, फौजदारी कायदा किंवा दिवाणी उपाय) — तथ्ये जबरदस्ती POSH मध्ये घुसू नका.',
      'guide14Title': '14. नियोक्ता अनुपालन सूची',
      'guide14Body':
          'अनुपालनशील नियोक्त्याने सामान्यतः: (1) 10+ कर्मचारी असल्यास योग्य रचनेची IC स्थापन करावी, (2) IC नामांकन व संपर्क अधिसूचित करावे, (3) POSH धोरण प्रकाशित व प्रसारित करावे, (4) लैंगिक छळाचे परिणाम व तक्रार पद्धतीबाबत स्पष्ट सूचना लावाव्यात, (5) कर्मचारी व IC सदस्यांसाठी नियमित जागरूकता/क्षमतावर्धन करावे, (6) तक्रार प्रक्रियेत मदत करावी व IC/LC ला सुविधा द्याव्यात, (7) वेळेवर चौकशी व शिफारशींची वैधानिक मुदतीत अंमलबजावणी सुनिश्चित करावी, आणि (8) कायदा/नियमांनुसार आवश्यक अहवाल/रिटर्न सादर करावे.\n\n'
          'नियोक्त्याने तक्रारदार व साक्षीदारांविरुद्ध सूड रोखणे व हाताळणेही आवश्यक आहे. तक्रारीनंतर भीतीचे वातावरण निर्माण करणे “तटस्थता” नाही, अनुपालन अपयश आहे.\n\n'
          'तुमच्या कार्यस्थळाकडून मागा: धोरण PDF, IC यादी, प्रशिक्षण नोंदी आणि तक्रार सादर पद्धत. मूलभूत अनुपालन माहिती नाकारल्यास ती खाजगी नोंदीत लिहा आणि LC/कायदेशीर सल्ला मार्ग विचारा.\n\n'
          'सरकारी व खासगी दोन्ही नियोक्त्यांकडून कायदा लागू असल्यास मूळ कर्तव्ये पूर्ण करण्याची अपेक्षा आहे; आकार व क्षेत्र ती मिटवत नाहीत.',
      'guide15Title': '15. व्यावहारिक पुरावा सूची',
      'guide15Body':
          'पुरावे लवकर सुरक्षित ठेवा. उपयुक्त साहित्य अनेकदा: तारीख व हँडल दिसणारे चॅट/ईमेल/DM स्क्रीनशॉट; मूळ संदेश निर्यात; कॉल लॉग; मीटिंग आमंत्रणे/कॅलेंडर; CCTV विनंती संदर्भ; जवळीक दाखवणारे अॅक्सेस-कार्ड/उपस्थिती लॉग; साक्षीदारांची नावे व त्यांनी काय पाहिले/ऐकले; व्यवस्थापक/HR कडे पूर्वीच्या लेखी तक्रारी; संबंधित वैद्यकीय/समुपदेशन नोंदी (जर शेअर करायचे ठरवले); आणि घटनांनंतर लगेच लिहिलेला वैयक्तिक टाइमलाइन.\n\n'
          'शक्य असल्यास मूळ ठेवा. मेटाडेटा काढणारे संपादन टाळा. बॅकअप एकापेक्षा जास्त सुरक्षित ठिकाणी ठेवा. प्रक्रिया सुरू असताना पुरावे सार्वजनिक पोस्ट करू नका.\n\n'
          'कालक्रमानुसार नोंद लिहा: तारीख → ठिकाण → काय झाले → कोण उपस्थित होते → तुम्ही काय म्हटले/केले → तत्काळ परिणाम → पुढील छळ. नवीन घटनांवर अपडेट करा.\n\n'
          'Suraksha ड्राफ्ट नोंद व्यवस्थित करण्यास मदत करू शकते, पण अधिकृत सबमिशन तरीही तुमच्या IC/LC किंवा इतर सक्षम प्राधिकरणाकडे जाणे आवश्यक आहे. धोक्यात परिपूर्ण दस्तऐवजीकरणापेक्षा सुरक्षा व आपत्कालीन मदत प्राधान्य द्या.',
      'guide16Title': '16. अपील आणि इतर उपाय',
      'guide16Body':
          'IC/LC च्या शिफारशींमुळे व्यथित असल्यास कायदा अधिसूचित न्यायालय/ट्रिब्युनलमध्ये अपीलची तरतूद करतो — सामान्यतः समान शिस्तभंग प्रकरणांसाठी सेवा नियमांच्या अपीलीय मार्गाशी जोडलेले. अपील कालबद्ध असते (सामान्यतः शिफारशींपासून 90 दिवसांत, तुमच्या प्रकरणावर लागू कायदा/नियमांनुसार).\n\n'
          'POSH अपीलाव्यतिरिक्त तथ्यांनुसार इतर उपाय असू शकतात: फौजदारी गुन्ह्यांसाठी पोलिस/FIR; श्रम/सेवा-कायदा आव्हाने; दिवाणी दावे; उच्च प्रशासकीय प्राधिकरणांकडे तक्रारी; किंवा योग्य असल्यास राष्ट्रीय/राज्य महिला आयोग.\n\n'
          'नियोक्त्याने IC शिफारशी लागू न केल्यास चूक नोंदवा आणि अंमलबजावणी/अनुपालन तक्रारीबाबत कायदेशीर सल्ला घ्या.\n\n'
          'अपीलीय रणनीती प्रकरण-विशिष्ट असल्याने लेखी निकाल मिळताच वकिलाचा सल्ला घ्या जेणेकरून मर्यादा कालावधी चुकणार नाही.',
      'guide17Title': '17. POSH पोर्टलचा सद्भावपूर्ण वापर',
      'guide17Body':
          'Suraksha च्या या POSH विभागाचा सद्भावाने वापर करा: चौकट शिका, अचूक ड्राफ्ट तयार करा, पुरावा यादी व्यवस्थित करा आणि IC विरुद्ध फौजदारी मार्ग समजून घ्या. Suraksha मध्ये ड्राफ्ट किंवा नोंद जतन केल्याने Internal Committee, Local Committee, नियोक्ता किंवा सरकारी पोर्टलवर केस दाखल होत नाही.\n\n'
          'अधिकृत कारवाईसाठी तयार झाल्यावर तुमच्या कार्यस्थळ IC/LC प्रक्रियेद्वारे (किंवा इतर सक्षम प्राधिकरणाद्वारे) सबमिट करा. Suraksha प्रती तुमची वैयक्तिक तयारी फाइल म्हणून ठेवा.\n\n'
          'नोंदी किंवा परिस्थिती तातडीचा धोका दर्शवत असल्यास आधी 112 / आपत्कालीन सेवांना कॉल करा, शक्य असल्यास सुरक्षित ठिकाणी जा आणि Suraksha SOS ने विश्वासू संपर्कांना कळवा. सुरक्षित झाल्यानंतर कार्यस्थळ तक्रार तयारी सुरू ठेवता येते.\n\n'
          'फक्त सत्य माहिती शेअर करा. पोर्टलचा वापर इतरांना छळण्यासाठी, खोटे आरोप रचण्यासाठी किंवा गोपनीय केस तपशील पसरवण्यासाठी करू नका. सद्भावपूर्ण वापर तुम्हाला आणि ही यंत्रणा आवश्यक असलेल्या सर्वांचे रक्षण करतो.',
      'safeRouteChanged': 'सुरक्षित मार्ग बदलला',
      'dailyRouteGuard': 'दैनंदिन मार्ग सुरक्षा',
      'routeGuardDialogTitle': 'दैनंदिन मार्ग बदलला',
      'routeGuardDialogMessage':
          'तुम्ही नेहमीच्या मार्गापासून वळला आहात. तुम्ही सुरक्षित आहात याची खात्री करा.',
      'routeGuardConfirmWithin': '{seconds} सेकंदात पुष्टी करा.',
      'routeGuardDeviationMeters':
          'नेहमीच्या मार्गापासून सुमारे {meters} मीटर दूर.',
      'routeGuardLearningRoute': 'मार्ग शिकत आहे',
      'routeGuardRoutinesLearned': '{count} दिनचर्या शिकल्या',
      'routeGuardIntelligenceLimited': 'क्षेत्र डेटा मर्यादित',
      'routeGuardMapRouteActive': 'नकाशा मार्ग सक्रिय',
      'safetyVerdictSafe': 'कमी दिसणारा धोका',
      'safetyVerdictSafeSummary':
          'उपलब्ध संकेतांनुसार येथे सध्या कमी दिसणारा धोका आहे. ही सुरक्षिततेची हमी नाही—सजग राहा.',
      'safetyVerdictCaution': 'सावधानी बाळगा',
      'safetyVerdictCautionSummary':
          'येथे अतिरिक्त सावधानी बाळगा—जवळपास काही धोका संकेत आढळले आहेत.',
      'safetyVerdictHighRisk': 'जास्त चिंता',
      'safetyVerdictHighRiskSummary':
          'हा परिसर सध्या सुरक्षित वाटत नाही, विशेषतः महिला आणि ज्येष्ठ वापरकर्त्यांसाठी.',
      'safetyVerdictLimitedDataSummary':
          'या परिसरासाठी सध्या मर्यादित सत्यापित माहिती आहे. सजग राहा आणि सामान्य दिवसाच्या खबरदारी घ्या.',
      'safetyVerdictSafeWithEmergencySummary':
          '१ किमी मध्ये आपत्कालीन मदत उपलब्ध आहे. दिसणारा धोका कमी वाटतो, पण सुरक्षिततेची हमी नाही.',
      'safetyVerdictNoCoreEmergencySummary':
          '१ किमी मध्ये पोलीस स्टेशन किंवा रुग्णालय सापडले नाही. या परिसरात सजग राहा.',
      'safetyEmergencyWithin1kmTitle': '१ किमी मधील आपत्कालीन सेवा',
      'safetyReasonNoCoreEmergency1km':
          '१ किमी मध्ये पोलीस स्टेशन किंवा रुग्णालय उपलब्ध नाही.',
      'safetyReasonPoliceWithin1km':
          '१ किमी मध्ये {count} पोलीस स्टेशन.',
      'safetyReasonHospitalWithin1km':
          '१ किमी मध्ये {count} रुग्णालय.',
      'safetyReasonPharmacyWithin1km':
          '१ किमी मध्ये {count} फार्मसी.',
      'safetyReasonPetrolWithin1km':
          '१ किमी मध्ये {count} पेट्रोल पंप.',
      'safetyReasonWashroomWithin1km':
          '१ किमी मध्ये {count} स्वच्छतागृह.',
      'safetyReasonBloodBankWithin1km':
          '१ किमी मध्ये {count} रक्तपेढी.',
      'safetyVerdictMonitoring': 'अजून शिकत आहे',
      'safetyVerdictMonitoringSummary':
          'लाइव्ह परिसर माहिती अजून तयार होत आहे. शिकत असताना सजग राहा.',
      'safetyWhySafeTitle': 'दिसणारा धोका कमी का वाटतो',
      'safetyWhyNotSafeTitle': 'हा परिसर सुरक्षित का वाटत नाही',
      'safetyWhatToDo': 'काय करावे',
      'safetyUpdatingAreaIntelligence': 'परिसर सुरक्षा माहिती अद्यतन होत आहे...',
      'safetyActionSafe': 'सजग राहा आणि विश्वासार्ह संपर्क जवळ ठेवा.',
      'safetyActionCaution':
          'प्रकाशित भागात राहा आणि कुटुंबाला माहिती द्या.',
      'safetyActionHighRisk':
          'एकट्या मार्गांपासून दूर राहा आणि लाइव्ह लोकेशन विश्वासू व्यक्तीसोबत शेअर करा.',
      'safetyScoreDisclaimer':
          'स्कोअर फक्त दिसणाऱ्या संकेतांवर आधारित आहेत आणि परिसर सुरक्षित असल्याची हमी देत नाहीत.',
      'safetySourceGoogle': 'Google',
      'mapOfflineBannerTitle': 'ऑफलाइन — मर्यादित नकाशा सुविधा',
      'mapOfflineBannerBody':
          'शेवटचे ज्ञात स्थान दाखवत आहोत. जवळच्या सेवा, रूटिंग आणि ताजी सुरक्षा माहितीसाठी इंटरनेट आवश्यक.',
      'mapOfflinePlacesUnavailable':
          'जवळची ठिकाणे इंटरनेटशिवाय उपलब्ध नाहीत. आपत्कालीन कॉल अजूनही चालते.',
      'mapOfflineEmergencyHint':
          'नकाशा डेटेशिवायही आपत्कालीन कृती उपलब्ध आहेत:',
      'mapNearbyPlacesListTitle': 'जवळची सुरक्षा ठिकाणे',
      'mapTapToOpenPlace': 'हे ठिकाण उघडण्यासाठी दोनदा टॅप करा.',
      'routeGuardMonitoringActive': 'निरीक्षण सक्रिय',
      'routeGuardMonitoringInactive': 'निरीक्षण निष्क्रिय',
      'routeGuardLastChecked': 'शेवटची तपासणी {time}',
      'routeGuardDataConfidence': 'डेटा विश्वास: {level}',
      'routeGuardConfidenceHigh': 'उच्च',
      'routeGuardConfidenceMedium': 'तयार होत आहे',
      'routeGuardConfidenceLow': 'मर्यादित',
      'routeGuardRouteLearned': 'मार्ग शिकला',
      'routeGuardRouteNotLearned': 'मार्ग शिकलेला नाही',
      'liveLocationSharingWith': 'लाइव्ह लोकेशन शेअर केली',
      'stopLiveLocationSharing': 'शेअरिंग थांबवा',
      'aiSafetyIntelligence': 'एआय सुरक्षा इंटेलिजन्स',
      'refreshIntelligence': 'इंटेलिजन्स रीफ्रेश करा',
      'couldNotOpenGoogleMaps': 'Google Maps उघडता आले नाही.',
      'listView': 'यादी दृश्य',
      'mapView': 'नकाशा दृश्य',
      'nearbyCleanToilets': 'जवळची स्वच्छ शौचालये',
      'toiletsRefresh': 'रीफ्रेश',
      'toiletsIncreaseRadius': 'त्रिज्या वाढवा',
      'toiletsOpenMap': 'नकाशा उघडा',
      'toiletsTryAgain': 'पुन्हा प्रयत्न करा',
      'toiletsViewOnMap': 'नकाशावर पहा',
      'toiletsNavigate': 'नेव्हिगेट करा',
      'toiletsReportIssue': 'समस्या नोंदवा',
      'toiletsOpenNowOnly': 'फक्त आत्ता उघडे',
      'toiletsFemaleFacility': 'महिला सुविधा',
      'toiletsAccessible': 'सुलभ',
      'toiletsWaterAvailable': 'पाणी उपलब्ध',
      'toiletsResults': 'निकाल',
      'toiletsRadiusLabel': 'त्रिज्या',
      'toiletsScopeLabel': 'दायरा',
      'toiletsAllRegistered': 'सभी शौचालय',
      'toiletsAllRegisteredShort': 'सभी',
      'toiletsQualityLabel': 'गुणवत्ता',
      'toiletsCleanOnly': 'फक्त स्वच्छ',
      'toiletsCleanAndUsable': 'स्वच्छ + वापरण्यायोग्य',
      'mapTraffic': 'ट्रॅफिक',
      'mapTrafficSubtitle': 'रस्ता ट्रॅफिक ओव्हरले दाखवा',
      'mapPublicToilets': 'सार्वजनिक शौचालये',
      'mapLayers': 'नकाशा स्तर',
      'mapTypeNormal': 'सामान्य',
      'mapTypeHybrid': 'हायब्रिड',
      'mapTypeTerrain': 'भूभाग',
      'couldNotFindLocation': 'ते स्थान सापडले नाही.',
      'couldNotOpenPlace': 'हे स्थान उघडता आले नाही.',
      'unableToOpenIssueReporting': 'समस्या अहवाल उघडता आला नाही.',
      'impactDetected': 'आघात आढळला',
      'cancelSos': 'SOS रद्द करा',
      'sendSosNow': 'आत्ता SOS पाठवा',
      'later': 'नंतर',
      'openContacts': 'संपर्क उघडा',
      'servicePolice': 'पोलीस',
      'serviceHospitals': 'रुग्णालये',
      'servicePharmacies': 'फार्मसी',
      'servicePetrolPumps': 'पेट्रोल पंप',
      'serviceWashrooms': 'स्वच्छतागृहे',
      'serviceBloodBanks': 'रक्तपेढ्या',
      'openNow': 'आत्ता उघडे',
      'closedNow': 'आत्ता बंद',
      'hoursUnavailable': 'वेळ उपलब्ध नाही',
      'currentLocationLabel': 'सध्याचे स्थान',
      'safetyScoreLabel': 'सुरक्षा स्कोर {score}',
      'policeCountLabel': '{count} पोलीस',
      'hospitalsCountLabel': '{count} रुग्णालये',
      'pharmaciesCountLabel': '{count} फार्मसी',
      'petrolPumpsCountLabel': '{count} पेट्रोल पंप',
      'washroomsCountLabel': '{count} स्वच्छतागृहे',
      'bloodBanksCountLabel': '{count} रक्तपेढ्या',
      'toiletsCleanlinessLabel': 'स्वच्छता',
      'toiletsAvailabilityLabel': 'उपलब्धता',
      'toiletsLastUpdated': 'शेवटचे अद्यतन',
      'toiletsLastUpdatedNotAvailable': 'शेवटचे अद्यतन उपलब्ध नाही',
      'toiletsNotAvailable': 'उपलब्ध नाही',
      'toiletsStatusNotVerified': 'स्थिती सत्यापित नाही',
      'toiletsFacilityFemale': 'महिला',
      'toiletsFacilityMale': 'पुरुष',
      'toiletsFacilityAccessible': 'सुलभ',
      'toiletsFacilityWater': 'पाणी',
      'toiletsCleanlinessScore': 'स्वच्छता स्कोर',
      'toiletsCleanlinessStatus': 'स्वच्छता स्थिती',
      'toiletsAvailability': 'उपलब्धता',
      'toiletsAddress': 'पत्ता',
      'toiletsAddressNotAvailable': 'पत्ता उपलब्ध नाही',
      'toiletsFacilities': 'सुविधा',
      'impactDetectedMessage':
          'तुमचा SOS काउंटडाउन सक्रिय आहे. ही चूक असेल तर आत्ताच कृती करा.',
      'saveEmergencyContactFirst': 'आधी आपत्कालीन संपर्क जतन करा',
      'saveEmergencyContactFirstMessage':
          'कृपया आधी आपत्कालीन संपर्क जतन करा, जेणेकरून कोणत्याही आपत्कालीन परिस्थितीत तुमच्या प्रियजनांना प्रथम कळेल.',
      'sosCountdownActiveMessage':
          'SOS काउंटडाउन सक्रिय आहे. ही चूक असेल तर आत्ता रद्द करा.',
      'sosWillBeSentIn': 'SOS {seconds} सेकंदात पाठवला जाईल.',
      'screamDetected': 'किंकाळी किंवा मोठा संकट आवाज आढळला',
      'savingLastKnownLocation': 'शेवटचे ज्ञात स्थान जतन होत आहे...',
      'lastLocationSavedForHelp': 'आपत्कालीन मदतीसाठी शेवटचे स्थान जतन केले.',
      'assessmentLimited': 'मूल्यांकन मर्यादित',
      'aiConfidenceLabel': 'एआय विश्वास {score}%',
      'riskLabelVerySafe': 'खूप सुरक्षित',
      'riskLabelSafe': 'सुरक्षित',
      'riskLabelModerate': 'मध्यम जोखीम',
      'riskLabelHighRisk': 'उच्च जोखीम',
      'riskLabelCritical': 'गंभीर जोखीम',
      'riskLabelMonitoring': 'निरीक्षण',
      'riskLabelLocationOff': 'लोकेशन बंद',
      'riskLabelLearning': 'शिकत आहे',
      'statusInitializing': 'सुरक्षा मॉनिटर सुरू होत आहे...',
      'statusGpsOff':
          'GPS बंद आहे. लाइव्ह परिसर डेटासाठी लोकेशन चालू करा.',
      'statusLocationDeniedForever':
          'लोकेशन परवानगी कायमची नाकारली आहे. अॅप सेटिंग्जमध्ये सक्षम करा.',
      'statusLocationPermissionRequired':
          'रीयलटाइम सुरक्षा निरीक्षणासाठी लोकेशन परवानगी आवश्यक आहे.',
      'statusGpsConnected': 'GPS जोडले. रीयलटाइम सुरक्षा डेटा कॅप्चर होत आहे.',
      'statusFetchingIntelligence': 'परिसर सुरक्षा माहिती आणली जात आहे...',
      'statusLiveStreamPaused': 'लाइव्ह लोकेशन स्ट्रीम थांबलेली आहे.',
      'statusLiveIntelligenceActive':
          'तुमच्या परिसरासाठी लाइव्ह सुरक्षा इंटेलिजन्स सक्रिय आहे.',
      'statusNearbyServicesLoaded':
          'जवळच्या आपत्कालीन सेवा लाइव्ह नकाशा डेटामधून लोड झाल्या.',
      'statusAreaAssessedLocal':
          'परिसर सुरक्षा लाइव्ह लोकेशन आणि स्थानिक संकेतांवरून मोजली.',
      'statusCannotReachServer':
          'Suraksha सर्व्हरशी कनेक्ट होऊ शकले नाही. .env मध्ये LAN_BASE_URL तुमच्या PC IP वर सेट करा.',
      'statusLearningDailyRoute':
          'लाइव्ह GPS वरून दैनंदिन मार्ग पॅटर्न शिकत आहे.',
      'statusMapRouteCleared':
          'नकाशा मार्ग साफ. दैनंदिन मार्ग सुरक्षा सुरू आहे.',
      'statusSafetyConfirmed':
          'सुरक्षा पुष्टी. मार्ग निरीक्षण सुरू आहे.',
      'statusRouteHistoryReset':
          'मार्ग इतिहास रीसेट. शिकणे आता पुन्हा सुरू.',
      'statusSafeRouteChanged':
          'सुरक्षित मार्ग बदलला. तुम्ही सुरक्षित आहात का?',
      'statusMonitoringMapRouteTo':
          '{name} पर्यंत सर्वात सुरक्षित नकाशा मार्गाचे निरीक्षण.',
      'statusFollowingMapRoute': 'निवडलेल्या सर्वात सुरक्षित नकाशा मार्गावर.',
      'statusFollowingMapRouteTo':
          '{name} पर्यंत निवडलेल्या सर्वात सुरक्षित नकाशा मार्गावर.',
      'statusMovedAwayMapRoute':
          'तुम्ही निवडलेल्या सुरक्षित नकाशा मार्गापासून दूर गेलात. तुम्ही सुरक्षित आहात का?',
      'statusLearningTravelRoutines':
          'तुमच्या दैनंदिन प्रवास दिनक्रम शिकत आहे.',
      'statusWatchingCommutePattern':
          'ओळखीच्या प्रवास पॅटर्नचे निरीक्षण होत आहे.',
      'statusMovedAwayUsualRoute':
          'तुम्ही नेहमीच्या मार्गापासून दूर गेलात. तुम्ही सुरक्षित आहात का?',
      'statusFollowingLearnedRoute':
          'तुमच्या शिकलेल्या सुरक्षित दैनंदिन मार्गावर.',
      'statusSafetyCheckEnded':
          'सुरक्षा तपासणी संपली. मार्ग निरीक्षण सुरू आहे.',
      'statusInitializingMap': 'नकाशा सेवा सुरू होत आहेत...',
      'statusLocationServiceDisabled': 'लोकेशन सेवा बंद आहे.',
      'statusLocationPermissionDenied': 'लोकेशन परवानगी नाकारली.',
      'statusDestinationReached': 'गंतव्य गाठले',
      'statusLoadingBestRoute': 'सर्वोत्तम मार्ग लोड होत आहे...',
      'statusRoadRoutingUnavailable':
          'रस्ता मार्ग अनुपलब्ध (Maps API की गहाळ).',
      'statusRoadRouteFallback':
          'रस्ता मार्ग अनुपलब्ध, सरळ रेषा दाखवत आहोत.',
      'routeFactorSelectedMapRoute': 'निवडलेला सर्वात सुरक्षित नकाशा मार्ग',
      'routeFactorStrongCommute': 'मजबूत प्रवास पॅटर्न',
      'routeFactorRepeatedDaily': 'पुन्हा पुन्हा दैनंदिन पॅटर्न',
      'routeFactorNoMatchingRoutine':
          'या प्रवासासाठी अजून जुळणारी दिनचर्या नाही',
      'routeProgressStrongCommute':
          'मजबूत प्रवास पॅटर्न ({trips} प्रवास शिकले)',
      'routeProgressProvisional':
          'तात्पुरता पॅटर्न ({trips}/{need} प्रवास)',
      'routeProgressRecordingTrip':
          'प्रवास नोंदवत आहे · आणखी {need} GPS बिंदू हवे',
      'routeProgressTakeUsualRoute':
          'सुरक्षा पॅटर्न तयार करण्यासाठी नेहमीचा मार्ग दोनदा घ्या',
      'routeProgressSavedTrips':
          '{trips} प्रवास जतन · वेळ आणि मार्ग जुळणे आवश्यक',
      'routeProgressRoutinesWaiting':
          '{count} दिनचर्या जतन · जुळण्याची वाट',
      'routeChangedNotificationTitle': 'मार्ग बदलला — तुम्ही सुरक्षित आहात का?',
      'routeChangedNotificationBody':
          'तुम्ही नेहमीचा मार्ग सोडला. Suraksha उघडा आणि {seconds} सेकंदात मी सुरक्षित आहे टॅप करा.',
      'cyberReasonCredentialRequest': 'संवेदनशील क्रेडेन्शियल विनंती आढळली.',
      'cyberReasonPaymentPressure':
          'पेमेंट किंवा खाते दबाव संकेत आढळले.',
      'cyberReasonBlackmail': 'ब्लॅकमेल/खंडणी संकेत आढळले.',
      'cyberThreatNoIndicators': 'कोणतेही मजबूत स्थानिक संकेत आढळले नाहीत.',
      'cyberActionNoOtp': 'OTP/पासवर्ड शेअर करू नका',
      'cyberActionSaveEvidence': 'पुरावे जतन करा',
      'cyberActionVerifyOfficial': 'अधिकृत स्रोताकडून पडताळा',
      'cyberTipNeverPayBlackmail': 'ब्लॅकमेलर्सना कधीही पैसे देऊ नका',
      'cyberTipReport1930': 'आर्थिक फसवणूक 1930 वर नोंदवा',
      'cyberTipBlockSenders': 'संशयास्पद पाठवणारे ब्लॉक करा',
      'cyberRiskHigh': 'उच्च',
      'cyberRiskMedium': 'मध्यम',
      'cyberRiskLow': 'कमी',
      'learnPasswordTitle': 'पासवर्ड सुरक्षा',
      'learnPasswordSummary':
          'मजबूत पासवर्ड तयार करा आणि रिकव्हरी चॅनेल सुरक्षित ठेवा.',
      'learnPasswordTip1': 'पासवर्ड व्यवस्थापक वापरा.',
      'learnPasswordTip2': 'दोन-घटक प्रमाणीकरण सक्षम करा.',
      'learnPasswordTip3': 'पासवर्ड पुन्हा वापरू नका.',
      'learnPasswordQuiz': 'पासवर्ड पुन्हा वापरणे सुरक्षित आहे का?',
      'learnDatingTitle': 'ऑनलाइन डेटिंग सुरक्षा',
      'learnDatingSummary':
          'जबरदस्ती, बनावट ओळख आणि प्रतिमा-आधारित गैरवापर ओळखा.',
      'learnDatingTip1': 'व्हिडिओने काळजीपूर्वक पडताळा.',
      'learnDatingTip2': 'अंतरंग मीडिया शेअर करू नका.',
      'learnDatingTip3': 'फक्त सार्वजनिक ठिकाणी भेटा.',
      'learnDatingQuiz':
          'नव्या ऑनलाइन मॅचला पैसे पाठवावेत का?',
      'learnQuizNo': 'नाही',
      'learnQuizYes': 'होय',
      'deepfakeTitle': 'डीपफेक आणि मॉर्फ्ड प्रतिमा आपत्कालीन मदत',
      'deepfakeSectionWhatTitle': 'डीपफेक म्हणजे काय?',
      'deepfakeSectionWhatBody':
          'हाताळलेले मीडिया जे व्यक्तीला बनावट फोटो, ऑडिओ किंवा व्हिडिओमध्ये चुकीचे दाखवू शकते.',
      'deepfakeSectionDoTitle': 'ताबडतोब काय करावे',
      'deepfakeSectionDoBody':
          'स्क्रीनशॉट, URL आणि पाठवणारा ID जतन करा. पैसे देऊ नका किंवा वाटाघाट करू नका. cybercrime.gov.in वर नोंदवा.',
      'deepfakeSectionEvidenceTitle': 'पुरावा जतन',
      'deepfakeSectionEvidenceBody':
          'मूळ फाइल्स, वेळचिन्हे, प्लॅटफॉर्म लिंक्स आणि व्यवहार तपशील ठेवा.',
      'helplineCyberCrime': 'सायबर क्राइम हेल्पलाइन',
      'helplinePoliceEmergency': 'पोलीस आपत्कालीन',
      'notAvailableShort': 'उपलब्ध नाही',
      'contributingFactorsTitle': 'योगदान देणारे घटक',
      'recommendedActionsTitle': 'शिफारस केलेल्या कृती',
      'priorityCritical': 'गंभीर',
      'priorityCaution': 'सावधानी',
      'priorityInfo': 'माहिती',
      'timeJustNow': 'आत्ताच',
      'timeMinutesAgo': '{count} मि पूर्वी',
      'timeHoursAgo': '{count} ता पूर्वी',
      'timeDaysAgo': '{count} दि पूर्वी',
      'alertCategoryUpcomingRisk': 'आगामी जोखीम क्षेत्र',
      'alertCategoryVerifiedIncident': 'सत्यापित घटना अहवाल',
      'alertCategoryAreaIncidentStatus': 'परिसर घटना स्थिती',
      'alertCategoryRoadLighting': 'रस्ता प्रकाश',
      'alertCategoryCrowdActivity': 'गर्दीची हालचाल',
      'alertCategoryGridRisk': 'ग्रिड जोखीम मॉडेल',
      'alertCategoryDistrictCrime': 'जिल्हा गुन्हा संदर्भ',
      'alertCategoryEmergencyInfra': 'आपत्कालीन पायाभूत सुविधा',
      'alertCategoryCommunitySafeRoute': 'समुदाय सुरक्षित मार्ग',
      'alertCategoryAreaSafety': 'परिसर सुरक्षा',
      'alertCategoryPublicTransport': 'सार्वजनिक वाहतूक',
      'alertCategoryPublicTransportNetwork': 'सार्वजनिक वाहतूक नेटवर्क',
      'alertCategoryPedestrianActivity': 'पादचारी हालचाल',
      'alertCategoryRegionNotice': 'परिसर सूचना',
      'alertSummaryUpcomingRisk': 'पुढे वाढलेली जोखीम अपेक्षित आहे.',
      'alertActionUpcomingRisk':
          'गती कमी करा, सजग राहा आणि पर्यायी मार्ग विचारा.',
      'alertSummaryIncidentCategory':
          '{region} मध्ये जवळ {category} अहवाल नोंदवला.',
      'alertSummaryIncidentGeneric':
          'जवळ अलीकडील सत्यापित घटना नोंदवली.',
      'alertActionVerifiedIncident':
          'सामान जवळ ठेवा, एकट्या ठिकाणी फोन वापर टाळा आणि सजग राहा.',
      'alertDisclaimerSurakshaReports':
          'सत्यापित Suraksha वापरकर्ता अहवालांवर आधारित. अधिकृत पोलीस नोंदी नाहीत.',
      'alertSummaryNoIncidents':
          '{region} मध्ये या स्थानाजवळ गेल्या ७२ तासांत कोणताही सत्यापित Suraksha घटना अहवाल नाही.',
      'alertActionNoIncidents':
          'जवळ अलीकडील अॅप-अहवाल घटना नाहीत. निरीक्षण सुरू ठेवा आणि कमी वाहतूक क्षेत्रांत सजग राहा.',
      'alertDisclaimerNoIncidents':
          'अॅप अहवाल नसणे शून्य गुन्ह्याची हमी नाही. अधिकृत डेटा वेगळा असू शकतो.',
      'alertSunsetCivilTwilight': 'नागरी संध्याकाळानंतर',
      'alertSunsetNightHours': 'रात्रीच्या वेळेत',
      'alertSummaryUnlitNearby':
          'OpenStreetMap {meters} मी मध्ये प्रकाश नसलेले रस्ते दाखवतो. स्थिती {sunset} आहे.',
      'alertSummaryMostlyLit':
          'OpenStreetMap प्रकाश टॅग जवळ बहुतेक प्रकाशित मार्ग सुचवतात. तरीही दृश्यता कमी आहे {sunset}.',
      'alertSummaryDarkLimited':
          '{region} मध्ये अंधार आहे. या भागासाठी रस्ता प्रकाश डेटा मर्यादित आहे.',
      'alertActionRoadLighting':
          'प्रकाशित मुख्य रस्त्यांवर राहा. गरज असल्यास टॉर्च वापरा आणि सावली मार्ग टाळा.',
      'alertDisclaimerLighting':
          'सूर्यास्त वेळेवरून अंदाजित प्रकाश. OSM रस्ता प्रकाश टॅग अपूर्ण असू शकतात.',
      'alertSummaryCrowdHigh':
          'जवळ उच्च अनामिक अॅप हालचाल ({pings} पिंग, २ तास, {cells} सेल).',
      'alertSummaryCrowdModerate':
          'जवळ मध्यम अनामिक अॅप हालचाल ({pings} पिंग, २ तास).',
      'alertSummaryCrowdVeryLow':
          'गेल्या २ तासांत जवळ खूप कमी अनामिक अॅप हालचाल.',
      'alertSummaryCrowdLow':
          'जवळ कमी अनामिक अॅप हालचाल ({pings} पिंग, २ तास).',
      'alertActionCrowdVeryLowDark':
          'जवळ कमी लोक असू शकतात. गर्दीचे, प्रकाशित मार्ग निवडा.',
      'alertActionCrowdGeneral':
          'गर्दी पॅटर्न अनेक संकेतांपैकी एक आहे—परिस्थितीबाबत सजग राहा.',
      'alertDisclaimerCrowd':
          'अनामिक Suraksha अॅप हालचाल पिंगवर आधारित—लाइव्ह फुटफॉल सेन्सर नाही.',
      'alertSummaryGridRisk':
          'या ~१ किमी ग्रिडसाठी {label} (३० दिवसांत {count30d} घटना, ७ दिवसांत {count7d}).',
      'alertActionGridElevated':
          'या ग्रिडमध्ये ऐतिहासिक घटना पॅटर्न उच्च आहेत—सजग राहा आणि मुख्य रस्ते निवडा.',
      'alertActionGridModerate':
          'ग्रिड इतिहास मध्यम आहे. लाइव्ह अलर्ट निरीक्षण सुरू ठेवा.',
      'alertDisclaimerGrid':
          'ऐतिहासिक घटना पॅटर्नवर आधारित सांख्यिकीय ग्रिड मॉडेल.',
      'alertSummaryDistrictCrime':
          'नाशिक जिल्हा ओपन-डेटा संदर्भ ({period}): प्रति १००क लोकसंख्येमागे ~{rate} नोंदवलेल्या घटना. फक्त परिसर-स्तरीय संदर्भ.',
      'alertActionDistrictCrime':
          'हे प्रादेशिक पार्श्वभूमी म्हणून वापरा—तुमच्या अचूक स्थानाचा लाइव्ह गुन्हा अलर्ट नाही.',
      'alertDisclaimerDistrictCrime': 'फक्त जिल्हा-स्तरीय ओपन डेटा संदर्भ.',
      'alertSummaryEmergencyInfra':
          'जवळची मदत स्कॅन: {police} पोलीस, {hospitals} रुग्णालय/क्लिनिक, आणि {fuel} इंधन स्टेशन सुविधा तुमच्या {radius} किमी मध्ये.',
      'alertActionEmergencySparse':
          'येथे आपत्कालीन मदत कमी आहे. SOS तयार ठेवा आणि लाइव्ह लोकेशन शेअर करा.',
      'alertActionEmergencyAvailable':
          'नकाशावरील आपत्कालीन पायाभूत सुविधा जवळ उपलब्ध आहेत.',
      'alertDisclaimerEmergencyInfra':
          'OSM, Google Places आणि Suraksha प्राधिकरण मॅपिंगमधून एकत्र. उपलब्धता बदलू शकते.',
      'alertSummaryEmergencyLimited':
          'नाशिकमध्ये या स्थानाजवळ मर्यादित नकाशा पोलीस, रुग्णालय किंवा प्रतिसादक कव्हरेज.',
      'alertActionEmergencyLimited':
          'SOS तयार ठेवा. पुढे जाण्यापूर्वी आपत्कालीन संपर्काला तुमचे स्थान सांगा.',
      'alertDisclaimerEmergencyLimited':
          'Suraksha + OpenStreetMap कव्हरेजवरून. सर्व सुविधा सूचीबद्ध नसू शकतात.',
      'alertSummarySafeCorridor':
          'तुमच्या मार्गाजवळ {count} समुदाय-सत्यापित सुरक्षित मार्ग.',
      'alertActionSafeCorridor':
          'हायलाइट समुदाय-सत्यापित मार्गासाठी सुरक्षा नकाशा उघडा.',
      'alertActionAreaHighRisk':
          'SOS सक्रिय करा, विश्वासू संपर्कासोबत लाइव्ह लोकेशन शेअर करा आणि पर्यायी मार्ग विचारा.',
      'alertActionAreaReview':
          'खालील कारणे पहा आणि शिफारस केलेल्या कृती करा.',
      'alertActionAreaManageable':
          'स्थिती हाताळण्यायोग्य वाटते. जवळचे अपडेट निरीक्षण सुरू ठेवा.',
      'alertActionAreaStayAlert':
          'सजग राहा, लाइव्ह लोकेशन शेअर करा आणि SOS तयार ठेवा.',
      'alertActionAreaSafe':
          'कोणतेही मजबूत जोखीम संकेत नाहीत. सामान्य सजगता सुरू ठेवा.',
      'alertSummaryAreaSafeVerified':
          'लाइव्ह संकेतांवरून हा परिसर सध्या सुरक्षित वाटतो.',
      'alertSummaryPublicTransport':
          'ऑटो रिक्षा, MSRTC बस आणि टॅक्सी सामान्यतः नाशिकच्या मुख्य मार्गांवर चालतात. उपलब्धता वेळ आणि मार्गानुसार बदलते.',
      'alertActionPublicTransport':
          'ऑटो, बस किंवा टॅक्सीसाठी मुख्य रस्ते आणि गर्दीचे चौक वापरा.',
      'alertDisclaimerPublicTransport':
          'सामान्य नाशिक वाहतूक मार्गदर्शन—लाइव्ह ट्रान्झिट API डेटा नाही. सध्याची सेवा स्थानिक तपासा.',
      'alertSummaryPublicTransportNetwork':
          'तुमच्या सध्याच्या स्थानाभोवती ऑटो रिक्षा, बस, टॅक्सी आणि इतर स्थानिक वाहतूक उपलब्ध आहे.',
      'alertActionPublicTransportNetwork':
          'सर्वात जलद पिकअपसाठी मुख्य रस्ता किंवा गर्दीच्या चौकात जा.',
      'alertSummaryLightingLateNight':
          'मध्यरात्रीनंतर तुमच्या परिसरात रस्ते कमी प्रकाशित असू शकतात.',
      'alertSummaryLightingEvening':
          'संध्याकाळी ७ नंतर दृश्यता कमी. जवळ रस्ता प्रकाश असंगत असू शकतो.',
      'alertSummaryPedestrianLateNight':
          'मध्यरात्रीनंतर या परिसरात खूप कमी पादचारी हालचाल अपेक्षित.',
      'alertSummaryPedestrianNight':
          'या मार्गिकात रात्री ८ नंतर पादचारी वाहतूक सामान्यतः कमी होते.',
      'alertSummaryPedestrianDay':
          'दिवसा तुमच्या जवळ सामान्य पादचारी हालचाल अपेक्षित.',
      'alertActionPedestrianNight':
          'एकटे मार्ग टाळा आणि जिथे लोक दिसतात तिथे राहा.',
      'alertActionPedestrianDay':
          'परिसर हालचाल सामान्य वाटते. मानक खबरदारी सुरू ठेवा.',
      'alertSummaryOutsideRegion':
          'टप्पा १ सुरक्षा इंटेलिजन्स {region} साठी अनुकूलित आहे. तुम्ही नकाशा क्षेत्राबाहेर दिसता—काही संकेत मर्यादित असू शकतात.',
      'alertActionOutsideRegion':
          'पूर्ण OSM, गर्दी आणि घटना फ्युजन कव्हरेजसाठी नाशिकमध्ये राहा.',
      'alertDisclaimerNashik':
          'नाशिक परिसरासाठी सुरक्षा इंटेलिजन्स. संकेत अपूर्ण असू शकतात.',
      'alertReasonSeriousViolentCrime':
          'जवळ गंभीर हिंसक गुन्हा नोंदवला आहे.',
      'alertReasonCrimeSignalsElevated':
          'या स्थानाजवळ गुन्हा-संबंधित संकेत उच्च आहेत.',
      'safetyReasonSupportNearby':
          'जवळपास विश्वासार्ह आपत्कालीन मदत उपलब्ध आहे.',
      'safetyReasonPlentyEmergencyServices':
          'या परिसरात पुरेशा आपत्कालीन सेवा उपलब्ध आहेत.',
      'safetyReasonNoCrimesReported':
          'सध्या या परिसरात कोणतेही गुन्हे नोंदवलेले नाहीत.',
      'safetyReasonGoodDaytimeFootfall':
          'जवळच्या रस्त्यांवर मोठ्या प्रमाणात गर्दी आणि हालचाल आहे, म्हणून दिवसा हा परिसर सुरक्षित वाटतो.',
      'safetyReasonRegisteredMurder':
          'या परिसरात नोंदवलेले खून प्रकरण अहवाली आहेत.',
      'safetyReasonRegisteredHalfMurder':
          'या परिसरात नोंदवलेले हाफ मर्डर किंवा खूनाचा प्रयत्न प्रकरण अहवाली आहेत.',
      'safetyReasonRegisteredDrug':
          'या परिसरात नोंदवलेली अमली पदार्थ संबंधित प्रकरणे अहवाली आहेत.',
      'safetyReasonRegisteredRobbery':
          'या परिसरात नोंदवलेली दरोडा प्रकरणे अहवाली आहेत.',
      'safetyReasonRegisteredTheft':
          'या परिसरात नोंदवलेली चोरी प्रकरणे अहवाली आहेत.',
      'safetyReasonRegisteredChainSnatching':
          'या परिसरात नोंदवलेली चेन-स्नॅचिंग प्रकरणे अहवाली आहेत.',
      'safetyReasonRegisteredAssault':
          'या परिसरात नोंदवलेले हल्ला किंवा छळ प्रकरण अहवाली आहेत.',
      'safetyReasonNightTraffic':
          'रस्ता वाहतूक आणि हालचाली नमुने संध्याकाळी ७ नंतर अतिरिक्त सावधानी दर्शवतात.',
      'safetyReasonNormalFootfall':
          'सामान्य पादचारी हालचालीमुळे परिसर एकटा नाही असे वाटते.',
      'safetyReasonGoodLighting':
          'या परिसरात प्रकाश आणि पायाभूत सुविधा स्थिर दिसतात.',
      'safetyReasonLowRiskSignals':
          'सध्या कोणतेही मजबूत जोखीम संकेत दिसत नाहीत.',
      'safetyReasonDrugActivity':
          'या परिसरात अलीकडे अमली पदार्थ संबंधित कृती नोंदवल्या गेल्या आहेत.',
      'safetyReasonChainSnatching':
          'जवळपास chain-snatching प्रकरणे नोंदवली गेली आहेत.',
      'safetyReasonTheftProne':
          'हा भाग चोरी संबंधित घटनांसाठी ओळखला जातो.',
      'safetyReasonHarassmentReports':
          'जवळपास छळ किंवा हल्ल्याच्या तक्रारी नोंदवल्या गेल्या आहेत.',
      'safetyReasonPoorLighting':
          'खराब रस्ता प्रकाशामुळे येथे दृश्यता कमी होऊ शकते.',
      'safetyReasonLowFootfall':
          'कमी पादचारी वाहतुकीमुळे हा परिसर एकटा वाटू शकतो.',
      'safetyReasonCrimeActivity':
          'जवळपासच्या घटना अजूनही वाढलेल्या आहेत.',
      'safetyReasonLimitedSupport':
          'जवळपास मर्यादित आपत्कालीन मदत बिंदू त्वरित मदतीस विलंब करू शकतात.',
      'safetyReasonNightRisk':
          'रात्रीच्या वेळी दृश्यता आणि सार्वजनिक हालचाल कमी होते.',
      'safetyReasonGpsLimited':
          'लाइव्ह स्थान अचूकता मर्यादित आहे; GPS सुधारल्यावर मूल्यांकन अद्यतन होऊ शकते.',
      'safetyReasonUnsafeNightlife':
          'असुरक्षित नाइटलाइफ किंवा red-light कृती येथे धोका वाढवू शकते.',
      'safetyReasonGeneralCaution':
          'या परिसरात अतिरिक्त सावधानी घेण्याची शिफारस आहे.',
      'safetyReasonLimitedData':
          'सत्यापित लाइव्ह परिसर डेटा मर्यादित आहे — येथे अतिरिक्त सजग राहा.',
      'routeVerdictChanged': 'मार्ग बदलला',
      'routeVerdictChangedSummary':
          'तुम्ही नेहमीच्या मार्गापासून वळला आहात. तुम्ही सुरक्षित आहात याची खात्री करा.',
      'routeVerdictLearning': 'मार्ग शिकत आहे',
      'routeVerdictLearningSummary':
          'दैनंदिन मार्ग सुरक्षा तुमचे प्रवास पॅटर्न लाइव्ह GPS वरून शिकत आहे.',
      'routeVerdictOnTrack': 'नेहमीच्या मार्गावर',
      'routeVerdictOnTrackSummary':
          'तुम्ही तुमच्या शिकलेल्या सुरक्षित दैनंदिन मार्गावर आहात.',
      'routeVerdictCaution': 'मार्ग सावधानी',
      'routeVerdictCautionSummary':
          'काही मार्ग परिस्थितींवर आता अतिरिक्त लक्ष देणे आवश्यक आहे.',
      'routeVerdictAlert': 'मार्ग सतर्कता',
      'routeVerdictAlertSummary':
          'तुमचा सध्याचा मार्ग तुमच्या नेहमीच्या सुरक्षित पॅटर्नशी जुळत नाही.',
      'refresh': 'रीफ्रेश',
      'openMap': 'नकाशा उघडा',
      'resetHomeWorkplaceRouteLearning': 'घर-कार्यस्थळ मार्ग शिकणे रीसेट करा',
      'homeWorkplaceRouteLearningReset': 'घर-कार्यस्थळ मार्ग शिकणे रीसेट झाले.',
      'safetyCheckEndsIn': 'सुरक्षा तपासणी इतक्यात संपेल',
      'unlessYouConfirm': 'जोपर्यंत तुम्ही पुष्टी करत नाही.',
      'imSafe': 'मी सुरक्षित आहे',
      'routeGuardNeedHelp': 'मदत हवी',
      'statusRouteGuardEscalated':
          'सुरक्षा पुष्टी मिळाली नाही. आपत्कालीन SOS सुरू केले.',
      'statusRouteGuardHelpRequested':
          'मार्ग रक्षकातून आपत्कालीन SOS सुरू केले.',
      'pleaseFillAllRequiredDetails': 'कृपया सर्व आवश्यक तपशील भरा.',
      'complaintSubmittedSuccessfully': 'तक्रार यशस्वीरित्या सबमिट केली.',
      'submissionFailedTryAgain':
          'सबमिशन अयशस्वी झाले. कृपया पुन्हा प्रयत्न करा.',
      'openDetailedPoshActGuide': 'तपशीलवार POSH कायदा मार्गदर्शक उघडा',
      'clearPreviousQuizToUnlockThisLevel':
          'हा स्तर अनलॉक करण्यासाठी मागील क्विझ साफ करा.',
      'previous': 'मागील',
      'retryQuiz': 'क्विझ पुन्हा प्रयत्न करा',
      'pleaseAnswerEveryQuestionFirst':
          'कृपया आधी प्रत्येक प्रश्नाचे उत्तर द्या.',
      'pleaseAnswerThisQuestionBeforeContinuing':
          'कृपया पुढे जाण्यापूर्वी या प्रश्नाचे उत्तर द्या.',
      'currentLevel': 'सध्याचा स्तर',
      'detailedPoshActGuide': 'तपशीलवार POSH कायदा मार्गदर्शक',
      'cyberLawHubTitle': 'सायबर गुन्हे कायदा ग्रंथालय',
      'cyberLawDeepfakeFullGuide': 'संपूर्ण डीपफेक कायदेशीर मार्गदर्शन',
      'cyberLawHubSubtitle': 'आपले हक्क जाणा. कायदा जाणा. लढायला शिका.',
      'cyberLawHelplineTitle': 'आपातकालीन हेल्पलाइन',
      'cyberLawHelplineDesc': 'सायबर क्राइम: 1930  |  महिला: 181  |  बाल: 1098  |  पोलिस: 112',
      'cyberLawOverviewHeader': 'आढावा',
      'cyberLawActsHeader': 'लागू कायदे व कलमे',
      'cyberLawPunishmentHeader': 'कायदेशीर शिक्षा',
      'cyberLawWhatToDoHeader': 'तुम्ही पीडित असाल तर काय करावे',
      'cyberLawReportHeader': 'तक्रार कुठे करावी',
      'authEnterEmailPhonePassword': 'कृपया ईमेल/फोन आणि पासवर्ड प्रविष्ट करा.',
      'authLoginFailed': 'लॉगिन अयशस्वी. पुन्हा प्रयत्न करा.',
      'authVerificationFailed': 'पडताळणी अयशस्वी. पुन्हा प्रयत्न करा.',
      'authFillRequiredFields':
          'कृपया सर्व आवश्यक फील्ड भरा (पासवर्ड किमान 8 अक्षरे).',
      'authSignupFailed': 'साइन अप अयशस्वी. पुन्हा प्रयत्न करा.',
      'logoutBeforeNewSignup':
          'नवीन खाते तयार करण्यापूर्वी सध्याच्या खात्यातून लॉग आउट करा.',
      'authPasswordMinLength': 'पासवर्ड किमान 8 अक्षरे असावा.',
      'authResetPasswordFailed': 'पासवर्ड रीसेट करता आला नाही. पुन्हा प्रयत्न करा.',
      'authRequestTimedOut':
          'विनंती वेळ संपली. कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.\nसर्वर: {server}',
      'authCouldNotReachServer':
          'सर्वर {server} पर्यंत पोहोचता आले नाही. बॅकएंड चालू आहे याची खात्री करा.',
      'networkRequestFailed': 'नेटवर्क विनंती अयशस्वी',
      'invalidDetails': 'अवैध तपशील.',
      'networkRequestTimedOut': 'विनंती वेळ संपली. पुन्हा प्रयत्न करा.',
      'profileUserNamePlaceholder': 'वापरकर्ता नाव',
      'profileEmailPlaceholder': 'email@example.com',
      'emergencyContactDefault': 'आपत्कालीन संपर्क',
      'routeGuardMetersFromPattern': 'पॅटर्नपासून {meters} मी',
      'routeGuardMapPoints': '{count} नकाशा बिंदू',
      'routeGuardRouteLogs': '{count} मार्ग लॉग',
      'countdownMinutesSeconds': '{minutes}मि {seconds}से',
      'distressPhraseDetected': 'संकट वाक्य ओळखले',
      'distressMatchedPhrase': 'जुळले: {phrase}',
      'distressScreamConfidence': 'किंकाळी विश्वास: {percent}%',
      'emergencyFetchingLocation': 'स्थान मिळवत आहे...',
      'emergencyLiveFeedActive': 'लाइव्ह फीड सक्रिय ({time})',
      'emergencyLiveTransmissionStarting': 'लाइव्ह प्रसारण सुरू होत आहे...',
      'emergencyLiveTransmissionPaused': 'लाइव्ह प्रसारण थांबवले',
      'dashboardSosLabel': 'SOS',
      'a11yOpenEmergencyMode': 'आपत्कालीन मोड उघडा. SOS सक्रिय आहे.',
      'a11ySendMessage': 'संदेश पाठवा',
      'mapHeatmapLegend':
          'रंगीत नकाशा क्षेत्र सापेक्ष जोखीम दाखवतात. फक्त रंग नव्हे — खाली स्कोर, जोखीम लेबल आणि घटक पहा.',
      'featureUnavailable': 'ही सुविधा सध्या उपलब्ध नाही.',
      'featureFlagDisabledHint': 'या बिल्डमध्ये ही क्षमता बंद आहे.',
      'partialDeliveryBanner':
          'अंशतः यशस्वी: काही आपत्कालीन सूचना पोहोचल्या.',
      'dashboardPoshLabel': 'POSH',
      'communityAlertStayAwareFallback':
          'नकाशावर जवळपासची परिस्थिती पहा आणि हलताना सजग राहा.',
      'poshQuizStudySubtitle':
          'प्रथम संपूर्ण माहिती वाचा, नंतर प्रमाणपत्रासाठी तीन क्विझ स्तर पूर्ण करा.',
      'poshQuizAllLevelsCleared': 'सर्व स्तर पूर्ण. तुमचे प्रमाणपत्र तयार आहे.',
      'poshQuizQuestionsCount': '{count} प्रश्न',
      'poshQuizMixedMcq': 'मिश्र MCQ',
      'poshQuizSingleChoice': 'एक पर्याय',
      'poshQuizQuestionProgress': 'प्रश्न {current} / {total}',
      'poshQuizAnsweredCount': '{count} उत्तरे दिली',
      'poshQuizCertificateEarned':
          'तुम्ही तीनही क्विझ स्तर पूर्ण करून प्रमाणपत्र मिळवले.',
      'poshQuizNextLevelUnlocked': 'उत्तम. पुढील स्तर आता अनलॉक झाला.',
      'poshQuizReviewScore':
          'तुमचा स्कोअर {score}/{total}. अभ्यास विभाग पहा आणि हा स्तर पुन्हा करा.',
      'poshComplaintTimedOut': 'तक्रार विनंती वेळ संपली. पुन्हा प्रयत्न करा.',
      'poshComplaintNetworkUnavailable':
          'नेटवर्क उपलब्ध नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.',
      'poshComplaintSessionExpired':
          'सत्र संपले. तक्रार सबमिट करण्यासाठी पुन्हा साइन इन करा.',
      'poshComplaintTitle': 'POSH कार्यस्थळ तक्रार',
      'poshComplaintComplainant': 'तक्रारदार: {name}',
      'poshComplaintPhone': 'फोन: {phone}',
      'poshComplaintEmail': 'ईमेल: {email}',
      'poshComplaintAccused': 'आरोपी: {name}',
      'poshComplaintWorkplace': 'कार्यस्थळ: {name}',
      'poshComplaintIncidentDate': 'घटना तारीख: {date}',
      'poshComplaintIncidentLocation': 'घटना स्थान: {location}',
      'poshComplaintWitnesses': 'साक्षीदार: {witnesses}',
      'poshComplaintDetails': 'तक्रार तपशील: {details}',
      'cyberNoSummaryAvailable': 'सारांश उपलब्ध नाही.',
      'cyberReportGenerated': 'अहवाल तयार झाला.',
      'cyberReportDefaultTitle': 'सायबर अहवाल',
      'cyberReportedStatus': 'नोंदवले',
      'cyberEvidenceLabel': 'पुरावा',
      'cyberOtherCategory': 'इतर',
      'cyberDeepfakeAwareness': 'डीपफेक जागरूकता',
      'cyberHelpline': 'हेल्पलाइन',
      'cyberInformation': 'माहिती',
      'cyberShareComplaintSubject': 'सुरक्षा सायबर गुन्हा तक्रार',
      'cyberShareComplaintBody': 'सुरक्षा द्वारे तयार सायबर गुन्हा PDF.',
      'cyberShareEvidenceSubject': 'सुरक्षा सायबर पुरावा',
      'cyberShareEvidenceBody': 'सुरक्षा वरून निर्यात सायबर पुरावा.',
      'cyberSharePackageSubject': 'सुरक्षा पुरावा पॅकेज',
      'cyberSharePackageBody': 'सुरक्षा वॉल्टमधून निर्यात पुरावा पॅकेज.',
      'medicalDefaultBloodGroup': 'O पॉझिटिव',
      'medicalDefaultAllergies': 'शेंगदाणे, पेनिसिलिन',
      'medicalDefaultConditions': 'दमा',
      'medicalDefaultMedications': 'इनहेलर (गरजेनुसार)',
      'mapInitializingServices': 'नकाशा सेवा सुरू होत आहेत...',
      'mapLocationServiceDisabled': 'स्थान सेवा बंद आहे.',
      'mapLocationPermissionDenied': 'स्थान परवानगी नाकारली.',
      'mapUpcomingElevatedRisk': 'येणारा वाढलेला धोका',
      'mapLoadingBestRoute': 'सर्वोत्तम मार्ग लोड होत आहे...',
      'mapRoadRoutingUnavailable': 'रस्ता मार्ग उपलब्ध नाही (Maps API key नाही).',
      'mapNearbyServicesPartialIssues':
          'जवळच्या सेवा अंशतः लोड झाल्या: {errors}',
      'mapNearbyServicesLoadFailed':
          'जवळच्या सेवा लोड करता आल्या नाहीत. पुन्हा प्रयत्न करा.',
      'mapPoliceStationFallback': 'पोलीस स्टेशन',
      'mapPoliceStationsLabel': 'पोलीस स्टेशने',
      'mapHospitalsLabel': 'रुग्णालये',
      'mapSelectedDestinationFallback': 'निवडलेले गंतव्य',
      'mapDirectFallbackRouteReason': 'Google रूटिंगशिवाय थेट फॉलबॅक मार्ग',
      'nearbyGpsUnavailable': 'लाइव्ह GPS उपलब्ध नाही. स्थान ON ठेवा.',
      'nearbyGoogleMapsKeyMissing':
          'जवळची ठिकाणे उपलब्ध नाहीत. Suraksha बॅकएंडवर GOOGLE_MAPS_API_KEY सेट करा.',
      'nearbyPlacesApiError': 'Places API त्रुटी: {status}',
      'nearbyUnnamedPlace': 'अनाम स्थान',
      'nearbyAddressUnavailable': 'पत्ता उपलब्ध नाही',
      'nearbyFetchFailed': 'आत्ता जवळची ठिकाणे लोड करता आली नाहीत. पुन्हा प्रयत्न करा.',
      'safetyEmergencyServicesWithin1Km': '1 किमी मध्ये आपत्कालीन सेवा',
      'distressMonitorNotificationTitle': 'सुरक्षा संकट मॉनिटर सक्रिय',
      'distressMonitorNotificationText':
          'ऑफलाइन किंकाळी आणि मदत वाक्य ऐकत आहे.',
      'distressMonitorTestModeNotification': 'चाचणी मोड — SOS पाठवला जाणार नाही.',
      'smsLastKnownLocation': 'शेवटचे ज्ञात स्थान: {url}',
      'smsTrackLiveLocation': 'लाइव्ह स्थान ट्रॅक करा: {url}',
      'sosActivatedSmsPermissionNeeded':
          'SOS सक्रिय. आपत्कालीन संपर्कांना सूचित करण्यासाठी SMS परवानगी हवी.',
      'sosRealtimeConnectionFailed':
          'रीअलटाइम कनेक्शन अयशस्वी. SOS जतन झाला; संपर्कांना सूचना मिळू शकते.',
      'sosMicrophonePermissionNeeded': 'किंकाळी ओळखीसाठी मायक्रोफोन परवानगी हवी.',
      'communityAlertGoogleMapsKeyMissing': 'Google Maps API key नाही.',
      'communityAlertLoadFailed': 'आत्ता लाइव्ह समुदाय सूचना लोड करता आल्या नाहीत.',
      'communityAlertTrafficDataLimited': 'जवळपास ट्रॅफिक डेटा मर्यादित',
      'communityAlertTrafficSampleFailed':
          'Google Maps वरून जवळचे ड्रायव्हिंग मार्ग नमुना घेता आले नाहीत.',
      'communityAlertHeavyTraffic': 'तुमच्या जवळ जड ट्रॅफिक',
      'communityAlertHeavyTrafficDetail':
          'Google Maps जवळच्या मार्गांवर सामान्यपेक्षा हळू वेळ दाखवतो.',
      'communityAlertTrafficNormal': 'जवळपास ट्रॅफिक सामान्य दिसतो',
      'communityAlertTrafficNormalDetail':
          'नमुना मार्गांवर वेळ या वेळेसाठी सामान्य दिसतो.',
      'communityAlertRouteBlockage': 'संभाव्य रस्ता अडथळा किंवा डिटूर',
      'communityAlertRouteBlockageDetail':
          'काही मार्गांवर असामान्य विलंब — अडथळा शक्य.',
      'communityAlertTransportAvailable': 'सार्वजनिक वाहतूक उपलब्ध',
      'communityAlertTransportAvailableDetail':
          'तुमच्या जवळ बस थांबे, मेट्रो किंवा रेल्वे स्टेशन सापडले.',
      'communityAlertLowActivity': 'कमी हालचालीचा परिसर',
      'communityAlertLowActivityDetail':
          'तुमच्या सभोवताल आत्ता कमी सार्वजनिक ठिकाणे सक्रिय आहेत.',
      'communityAlertSilentZone': 'जवळ शांत क्षेत्र संदर्भ',
      'communityAlertSilentZoneDetail':
          'तुमच्या सभोवताल {count} रुग्णालये, शाळा किंवा न्यायालये सापडली.',
      'communityAlertLightingStrong': 'जवळ प्रकाश मजबूत दिसतो',
      'communityAlertLightingStrongDetail':
          'या परिसरात रस्ता/सार्वजनिक प्रकाश संकेत मजबूत आहेत.',
      'communityAlertLightingModerate': 'जवळ प्रकाश मध्यम दिसतो',
      'communityAlertLightingModerateDetail':
          'प्रकाश मध्यम आहे; रात्री सजग राहा.',
      'communityAlertLightingLimited': 'जवळ प्रकाश मर्यादित असू शकतो',
      'communityAlertLightingCoverageLimited': 'प्रकाश कव्हरेज मर्यादित दिसते',
      'communityAlertLightingLimitedDetail':
          'मर्यादित प्रकाश — रात्री अतिरिक्त काळजी घ्या.',
      'communityAlertJustNow': 'आत्ताच',
      'communityAlertMinsAgo': '{minutes} मिनिटांपूर्वी',
      'communityAlertHoursAgo': '{hours} तासांपूर्वी',
    },
  };

  String t(String key) {
    final langCode = _languageCodeFor(locale);
    return _values[langCode]?[key] ?? _values['en']![key] ?? key;
  }

  /// Maps API / internal risk labels (English) to the active language.
  String localizeRiskLabel(String? label) {
    final text = label?.trim() ?? '';
    if (text.isEmpty) return t('riskLabelMonitoring');
    // Already a known l10n key.
    if (_values['en']!.containsKey(text)) return t(text);

    final lower = text.toLowerCase();
    if (lower.contains('location off')) return t('riskLabelLocationOff');
    if (lower.contains('very safe')) return t('riskLabelVerySafe');
    if (lower.contains('critical')) return t('riskLabelCritical');
    if (lower.contains('high risk') || lower.contains('high alert')) {
      return t('riskLabelHighRisk');
    }
    if (lower.contains('moderate') ||
        lower.contains('caution') ||
        lower.contains('mixed')) {
      return t('riskLabelModerate');
    }
    if (lower.contains('monitoring') ||
        lower.contains('still learning') ||
        lower.contains('learning')) {
      return lower.contains('learning') && !lower.contains('monitoring')
          ? t('riskLabelLearning')
          : t('riskLabelMonitoring');
    }
    if (lower.contains('safe') && !lower.contains('unsafe')) {
      return t('riskLabelSafe');
    }
    return text;
  }

  /// Maps status message keys or known English status text to the active language.
  String localizeStatusMessage(String? message) {
    final text = message?.trim() ?? '';
    if (text.isEmpty) return t('statusInitializing');

    // Key with optional payload: statusFollowingMapRouteTo|Place Name
    final pipeIndex = text.indexOf('|');
    if (pipeIndex > 0) {
      final key = text.substring(0, pipeIndex);
      final payload = text.substring(pipeIndex + 1);
      if (_values['en']!.containsKey(key)) {
        return t(key).replaceAll('{name}', payload);
      }
    }

    if (_values['en']!.containsKey(text)) return t(text);

    final lower = text.toLowerCase();
    if (lower.contains('gps is off')) return t('statusGpsOff');
    if (lower.contains('permanently denied')) {
      return t('statusLocationDeniedForever');
    }
    if (lower.contains('location permission required')) {
      return t('statusLocationPermissionRequired');
    }
    if (lower.contains('gps connected')) return t('statusGpsConnected');
    if (lower.contains('fetching area safety')) {
      return t('statusFetchingIntelligence');
    }
    if (lower.contains('stream paused')) return t('statusLiveStreamPaused');
    if (lower.contains('live safety intelligence active')) {
      return t('statusLiveIntelligenceActive');
    }
    if (lower.contains('nearby emergency services loaded')) {
      return t('statusNearbyServicesLoaded');
    }
    if (lower.contains('area safety assessed')) {
      return t('statusAreaAssessedLocal');
    }
    if (lower.contains('cannot reach suraksha') ||
        lower.contains('lan_base_url')) {
      return t('statusCannotReachServer');
    }
    if (lower.contains('initializing safety monitor')) {
      return t('statusInitializing');
    }
    if (lower.contains('learning daily route')) {
      return t('statusLearningDailyRoute');
    }
    if (lower.contains('map route cleared')) return t('statusMapRouteCleared');
    if (lower.contains('safety confirmed')) return t('statusSafetyConfirmed');
    if (lower.contains('route history reset')) {
      return t('statusRouteHistoryReset');
    }
    if (lower.contains('safe route changed') ||
        lower.contains('are you safe')) {
      return t('statusSafeRouteChanged');
    }
    if (lower.contains('initializing map')) return t('statusInitializingMap');
    if (lower.contains('location service is disabled')) {
      return t('statusLocationServiceDisabled');
    }
    if (lower.contains('location permission denied')) {
      return t('statusLocationPermissionDenied');
    }
    if (lower.contains('destination reached')) {
      return t('statusDestinationReached');
    }
    if (lower.contains('loading best route')) {
      return t('statusLoadingBestRoute');
    }
    if (lower.contains('missing maps api key')) {
      return t('statusRoadRoutingUnavailable');
    }
    if (lower.contains('direct line fallback')) {
      return t('statusRoadRouteFallback');
    }
    return text;
  }

  /// Localizes dynamic app strings that may be keys, key|payload, or English.
  String localizeDynamic(String? message) {
    final text = message?.trim() ?? '';
    if (text.isEmpty) return text;

    // key|a|b|c → fill placeholders in template order of appearance
    final parts = text.split('|');
    final key = parts.first;
    if (_values['en']!.containsKey(key)) {
      var out = t(key);
      if (parts.length > 1) {
        final values = parts.sublist(1);
        const placeholders = [
          '{meters}',
          '{region}',
          '{pings}',
          '{cells}',
          '{police}',
          '{hospitals}',
          '{fuel}',
          '{radius}',
          '{label}',
          '{count30d}',
          '{count7d}',
          '{period}',
          '{rate}',
          '{count}',
          '{category}',
          '{name}',
          '{trips}',
          '{need}',
          '{seconds}',
          '{score}',
          '{sunset}',
        ];
        final ordered = placeholders.where(out.contains).toList()
          ..sort((a, b) => out.indexOf(a).compareTo(out.indexOf(b)));
        for (var i = 0; i < ordered.length && i < values.length; i++) {
          var value = values[i];
          if (_values['en']!.containsKey(value)) {
            value = t(value);
          }
          out = out.replaceAll(ordered[i], value);
        }
      }
      return out;
    }

    final status = localizeStatusMessage(text);
    if (status != text) return status;
    final risk = localizeRiskLabel(text);
    if (risk != text) return risk;

    final lower = text.toLowerCase();
    if (lower.contains('drug-related') || lower.contains('narcotic')) {
      return t('safetyReasonDrugActivity');
    }
    if (lower.contains('chain-snatch') || lower.contains('snatch')) {
      return t('safetyReasonChainSnatching');
    }
    if (lower.contains('theft') || lower.contains('robbery')) {
      return t('safetyReasonTheftProne');
    }
    if (lower.contains('harass') || lower.contains('assault')) {
      return t('safetyReasonHarassmentReports');
    }
    if (lower.contains('poor') && lower.contains('light')) {
      return t('safetyReasonPoorLighting');
    }
    if (lower.contains('low pedestrian') || lower.contains('isolated')) {
      return t('safetyReasonLowFootfall');
    }
    if (lower.contains('incident activity remains elevated')) {
      return t('safetyReasonCrimeActivity');
    }
    if (lower.contains('limited nearby emergency support')) {
      return t('safetyReasonLimitedSupport');
    }
    if (lower.contains('after sunset') || lower.contains('night-time')) {
      return t('safetyReasonNightRisk');
    }
    if (lower.contains('emergency support') && lower.contains('nearby')) {
      return t('safetyReasonSupportNearby');
    }
    if (lower.contains('stay aware') && lower.contains('trusted')) {
      return t('safetyActionSafe');
    }
    if (lower.contains('avoid isolated')) {
      return t('safetyActionHighRisk');
    }
    return text;
  }

  String localizeRiskLevelCode(String level) {
    switch (level.trim().toUpperCase()) {
      case 'HIGH':
        return t('cyberRiskHigh');
      case 'MEDIUM':
        return t('cyberRiskMedium');
      case 'LOW':
        return t('cyberRiskLow');
      default:
        return level;
    }
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (item) => item.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
