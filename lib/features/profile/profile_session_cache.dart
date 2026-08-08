import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/models/user_model.dart';

/// Device-local profile data. Must be cleared or rebound on logout / account switch.
/// PII lives in secure storage; SharedPreferences only holds non-sensitive leftovers.
class ProfileSessionCache {
  ProfileSessionCache._();

  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static const String nameKey = 'profile_local_name_v1';
  static const String emailKey = 'profile_local_email_v1';
  static const String phoneKey = 'profile_local_phone_v1';
  static const String bloodKey = 'profile_local_blood_v1';
  static const String photoPathKey = 'profile_local_photo_path_v1';

  /// Legacy global emergency-contacts bucket (pre user-scoping).
  static const String legacyEmergencyContactsKey =
      'emergency_contacts_offline_v2';

  static String emergencyContactsKeyFor(String userId) =>
      'emergency_contacts_offline_v3_$userId';

  static Future<void> _migratePrefsToSecureIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final secureName = await _secure.read(key: nameKey);
    if (secureName != null) {
      // Already migrated — scrub plaintext leftovers.
      await Future.wait([
        prefs.remove(nameKey),
        prefs.remove(emailKey),
        prefs.remove(phoneKey),
        prefs.remove(bloodKey),
      ]);
      return;
    }
    final name = prefs.getString(nameKey);
    final email = prefs.getString(emailKey);
    final phone = prefs.getString(phoneKey);
    final blood = prefs.getString(bloodKey);
    if ((name ?? '').isEmpty && (email ?? '').isEmpty && (phone ?? '').isEmpty) {
      return;
    }
    if (name != null) await _secure.write(key: nameKey, value: name);
    if (email != null) await _secure.write(key: emailKey, value: email);
    if (phone != null) await _secure.write(key: phoneKey, value: phone);
    if (blood != null) await _secure.write(key: bloodKey, value: blood);
    await Future.wait([
      prefs.remove(nameKey),
      prefs.remove(emailKey),
      prefs.remove(phoneKey),
      prefs.remove(bloodKey),
    ]);
  }

  static Future<void> clearAll({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _secure.delete(key: nameKey),
      _secure.delete(key: emailKey),
      _secure.delete(key: phoneKey),
      _secure.delete(key: bloodKey),
      prefs.remove(nameKey),
      prefs.remove(emailKey),
      prefs.remove(phoneKey),
      prefs.remove(bloodKey),
      prefs.remove(photoPathKey),
      prefs.remove(legacyEmergencyContactsKey),
      if (userId != null && userId.isNotEmpty) ...[
        _secure.delete(key: emergencyContactsKeyFor(userId)),
        prefs.remove(emergencyContactsKeyFor(userId)),
      ],
    ]);
  }

  static Future<UserModel?> readUser() async {
    await _migratePrefsToSecureIfNeeded();
    final name = (await _secure.read(key: nameKey))?.trim() ?? '';
    final email = (await _secure.read(key: emailKey))?.trim() ?? '';
    final phone = (await _secure.read(key: phoneKey))?.trim() ?? '';
    if (name.isEmpty && email.isEmpty && phone.isEmpty) return null;
    return UserModel(
      id: '',
      name: name,
      email: email,
      phone: phone,
      bloodGroup: await _secure.read(key: bloodKey),
    );
  }

  static Future<void> writeLocalProfile({
    required String fullName,
    required String email,
    required String phone,
    required String bloodGroup,
    String? localPhotoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _secure.write(key: nameKey, value: fullName),
      _secure.write(key: emailKey, value: email),
      _secure.write(key: phoneKey, value: phone),
      _secure.write(key: bloodKey, value: bloodGroup),
      prefs.remove(nameKey),
      prefs.remove(emailKey),
      prefs.remove(phoneKey),
      prefs.remove(bloodKey),
    ]);
    if (localPhotoPath != null && localPhotoPath.isNotEmpty) {
      await prefs.setString(photoPathKey, localPhotoPath);
    }
  }

  static Future<Map<String, String?>> readLocalProfile() async {
    await _migratePrefsToSecureIfNeeded();
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': await _secure.read(key: nameKey),
      'email': await _secure.read(key: emailKey),
      'phone': await _secure.read(key: phoneKey),
      'blood': await _secure.read(key: bloodKey),
      'photoPath': prefs.getString(photoPathKey),
    };
  }

  static Future<void> writeDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await _secure.write(key: nameKey, value: name.trim());
    await prefs.remove(nameKey);
  }

  static Future<String> readDisplayName() async {
    await _migratePrefsToSecureIfNeeded();
    return (await _secure.read(key: nameKey))?.trim() ?? '';
  }

  static Future<void> syncFromUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _secure.write(key: nameKey, value: user.name.trim()),
      _secure.write(key: emailKey, value: user.email.trim()),
      _secure.write(key: phoneKey, value: user.phone.trim()),
      if (user.bloodGroup != null && user.bloodGroup!.trim().isNotEmpty)
        _secure.write(key: bloodKey, value: user.bloodGroup!.trim())
      else
        _secure.delete(key: bloodKey),
      prefs.remove(nameKey),
      prefs.remove(emailKey),
      prefs.remove(phoneKey),
      prefs.remove(bloodKey),
      // Local photo belongs to the previous account; use server photo after switch.
      prefs.remove(photoPathKey),
    ]);
  }
}
