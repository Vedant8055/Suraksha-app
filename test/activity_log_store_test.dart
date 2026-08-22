import 'dart:io';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_redactor.dart';
import 'package:suraksha_women_safety_app/core/activity_log/activity_log_store.dart';

void main() {
  test('redacts passwords and otp-like numbers', () {
    expect(
      ActivityLogRedactor.scrubMap({'password': 'secret', 'name': 'Asha'})['password'],
      '[redacted]',
    );
    expect(ActivityLogRedactor.scrubText('code 123456'), contains('[redacted]'));
  });

  test('appends encrypted entries and reads them back', () async {
    final dir = await Directory.systemTemp.createTemp('suraksha_logs_');
    addTearDown(() => dir.delete(recursive: true));
    final store = ActivityLogStore(
      directory: dir,
      testKey: enc.Key.fromSecureRandom(32),
    );

    await store.append(event: 'login_success', details: 'ok');
    await store.append(event: 'sos_triggered', details: '');
    final rows = await store.readRecent();
    expect(rows.length, 2);
    expect(rows.map((e) => e.event), containsAll(['login_success', 'sos_triggered']));
    expect(rows.every((e) => !e.tampered), isTrue);
  });
}
