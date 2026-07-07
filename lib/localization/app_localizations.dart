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
      'fullName': 'Full Name',
      'phoneNumber': 'Phone Number',
      'phoneNumberInvalid': 'Enter a valid 10-digit mobile number.',
      'emailOptional': 'Email (optional)',
      'confirmPassword': 'Confirm Password',
      'signUp': 'SIGN UP',
      'alreadyHaveAccount': 'Already have an account? Sign in',
      'dontHaveAccount': "Don't have an account? Sign up",
      'passwordsDoNotMatch': 'Passwords do not match.',
      'forgotPassword': 'Forgot password?',
      'forgotPasswordTitle': 'Reset password',
      'forgotPasswordSubtitle':
          'Enter your registered phone number. We will send a 6-digit OTP.',
      'sendOtp': 'SEND OTP',
      'resendOtp': 'RESEND OTP',
      'resendOtpIn': 'Resend OTP in {seconds}s',
      'enterOtp': '6-digit OTP',
      'verifyOtp': 'VERIFY OTP',
      'otpSent': 'OTP sent to your phone.',
      'otpSendFailed': 'Could not send OTP. Try again.',
      'otpInvalid': 'Enter the 6-digit OTP.',
      'phoneVerified': 'Phone number verified.',
      'verifyPhoneFirst': 'Verify your phone with OTP before signing up.',
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
      'fullName': 'Full Name',
      'email': 'Email',
      'phone': 'Phone Number',
      'relation': 'Relation',
      'name': 'Name',
      'bloodGroup': 'Blood Group',
      'allergies': 'Allergies',
      'medicalConditions': 'Medical Conditions',
      'currentMedications': 'Current Medications',
      'phoneNumber': 'Phone Number',
      'notProvided': 'Not provided',
      'emergencyContacts': 'Emergency Contacts',
      'contactsSaved': 'Contacts Saved',
      'emergencyContactList': 'Emergency Contact List',
      'addEmergencyContact': 'ADD EMERGENCY CONTACT',
      'addNewContact': 'Add new contact',
      'logoutSession': 'LOGOUT SESSION',
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
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
      'duplicatePhoneNumber': 'This phone number is already saved.',
      'savedLocallyRetryLater': 'Saved locally. Server sync will retry later.',
      'photoSavedLocally': 'Photo saved locally.',
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
      'uploadingEvidence': 'Uploading evidence...',
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
          'Prepare and submit a detailed complaint record. In immediate danger, call 112 first.',
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
          'Legal Disclaimer: This guide is not a substitute for case-specific legal advice. For critical matters, consult a qualified lawyer, HR-POSH expert, or competent authority.',
      'guide1Title': '1. Background And Objective',
      'guide1Body':
          'The POSH Act creates a legal framework to prevent and address sexual harassment at work while protecting dignity and safe working conditions.',
      'guide2Title': '2. Where It Applies',
      'guide2Body':
          'It applies to public and private workplaces, schools, hospitals, NGOs, sports setups, domestic-work settings, and travel connected to employment.',
      'guide3Title': '3. Who Is Protected',
      'guide3Body':
          'The law primarily protects women at the workplace, including employees, trainees, interns, volunteers, contract staff, and visitors in that context.',
      'guide4Title': '4. What Counts As Sexual Harassment',
      'guide4Body':
          'Unwelcome physical contact, sexual requests, sexual remarks, pornography, and other verbal, non-verbal, or digital conduct of a sexual nature can count.',
      'guide5Title': '5. Internal Committee (IC) Requirements',
      'guide5Body':
          'Workplaces with 10 or more employees must form an Internal Committee with the required composition, including a presiding officer and an external member.',
      'guide6Title': '6. Complaint Timeline And Format',
      'guide6Body':
          'Complaints are usually filed in writing within 3 months. They should include parties, dates, location, facts, witnesses, evidence, and the relief sought.',
      'guide7Title': '7. Conciliation And Inquiry',
      'guide7Body':
          'Conciliation is voluntary. If it does not happen, the IC runs a fair inquiry where both sides are heard and the process stays written and documented.',
      'guide8Title': '8. Interim Relief During Proceedings',
      'guide8Body':
          'Interim relief can include transfer, leave, reporting-line changes, no-contact directions, work-from-home changes, or security support.',
      'guide9Title': '9. Inquiry Outcome And Employer Action',
      'guide9Body':
          'If proven, the IC can recommend action such as warning, apology, counseling, promotion impact, termination, or compensation according to service rules.',
      'guide10Title': '10. Police Complaint And Criminal Law',
      'guide10Body':
          'POSH does not replace criminal remedies. If the facts show a criminal offense, the complainant can also file a police complaint or FIR.',
      'guide11Title': '11. Confidentiality Rules',
      'guide11Body':
          'The identities of parties and witnesses, inquiry details, findings, and actions should stay confidential unless the law requires disclosure.',
      'guide12Title': '12. False Complaints: Correct Legal Position',
      'guide12Body':
          'A complaint is not automatically malicious just because it was not proven. Deliberate falsehood or forged evidence is a different standard.',
      'guide13Title': '13. How Not To Misuse The Act',
      'guide13Body':
          'Do not fabricate allegations, tamper with evidence, coach witnesses, or use the process for unrelated personal disputes.',
      'guide14Title': '14. Employer Compliance Checklist',
      'guide14Body':
          'Employers should form the IC correctly, publish the POSH policy, train staff, display the complaint channel, document inquiries, and avoid retaliation.',
      'guide15Title': '15. Practical Evidence Checklist',
      'guide15Body':
          'Preserve chats, emails, call logs, timestamps, witness names, complaint history, and relevant medical or mental-health records.',
      'guide16Title': '16. Appeals And Further Remedies',
      'guide16Body':
          'Depending on the rules and law, parties may challenge outcomes through appellate channels or seek external legal remedies.',
      'guide17Title': '17. Good-Faith Use Of POSH Portal',
      'guide17Body':
          'Use the portal to create records, file structured complaints, and prepare for IC or police processes. In danger, call emergency services first.',
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
      'safetyVerdictSafe': 'Generally safe',
      'safetyVerdictSafeSummary':
          'This area feels generally safe right now based on your live location.',
      'safetyVerdictCaution': 'Use caution',
      'safetyVerdictCautionSummary':
          'Use extra caution here—some risk signals were detected nearby.',
      'safetyVerdictHighRisk': 'Higher concern',
      'safetyVerdictHighRiskSummary':
          'This area may not feel safe right now, especially for women and elderly users.',
      'safetyVerdictLimitedDataSummary':
          'We have limited verified information for this area right now. Stay alert and use normal daytime precautions.',
      'safetyVerdictSafeWithEmergencySummary':
          'Emergency support is available within 1 km. This area feels generally safer right now.',
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
      'safetyWhySafeTitle': 'Why this area looks safe',
      'safetyWhyNotSafeTitle': 'Why this area may not feel safe',
      'safetyWhatToDo': 'What to do',
      'safetyUpdatingAreaIntelligence': 'Updating area safety intelligence...',
      'safetyActionSafe': 'Stay aware and keep trusted contacts reachable.',
      'safetyActionCaution':
          'Stay in lit areas and keep trusted contacts informed.',
      'safetyActionHighRisk':
          'Avoid isolated routes and share live location with someone you trust.',
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
      'fullName': 'पूरा नाम',
      'phoneNumber': 'फोन नंबर',
      'phoneNumberInvalid': 'मान्य 10 अंकों का मोबाइल नंबर दर्ज करें।',
      'emailOptional': 'ईमेल (वैकल्पिक)',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'signUp': 'साइन अप',
      'alreadyHaveAccount': 'पहले से खाता है? साइन इन करें',
      'dontHaveAccount': 'खाता नहीं है? साइन अप करें',
      'passwordsDoNotMatch': 'पासवर्ड मेल नहीं खाते।',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'forgotPasswordTitle': 'पासवर्ड रीसेट करें',
      'forgotPasswordSubtitle':
          'अपना पंजीकृत फोन नंबर दर्ज करें। हम 6 अंकों का OTP भेजेंगे।',
      'sendOtp': 'OTP भेजें',
      'resendOtp': 'OTP दोबारा भेजें',
      'resendOtpIn': '{seconds}s में OTP दोबारा भेजें',
      'enterOtp': '6 अंकों का OTP',
      'verifyOtp': 'OTP सत्यापित करें',
      'otpSent': 'OTP आपके फोन पर भेजा गया।',
      'otpSendFailed': 'OTP भेजा नहीं जा सका। पुनः प्रयास करें।',
      'otpInvalid': '6 अंकों का OTP दर्ज करें।',
      'phoneVerified': 'फोन नंबर सत्यापित हो गया।',
      'verifyPhoneFirst': 'साइन अप से पहले OTP से फोन सत्यापित करें।',
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
      'fullName': 'पूरा नाम',
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
      'allergies': 'एलर्जी',
      'medicalConditions': 'चिकित्सीय स्थितियां',
      'currentMedications': 'वर्तमान दवाएं',
      'phoneNumber': 'फोन नंबर',
      'notProvided': 'उपलब्ध नहीं',
      'emergencyContacts': 'आपातकालीन संपर्क',
      'contactsSaved': 'संपर्क सहेजे गए',
      'emergencyContactList': 'आपातकालीन संपर्क सूची',
      'addEmergencyContact': 'आपातकालीन संपर्क जोड़ें',
      'addNewContact': 'नया संपर्क जोड़ें',
      'logoutSession': 'लॉगआउट',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'ok': 'ठीक है',
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
      'duplicatePhoneNumber': 'यह फोन नंबर पहले से सहेजा गया है।',
      'savedLocallyRetryLater':
          'स्थानीय रूप से सहेजा गया। सर्वर सिंक बाद में फिर से कोशिश करेगा।',
      'photoSavedLocally': 'फ़ोटो स्थानीय रूप से सहेजी गई।',
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
      'uploadingEvidence': 'साक्ष्य अपलोड हो रहा है...',
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
          'विस्तृत शिकायत रिकॉर्ड तैयार करें और भेजें। तुरंत खतरे में 112 पर कॉल करें।',
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
          'कानूनी अस्वीकरण: यह मार्गदर्शिका मामले-विशेष कानूनी सलाह का विकल्प नहीं है। महत्वपूर्ण मामलों में योग्य वकील, HR-POSH विशेषज्ञ या सक्षम प्राधिकारी से सलाह लें।',
      'guide1Title': '1. पृष्ठभूमि और उद्देश्य',
      'guide1Body':
          'POSH अधिनियम काम पर यौन उत्पीड़न को रोकने और संबोधित करने के लिए कानूनी ढांचा बनाता है और गरिमा व सुरक्षित कार्य स्थितियों की रक्षा करता है।',
      'guide2Title': '2. यह कहाँ लागू होता है',
      'guide2Body':
          'यह सार्वजनिक और निजी कार्यस्थलों, स्कूलों, अस्पतालों, NGO, खेल सेटअप, घरेलू काम और रोजगार से जुड़े सफर पर लागू होता है।',
      'guide3Title': '3. कौन संरक्षित है',
      'guide3Body':
          'यह कानून मुख्य रूप से कार्यस्थल पर महिलाओं की रक्षा करता है, जिसमें कर्मचारी, प्रशिक्षु, इंटर्न, स्वयंसेवक, संविदा कर्मचारी और उस संदर्भ में आने वाले आगंतुक शामिल हैं।',
      'guide4Title': '4. यौन उत्पीड़न क्या है',
      'guide4Body':
          'अवांछित शारीरिक संपर्क, यौन अनुरोध, यौन टिप्पणियाँ, अश्लील सामग्री, और यौन प्रकृति का अन्य मौखिक, गैर-मौखिक या डिजिटल आचरण इसमें आ सकते हैं।',
      'guide5Title': '5. आंतरिक समिति (IC) आवश्यकताएँ',
      'guide5Body':
          '10 या अधिक कर्मचारियों वाले कार्यस्थलों में आवश्यक संरचना के साथ Internal Committee बननी चाहिए, जिसमें Presiding Officer और बाहरी सदस्य शामिल हों।',
      'guide6Title': '6. शिकायत समयसीमा और प्रारूप',
      'guide6Body':
          'शिकायत आमतौर पर 3 महीने के भीतर लिखित रूप में दी जाती है। इसमें पक्ष, तिथियाँ, स्थान, तथ्य, गवाह, साक्ष्य और मांगी गई राहत शामिल होनी चाहिए।',
      'guide7Title': '7. सुलह और जाँच',
      'guide7Body':
          'सुलह स्वैच्छिक है। यदि ऐसा न हो, तो IC निष्पक्ष जाँच करती है जहाँ दोनों पक्ष सुने जाते हैं और प्रक्रिया लिखित व दस्तावेजित रहती है।',
      'guide8Title': '8. प्रक्रिया के दौरान अंतरिम राहत',
      'guide8Body':
          'अंतरिम राहत में स्थानांतरण, अवकाश, रिपोर्टिंग लाइन परिवर्तन, संपर्क-निषेध निर्देश, WFH बदलाव या सुरक्षा सहायता शामिल हो सकती है।',
      'guide9Title': '9. जाँच परिणाम और नियोक्ता की कार्रवाई',
      'guide9Body':
          'यदि आरोप सिद्ध हों, तो IC नियमों के अनुसार चेतावनी, माफी, परामर्श, प्रमोशन/वेतन वृद्धि पर प्रभाव, बर्खास्तगी या मुआवज़ा सुझा सकती है।',
      'guide10Title': '10. पुलिस शिकायत और आपराधिक कानून',
      'guide10Body':
          'POSH आपराधिक उपायों की जगह नहीं लेता। यदि तथ्य अपराध दिखाते हैं, तो शिकायतकर्ता पुलिस शिकायत या FIR भी दर्ज कर सकता है।',
      'guide11Title': '11. गोपनीयता नियम',
      'guide11Body':
          'पक्षों और गवाहों की पहचान, जाँच विवरण, निष्कर्ष और कार्रवाई गोपनीय रखी जानी चाहिए, जब तक कानून अलग से न कहे।',
      'guide12Title': '12. झूठी शिकायत: सही कानूनी स्थिति',
      'guide12Body':
          'केवल साबित न होने से शिकायत अपने आप दुर्भावनापूर्ण नहीं हो जाती। जानबूझकर झूठ या जाली साक्ष्य अलग मानक है।',
      'guide13Title': '13. अधिनियम का दुरुपयोग कैसे न करें',
      'guide13Body':
          'जानबूझकर झूठे आरोप, साक्ष्य में छेड़छाड़, गवाहों को प्रभावित करना या निजी विवादों के लिए प्रक्रिया का उपयोग न करें।',
      'guide14Title': '14. नियोक्ता अनुपालन सूची',
      'guide14Body':
          'IC सही ढंग से बनाएं, POSH नीति प्रकाशित करें, स्टाफ को प्रशिक्षित करें, शिकायत चैनल दिखाएं, जाँच दस्तावेज़ रखें और प्रतिशोध से बचें।',
      'guide15Title': '15. व्यावहारिक साक्ष्य सूची',
      'guide15Body':
          'चैट, ईमेल, कॉल लॉग, टाइमस्टैम्प, गवाहों के नाम, शिकायत इतिहास और संबंधित मेडिकल/मेंटल हेल्थ रिकॉर्ड सुरक्षित रखें।',
      'guide16Title': '16. अपील और अन्य उपाय',
      'guide16Body':
          'नियमों और कानून के अनुसार, पक्ष अपीलीय मार्गों से परिणामों को चुनौती दे सकते हैं या बाहरी कानूनी उपाय खोज सकते हैं।',
      'guide17Title': '17. POSH पोर्टल का सद्भावपूर्ण उपयोग',
      'guide17Body':
          'रिकॉर्ड बनाने, संरचित शिकायत दाखिल करने और IC या पुलिस प्रक्रिया की तैयारी के लिए पोर्टल का उपयोग करें। खतरे में पहले आपातकालीन सहायता लें।',
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
      'safetyVerdictSafe': 'आम तौर पर सुरक्षित',
      'safetyVerdictSafeSummary':
          'आपके लाइव स्थान के आधार पर यह क्षेत्र अभी सामान्य रूप से सुरक्षित लगता है।',
      'safetyVerdictCaution': 'सावधानी बरतें',
      'safetyVerdictCautionSummary':
          'यहां अतिरिक्त सावधानी बरतें—आसपास कुछ जोखिम संकेत मिले हैं।',
      'safetyVerdictHighRisk': 'उच्च चिंता',
      'safetyVerdictHighRiskSummary':
          'यह क्षेत्र अभी सुरक्षित नहीं लग सकता, विशेषकर महिलाओं और बुजुर्ग उपयोगकर्ताओं के लिए।',
      'safetyVerdictLimitedDataSummary':
          'इस क्षेत्र के लिए अभी सीमित सत्यापित जानकारी है। सतर्क रहें और सामान्य दिन की सावधानियाँ बरतें।',
      'safetyVerdictSafeWithEmergencySummary':
          '1 किमी के भीतर आपातकालीन सहायता उपलब्ध है। यह क्षेत्र अभी सामान्यतः सुरक्षित लगता है।',
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
      'safetyWhySafeTitle': 'यह क्षेत्र सुरक्षित क्यों लगता है',
      'safetyWhyNotSafeTitle': 'यह क्षेत्र सुरक्षित क्यों नहीं लग सकता',
      'safetyWhatToDo': 'क्या करें',
      'safetyUpdatingAreaIntelligence': 'क्षेत्र सुरक्षा जानकारी अपडेट हो रही है...',
      'safetyActionSafe': 'सतर्क रहें और विश्वसनीय संपर्कों को पास रखें।',
      'safetyActionCaution':
          'रोशनी वाले क्षेत्रों में रहें और परिवार को सूचित रखें।',
      'safetyActionHighRisk':
          'एकांत रास्तों से बचें और लाइव लोकेशन किसी भरोसेमंद व्यक्ति के साथ साझा करें।',
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
      'fullName': 'पूर्ण नाव',
      'phoneNumber': 'फोन नंबर',
      'phoneNumberInvalid': 'वैध 10 अंकी मोबाइल नंबर प्रविष्ट करा.',
      'emailOptional': 'ईमेल (पर्यायी)',
      'confirmPassword': 'पासवर्डची पुष्टी करा',
      'signUp': 'साइन अप',
      'alreadyHaveAccount': 'आधीपासून खाते आहे? साइन इन करा',
      'dontHaveAccount': 'खाते नाही? साइन अप करा',
      'passwordsDoNotMatch': 'पासवर्ड जुळत नाहीत.',
      'forgotPassword': 'पासवर्ड विसरलात?',
      'forgotPasswordTitle': 'पासवर्ड रीसेट करा',
      'forgotPasswordSubtitle':
          'तुमचा नोंदणीकृत फोन नंबर टाका. आम्ही 6 अंकी OTP पाठवू.',
      'sendOtp': 'OTP पाठवा',
      'resendOtp': 'OTP पुन्हा पाठवा',
      'resendOtpIn': '{seconds}s मध्ये OTP पुन्हा पाठवा',
      'enterOtp': '6 अंकी OTP',
      'verifyOtp': 'OTP पडताळा',
      'otpSent': 'OTP तुमच्या फोनवर पाठवला.',
      'otpSendFailed': 'OTP पाठवता आला नाही. पुन्हा प्रयत्न करा.',
      'otpInvalid': '6 अंकी OTP टाका.',
      'phoneVerified': 'फोन नंबर पडताळला.',
      'verifyPhoneFirst': 'साइन अप करण्यापूर्वी OTP ने फोन पडताळा.',
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
      'fullName': 'पूर्ण नाव',
      'email': 'ईमेल',
      'phone': 'फोन नंबर',
      'relation': 'नाते',
      'name': 'नाव',
      'bloodGroup': 'ब्लड ग्रुप',
      'allergies': 'अॅलर्जी',
      'medicalConditions': 'आरोग्यविषयक स्थिती',
      'currentMedications': 'सध्याची औषधे',
      'phoneNumber': 'फोन नंबर',
      'notProvided': 'उपलब्ध नाही',
      'emergencyContacts': 'आपत्कालीन संपर्क',
      'contactsSaved': 'संपर्क जतन केले',
      'emergencyContactList': 'आपत्कालीन संपर्क यादी',
      'addEmergencyContact': 'आपत्कालीन संपर्क जोडा',
      'addNewContact': 'नवीन संपर्क जोडा',
      'logoutSession': 'लॉगआउट',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'ok': 'ठीक आहे',
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
      'duplicatePhoneNumber': 'हा फोन नंबर आधीच जतन केला आहे.',
      'savedLocallyRetryLater':
          'स्थानिकरित्या जतन केले. सर्व्हर सिंक नंतर पुन्हा प्रयत्न करेल.',
      'photoSavedLocally': 'फोटो स्थानिकरित्या जतन केला.',
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
      'uploadingEvidence': 'साक्ष्य अपलोड होत आहे...',
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
          'तपशीलवार तक्रार नोंद तयार करा आणि पाठवा. तातडीच्या धोक्यात 112 वर कॉल करा.',
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
          'कायदेशीर अस्वीकरण: हे मार्गदर्शक केस-विशिष्ट कायदेशीर सल्ल्याचा पर्याय नाही. महत्त्वाच्या बाबींमध्ये पात्र वकील, HR-POSH तज्ज्ञ किंवा सक्षम प्राधिकरणाचा सल्ला घ्या.',
      'guide1Title': '1. पार्श्वभूमी आणि उद्देश',
      'guide1Body':
          'POSH कायदा कामाच्या ठिकाणी लैंगिक छळ रोखण्यासाठी आणि त्यावर कारवाई करण्यासाठी कायदेशीर चौकट तयार करतो आणि सन्मान व सुरक्षित कामाच्या अटींचे रक्षण करतो.',
      'guide2Title': '2. कुठे लागू होते',
      'guide2Body':
          'हे सार्वजनिक व खासगी कार्यस्थळे, शाळा, रुग्णालये, NGO, क्रीडा व्यवस्था, घरकामाचे संदर्भ आणि नोकरीशी संबंधित प्रवासावर लागू होते.',
      'guide3Title': '3. कोण संरक्षित आहे',
      'guide3Body':
          'हा कायदा मुख्यतः कार्यस्थळी महिलांचे संरक्षण करतो, ज्यात कर्मचारी, प्रशिक्षणार्थी, इंटर्न, स्वयंसेवक, करार कर्मचारी आणि त्या संदर्भातील अभ्यागत समाविष्ट आहेत.',
      'guide4Title': '4. लैंगिक छळ म्हणजे काय',
      'guide4Body':
          'अनाहूत शारीरिक संपर्क, लैंगिक मागण्या, लैंगिक टिप्पणी, अश्लील सामग्री आणि लैंगिक स्वरूपाचे इतर मौखिक, अमौखिक किंवा डिजिटल वर्तन यामध्ये येऊ शकते.',
      'guide5Title': '5. अंतर्गत समिती (IC) आवश्यकता',
      'guide5Body':
          '10 किंवा अधिक कर्मचारी असलेल्या कार्यस्थळी आवश्यक रचनेसह Internal Committee असणे बंधनकारक आहे, ज्यात Presiding Officer आणि बाह्य सदस्य असतो.',
      'guide6Title': '6. तक्रार वेळमर्यादा आणि स्वरूप',
      'guide6Body':
          'तक्रार सामान्यतः 3 महिन्यांच्या आत लेखी दिली जाते. त्यात पक्ष, तारखा, ठिकाण, तथ्ये, साक्षीदार, पुरावे आणि मागितलेली मदत असावी.',
      'guide7Title': '7. संमती/समेट आणि चौकशी',
      'guide7Body':
          'समेट स्वैच्छिक असतो. तो न झाल्यास IC निष्पक्ष चौकशी करते जिथे दोन्ही बाजू ऐकल्या जातात आणि प्रक्रिया लेखी व दस्तऐवजीकृत राहते.',
      'guide8Title': '8. प्रक्रियेतील अंतरिम मदत',
      'guide8Body':
          'अंतरिम मदतीमध्ये बदली, रजा, रिपोर्टिंग लाइन बदल, संपर्क-निषेध, WFH बदल किंवा सुरक्षा मदत समाविष्ट असू शकते.',
      'guide9Title': '9. चौकशी निकाल आणि नियोक्त्याची कारवाई',
      'guide9Body':
          'आरोप सिद्ध झाल्यास, नियमांनुसार इशारा, माफी, समुपदेशन, पदोन्नती/वाढीवर परिणाम, नोकरी समाप्ती किंवा भरपाई सुचवली जाऊ शकते.',
      'guide10Title': '10. पोलिस तक्रार आणि फौजदारी कायदा',
      'guide10Body':
          'POSH हे फौजदारी उपायांचा पर्याय नाही. तथ्यांमधून गुन्हा दिसल्यास, तक्रारदार पोलिस तक्रार किंवा FIR देखील दाखल करू शकतो.',
      'guide11Title': '11. गोपनीयता नियम',
      'guide11Body':
          'पक्ष आणि साक्षीदारांची ओळख, चौकशी तपशील, निष्कर्ष आणि कारवाई गोपनीय ठेवली पाहिजे, जोपर्यंत कायदा वेगळे सांगत नाही.',
      'guide12Title': '12. खोट्या तक्रारी: योग्य कायदेशीर स्थिती',
      'guide12Body':
          'फक्त सिद्ध न झाल्याने तक्रार आपोआप द्वेषपूर्ण ठरत नाही. जाणूनबुजून खोटेपणा किंवा बनावट पुरावा वेगळा निकष आहे.',
      'guide13Title': '13. कायद्याचा गैरवापर कसा करू नये',
      'guide13Body':
          'जाणूनबुजून खोटे आरोप, पुराव्यात फेरफार, साक्षीदारांना प्रभावित करणे किंवा वैयक्तिक वादांसाठी प्रक्रिया वापरणे टाळा.',
      'guide14Title': '14. नियोक्ता अनुपालन सूची',
      'guide14Body':
          'IC योग्यरित्या तयार करा, POSH धोरण प्रकाशित करा, स्टाफला प्रशिक्षण द्या, तक्रार चॅनेल दाखवा, जाँच दस्तऐवजीकरण ठेवा आणि सूड टाळा.',
      'guide15Title': '15. व्यावहारिक पुरावा सूची',
      'guide15Body':
          'चॅट, ईमेल, कॉल लॉग, टाइमस्टॅम्प, साक्षीदारांची नावे, तक्रार इतिहास आणि संबंधित वैद्यकीय/मानसिक आरोग्य नोंदी जपून ठेवा.',
      'guide16Title': '16. अपील आणि इतर उपाय',
      'guide16Body':
          'नियम आणि कायद्याप्रमाणे, पक्ष अपीलीय मार्गांद्वारे निकाल आव्हान देऊ शकतात किंवा बाह्य कायदेशीर उपाय शोधू शकतात.',
      'guide17Title': '17. POSH पोर्टलचा सद्भावपूर्ण वापर',
      'guide17Body':
          'रेकॉर्ड तयार करण्यासाठी, संरचित तक्रार दाखल करण्यासाठी आणि IC किंवा पोलिस प्रक्रियेची तयारी करण्यासाठी पोर्टल वापरा. धोक्यात आधी आपत्कालीन मदत घ्या.',
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
      'safetyVerdictSafe': 'सामान्यतः सुरक्षित',
      'safetyVerdictSafeSummary':
          'तुमच्या लाइव्ह स्थानावर आधारित हा परिसर सध्या सामान्यतः सुरक्षित वाटतो.',
      'safetyVerdictCaution': 'सावधानी बाळगा',
      'safetyVerdictCautionSummary':
          'येथे अतिरिक्त सावधानी बाळगा—जवळपास काही धोका संकेत आढळले आहेत.',
      'safetyVerdictHighRisk': 'जास्त चिंता',
      'safetyVerdictHighRiskSummary':
          'हा परिसर सध्या सुरक्षित वाटत नाही, विशेषतः महिला आणि ज्येष्ठ वापरकर्त्यांसाठी.',
      'safetyVerdictLimitedDataSummary':
          'या परिसरासाठी सध्या मर्यादित सत्यापित माहिती आहे. सजग राहा आणि सामान्य दिवसाच्या खबरदारी घ्या.',
      'safetyVerdictSafeWithEmergencySummary':
          '१ किमी मध्ये आपत्कालीन मदत उपलब्ध आहे. हा परिसर सध्या सामान्यतः सुरक्षित वाटतो.',
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
      'safetyWhySafeTitle': 'हा परिसर सुरक्षित का वाटतो',
      'safetyWhyNotSafeTitle': 'हा परिसर सुरक्षित का वाटत नाही',
      'safetyWhatToDo': 'काय करावे',
      'safetyUpdatingAreaIntelligence': 'परिसर सुरक्षा माहिती अद्यतन होत आहे...',
      'safetyActionSafe': 'सजग राहा आणि विश्वासार्ह संपर्क जवळ ठेवा.',
      'safetyActionCaution':
          'प्रकाशित भागात राहा आणि कुटुंबाला माहिती द्या.',
      'safetyActionHighRisk':
          'एकट्या मार्गांपासून दूर राहा आणि लाइव्ह लोकेशन विश्वासू व्यक्तीसोबत शेअर करा.',
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
