import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/features/profile/emergency_contacts_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final secureStore = <String, String>{};

  group('EmergencyContactsNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      secureStore.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureChannel, (call) async {
        final args = call.arguments;
        final key = args is Map ? args['key']?.toString() : null;
        switch (call.method) {
          case 'read':
            return key == null ? null : secureStore[key];
          case 'write':
            if (key != null) {
              secureStore[key] = args['value']?.toString() ?? '';
            }
            return null;
          case 'delete':
            if (key != null) secureStore.remove(key);
            return null;
          case 'deleteAll':
            secureStore.clear();
            return null;
          case 'readAll':
            return Map<String, String>.from(secureStore);
          case 'containsKey':
            return key != null && secureStore.containsKey(key);
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureChannel, null);
    });

    test('saves contacts locally even when backend sync fails', () async {
      final notifier = EmergencyContactsNotifier(syncEnabled: false);
      addTearDown(notifier.dispose);
      await notifier.bindUser('test-user-1');

      await notifier.addContact(
        const EmergencyContact(
          id: '',
          name: '  Asha  ',
          phone: ' +91 98765 43210 ',
          relation: '',
        ),
      );

      expect(notifier.state, hasLength(1));
      expect(notifier.state.first.name, 'Asha');
      expect(notifier.state.first.phone, '+919876543210');
      expect(notifier.state.first.relation, 'Emergency Contact');

      final reloaded = EmergencyContactsNotifier(syncEnabled: false);
      addTearDown(reloaded.dispose);
      await reloaded.bindUser('test-user-1');
      await reloaded.loadContacts();

      expect(reloaded.state, hasLength(1));
      expect(reloaded.state.first.phone, '+919876543210');
    });

    test('normalizes phone numbers for SMS sending', () {
      expect(
        EmergencyContact.normalizePhoneNumber(' +91 98765-43210 '),
        '+919876543210',
      );
      expect(
        EmergencyContact.normalizePhoneNumber('98765 43210'),
        '+919876543210',
      );
      expect(
        EmergencyContact.identityDigits('+91 98765 43210'),
        EmergencyContact.identityDigits('9876543210'),
      );
    });

    test('rejects a second contact with the same Indian number', () async {
      final notifier = EmergencyContactsNotifier(syncEnabled: false);
      addTearDown(notifier.dispose);
      await notifier.bindUser('test-user-dup');

      final first = await notifier.addContact(
        const EmergencyContact(
          id: '',
          name: 'Asha',
          phone: '98765 43210',
          relation: 'Sister',
        ),
      );
      final second = await notifier.addContact(
        const EmergencyContact(
          id: '',
          name: 'Asha Again',
          phone: '+91 98765 43210',
          relation: 'Friend',
        ),
      );

      expect(first, isTrue);
      expect(second, isFalse);
      expect(notifier.state, hasLength(1));
    });

    test(
      'loading empty local storage does not wipe current contacts',
      () async {
        final notifier = EmergencyContactsNotifier(syncEnabled: false);
        addTearDown(notifier.dispose);
        await notifier.bindUser('test-user-2');

        await notifier.addContact(
          const EmergencyContact(
            id: '',
            name: 'Meera',
            phone: '99999 11111',
            relation: 'Sister',
          ),
        );
        SharedPreferences.setMockInitialValues({});
        secureStore.clear();

        await notifier.loadContacts();

        expect(notifier.state, hasLength(1));
        expect(notifier.state.first.name, 'Meera');
      },
    );
    test('detects Mongo-style server contact ids', () {
      expect(
        EmergencyContactsNotifier.isServerContactId('507f1f77bcf86cd799439011'),
        isTrue,
      );
      expect(
        EmergencyContactsNotifier.isServerContactId('1712345678901'),
        isFalse,
      );
    });

    test('updates local-only contacts without requiring server id', () async {
      final notifier = EmergencyContactsNotifier(syncEnabled: false);
      addTearDown(notifier.dispose);
      await notifier.bindUser('test-user-3');

      await notifier.addContact(
        const EmergencyContact(
          id: '',
          name: 'Riya',
          phone: '9000011111',
          relation: 'Friend',
        ),
      );
      final localId = notifier.state.first.id;
      expect(EmergencyContactsNotifier.isServerContactId(localId), isFalse);

      final updated = await notifier.updateContact(
        EmergencyContact(
          id: localId,
          name: 'Riya Updated',
          phone: '9000011111',
          relation: 'Friend',
        ),
      );
      expect(updated, isTrue);
      expect(notifier.state.first.name, 'Riya Updated');
    });
  });
}
