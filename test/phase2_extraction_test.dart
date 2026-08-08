import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alert_display_helpers.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alert_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/community_alerts_provider.dart';
import 'package:suraksha_women_safety_app/features/dashboard/dashboard_chrome_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/nearby_services_widgets.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_meta_chip.dart';
import 'package:suraksha_women_safety_app/features/dashboard/safety_monitor_provider.dart';
import 'package:suraksha_women_safety_app/features/maps/map_route_models.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/journey_alert_banner.dart';
import 'package:suraksha_women_safety_app/features/maps/widgets/map_quick_controls.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contact_item.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_format_helpers.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_settings_widgets.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CommunityAlertDisplayHelpers', () {
    test('maps local alert kinds to priorities', () {
      final alert = CommunityAlertDisplayHelpers.mapLocalCommunityAlert(
        CommunityAlertItem(
          kind: CommunityAlertKind.roadBlock,
          title: 'Block',
          detail: 'Closed',
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      expect(alert.priority, 'critical');
      expect(alert.category, 'Block');
    });

    test('colors and icons are stable for priorities', () {
      expect(
        CommunityAlertDisplayHelpers.colorForCommunityAlert('critical'),
        const Color(0xFFE53935),
      );
      expect(
        CommunityAlertDisplayHelpers.iconForCommunityAlert(
          'information',
          'hospital nearby',
        ),
        Icons.local_hospital_rounded,
      );
    });

    test('prefers monitor alerts over local', () {
      final monitor = SafetyMonitorState(
        communityAlerts: [
          SafetyCommunityAlert(
            category: 'From monitor',
            priority: 'caution',
            distanceMeters: 10,
            timestamp: DateTime(2026, 1, 1),
            summary: 's',
            recommendedAction: 'a',
          ),
        ],
      );
      final resolved = CommunityAlertDisplayHelpers.resolveCommunityAlerts(
        monitor,
        const CommunityAlertsState(),
      );
      expect(resolved, isNotEmpty);
      expect(resolved.first.category, 'From monitor');
    });
  });

  group('ProfileFormatHelpers', () {
    test('extractError reads ArgumentError message', () {
      expect(ProfileFormatHelpers.extractError(ArgumentError('bad')), 'bad');
    });

    test('route countdown formatting', () async {
      SharedPreferences.setMockInitialValues({});
      final l10n = await AppLocalizations.current();
      expect(ProfileFormatHelpers.formatRouteCountdown(l10n, 0), 'now');
      expect(ProfileFormatHelpers.formatRouteCountdown(l10n, 45), '45s');
      expect(ProfileFormatHelpers.formatRouteCountdown(l10n, 120), '2m');
    });
  });

  group('Phase2 chrome & map model extractions', () {
    testWidgets('PoppingActionCard renders label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppingActionCard(
              icon: Icons.map_rounded,
              label: 'Safe Map',
              color: const Color(0xFF3B82F6),
              width: 200,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Safe Map'), findsOneWidget);
    });

    testWidgets('ProfileRouteChip renders label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileRouteChip(
              icon: Icons.shield_rounded,
              label: 'Low risk',
              color: Color(0xFF15803D),
            ),
          ),
        ),
      );
      expect(find.text('Low risk'), findsOneWidget);
    });

    test('MapRouteAssessmentDisplay.fromJson keeps defaults', () {
      final display = MapRouteAssessmentDisplay.fromJson(const {});
      expect(display.id, '');
      expect(display.label, 'Safer Route');
      expect(display.averageSafetyScore, 50);
      expect(display.summary, 'Balanced route guidance applied.');
    });

    test('MapDirectionRoute fields are preserved', () {
      const route = MapDirectionRoute(
        routeId: 'r1',
        encodedPolyline: 'abc',
        etaSeconds: 120,
        distanceMeters: 900,
        distanceText: '0.9 km',
        durationText: '2 min',
        safetyScore: 78,
        safetyReason: 'lit streets',
      );
      expect(route.routeId, 'r1');
      expect(route.safetyScore, 78);
      expect(route.safetyReason, 'lit streets');
    });

    testWidgets('SafetyMetaChip renders label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafetyMetaChip(
              icon: Icons.public_rounded,
              label: 'Maharashtra',
              isLight: true,
            ),
          ),
        ),
      );
      expect(find.text('Maharashtra'), findsOneWidget);
    });

    testWidgets('NearbyStatusPanel renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearbyStatusPanel(
              icon: Icons.radar_rounded,
              title: 'Scanning nearby places',
              tone: Color(0xFF3B82F6),
            ),
          ),
        ),
      );
      expect(find.text('Scanning nearby places'), findsOneWidget);
    });

    testWidgets('CommunityAlertsStatusPanel renders title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommunityAlertsStatusPanel(
              isLight: true,
              icon: Icons.info_outline_rounded,
              loading: false,
              title: 'Live alerts',
              tone: Color(0xFF26BF96),
            ),
          ),
        ),
      );
      expect(find.text('Live alerts'), findsOneWidget);
    });

    testWidgets('JourneyAlertBanner renders fallback title and body', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final l10n = await AppLocalizations.current();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: JourneyAlertBanner(
              safetyState: SafetyMonitorState(
                rerouteHint: 'Low lighting nearby',
              ),
              isLight: true,
            ),
          ),
        ),
      );
      expect(find.text(l10n.t('journeyRerouteHint')), findsOneWidget);
      expect(find.text('Low lighting nearby'), findsOneWidget);
    });

    testWidgets('MapCircleControl renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapCircleControl(
              icon: Icons.layers_rounded,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.layers_rounded), findsOneWidget);
    });

    testWidgets('EmergencyContactItem renders name and phone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyContactItem(
              contact: const EmergencyContact(
                id: '1',
                name: 'Mom',
                phone: '9876543210',
                relation: 'Mother',
              ),
              enabled: true,
              onTestSms: () {},
              onMakePrimary: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      expect(find.text('Mom'), findsOneWidget);
      expect(find.textContaining('9876543210'), findsOneWidget);
    });
  });
}
