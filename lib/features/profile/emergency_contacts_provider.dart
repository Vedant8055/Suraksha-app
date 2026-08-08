import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/features/profile/profile_session_cache.dart';
import 'package:suraksha_women_safety_app/localization/l10n_helper.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final int priority;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.priority = 1,
  });

  bool get isPrimary => priority == 0;

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    int? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'phone': phone,
    'relation': relation,
    'priority': priority,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relation: json['relation']?.toString() ?? l10nSync('emergencyContactDefault'),
      priority: (json['priority'] as num?)?.toInt() ?? 1,
    );
  }

  EmergencyContact normalized() {
    return EmergencyContact(
      id: id,
      name: name.trim(),
      phone: normalizePhoneNumber(phone),
      relation: relation.trim().isEmpty
          ? l10nSync('emergencyContactDefault')
          : relation.trim(),
      priority: priority,
    );
  }

  static String normalizePhoneNumber(String value) {
    final trimmed = value.trim();
    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return hasPlus ? '+$digits' : digits;
  }

  static bool isValidIndianMobile(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }
}

final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, List<EmergencyContact>>(
      (ref) => EmergencyContactsNotifier(),
    );

class EmergencyContactsNotifier extends StateNotifier<List<EmergencyContact>> {
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  final Dio _dio = DioClient().dio;
  final bool _syncEnabled;
  String? _userId;
  Future<void>? _loadContactsFuture;
  Future<void>? _bindUserFuture;

  EmergencyContactsNotifier({bool syncEnabled = true})
    : _syncEnabled = syncEnabled,
      super(const []);

  String? get activeUserId => _userId;

  Future<void> resetForLogout() async {
    final previousUserId = _userId;
    _userId = null;
    _loadContactsFuture = null;
    _bindUserFuture = null;
    state = const [];
    await _scrubLocalContacts(previousUserId);
  }

  Future<void> bindUser(String userId) async {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return;

    final inFlight = _bindUserFuture;
    if (inFlight != null) {
      await inFlight;
      if (_userId == normalizedUserId) {
        if (state.isNotEmpty) return;
        await loadContacts();
        return;
      }
    }

    // Same user: never wipe an already-loaded list; just refresh if empty.
    if (_userId == normalizedUserId) {
      if (state.isNotEmpty) return;
      await loadContacts();
      return;
    }

    final bindFuture = _bindUserInternal(normalizedUserId);
    _bindUserFuture = bindFuture;
    try {
      await bindFuture;
    } finally {
      if (identical(_bindUserFuture, bindFuture)) {
        _bindUserFuture = null;
      }
    }
  }

  Future<void> _bindUserInternal(String userId) async {
    _userId = userId;
    _loadContactsFuture = null;
    state = const [];
    await loadContacts();
  }

  Future<void> loadContacts() {
    if (_userId == null || _userId!.isEmpty) {
      return Future<void>.value();
    }
    return _loadContactsFuture ??= _loadContacts().whenComplete(() {
      _loadContactsFuture = null;
    });
  }

  Future<void> _loadContacts() async {
    final local = _withoutLegacyDefaultContacts(await _loadLocalContacts());
    if (local.isNotEmpty) {
      state = _mergeContacts(state, local);
      await _persistLocalContacts(state);
    }
    if (!_syncEnabled) return;

    try {
      final response = await _dio.get(ApiConstants.contacts);
      final remote = _decodeContactsResponse(response.data);
      // Prefer local/offline edits over remote when phone numbers match.
      state = _mergeContacts(remote, [...state, ...local]);
      await _persistLocalContacts(state);
    } catch (error, stack) {
      developer.log(
        'Emergency contacts remote sync failed',
        name: 'EmergencyContacts',
        error: error,
        stackTrace: stack,
      );
      if (state.isEmpty && local.isEmpty) {
        state = const [];
        await _persistLocalContacts(state);
      }
    }
  }

  /// Waits for any in-flight bind/load, then reports whether contacts exist.
  ///
  /// Returns `null` when the user is not bound yet, so callers can avoid
  /// showing a false "missing contacts" reminder during startup races.
  Future<bool?> hasSavedContactsResolved() async {
    final bind = _bindUserFuture;
    if (bind != null) await bind;

    if (_userId == null || _userId!.isEmpty) return null;
    if (state.isNotEmpty) return true;

    await loadContacts();
    return state.isNotEmpty;
  }

  Future<bool> hasSavedContacts() async {
    return (await hasSavedContactsResolved()) ?? false;
  }

  Future<bool> addContact(EmergencyContact contact) async {
    final normalizedContact = contact.normalized();
    if (normalizedContact.name.isEmpty ||
        !EmergencyContact.isValidIndianMobile(normalizedContact.phone)) {
      throw ArgumentError('A valid Indian mobile number is required.');
    }

    final contactKey = _contactKey(normalizedContact);
    final alreadySaved = state.any(
      (current) => _contactKey(current) == contactKey,
    );
    if (alreadySaved) return false;

    final localContact = EmergencyContact(
      id: normalizedContact.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : normalizedContact.id,
      name: normalizedContact.name,
      phone: normalizedContact.phone,
      relation: normalizedContact.relation,
      priority: normalizedContact.priority,
    );

    state = _mergeContacts(state, [localContact]);
    await _persistLocalContacts(state);
    if (!_syncEnabled) return true;

    unawaited(_syncAddedContact(localContact));
    return true;
  }

  Future<void> _syncAddedContact(EmergencyContact localContact) async {
    try {
      final response = await _dio.post(
        ApiConstants.contacts,
        data: {
          'name': localContact.name,
          'phone': localContact.phone,
          'relation': localContact.relation,
          'priority': localContact.priority,
        },
      );
      final created = _decodeContactResponse(response.data).normalized();
      if (created.name.isEmpty || created.phone.isEmpty) return;
      state = [
        for (final current in state)
          if (current.id == localContact.id) created else current,
      ];
      await _persistLocalContacts(state);
    } catch (error, stack) {
      developer.log(
        'Emergency contact create sync failed',
        name: 'EmergencyContacts',
        error: error,
        stackTrace: stack,
      );
      // Keep local data as source of truth when offline/API fails.
    }
  }

  static bool isServerContactId(String id) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(id);
  }

  Future<bool> updateContact(EmergencyContact contact) async {
    final normalizedContact = contact.normalized();
    if (normalizedContact.name.isEmpty ||
        !EmergencyContact.isValidIndianMobile(normalizedContact.phone)) {
      throw ArgumentError('A valid Indian mobile number is required.');
    }

    final contactKey = _contactKey(normalizedContact);
    final duplicateExists = state.any(
      (current) =>
          current.id != normalizedContact.id &&
          _contactKey(current) == contactKey,
    );
    if (duplicateExists) return false;

    state = [
      for (final current in state)
        if (current.id == normalizedContact.id) normalizedContact else current,
    ];
    await _persistLocalContacts(state);
    if (!_syncEnabled) return true;

    try {
      if (!isServerContactId(normalizedContact.id)) {
        // Local-only id: create on server instead of patching a fake id.
        await _syncAddedContact(normalizedContact);
        return true;
      }

      final response = await _dio.patch(
        '${ApiConstants.contacts}/${normalizedContact.id}',
        data: {
          'name': normalizedContact.name,
          'phone': normalizedContact.phone,
          'relation': normalizedContact.relation,
          'priority': normalizedContact.priority,
        },
      );
      final updated = _decodeContactResponse(response.data).normalized();
      state = [
        for (final current in state)
          if (current.id == updated.id || current.id == normalizedContact.id)
            updated
          else
            current,
      ];
      await _persistLocalContacts(state);
    } catch (error, stack) {
      developer.log(
        'Emergency contact update sync failed',
        name: 'EmergencyContacts',
        error: error,
        stackTrace: stack,
      );
      // Keep local update when backend sync fails.
    }
    return true;
  }

  Future<void> setPrimary(String contactId) async {
    final updated = [
      for (final contact in state)
        contact.copyWith(priority: contact.id == contactId ? 0 : 1),
    ]..sort((a, b) => a.priority.compareTo(b.priority));
    state = updated;
    await _persistLocalContacts(state);
    if (!_syncEnabled) return;
    for (final contact in updated) {
      if (!isServerContactId(contact.id)) continue;
      unawaited(_syncContactPriority(contact));
    }
  }

  Future<void> _syncContactPriority(EmergencyContact contact) async {
    try {
      await _dio.patch(
        '${ApiConstants.contacts}/${contact.id}',
        data: {'priority': contact.priority},
      );
    } catch (error, stack) {
      developer.log(
        'Emergency contact priority sync failed',
        name: 'EmergencyContacts',
        error: error,
        stackTrace: stack,
      );
    }
  }

  Future<void> deleteContact(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _persistLocalContacts(state);
    if (!_syncEnabled) return;
    if (!isServerContactId(id)) return;

    try {
      await _dio.delete('${ApiConstants.contacts}/$id');
    } catch (error, stack) {
      developer.log(
        'Emergency contact delete sync failed',
        name: 'EmergencyContacts',
        error: error,
        stackTrace: stack,
      );
      // Keep local delete when backend sync fails.
    }
  }

  Future<List<EmergencyContact>> _loadLocalContacts() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return const [];

    final secureKey = ProfileSessionCache.emergencyContactsKeyFor(userId);
    final secureRaw = await _secure.read(key: secureKey);
    if (secureRaw != null && secureRaw.isNotEmpty) {
      return _decodeStoredContacts(secureRaw);
    }

    // One-time migrate from plaintext SharedPreferences, then scrub prefs.
    final prefs = await SharedPreferences.getInstance();
    final prefsRaw = prefs.getString(secureKey);
    if (prefsRaw == null || prefsRaw.isEmpty) {
      await prefs.remove(ProfileSessionCache.legacyEmergencyContactsKey);
      return const [];
    }

    final migrated = _decodeStoredContacts(prefsRaw);
    if (migrated.isNotEmpty) {
      await _secure.write(
        key: secureKey,
        value: jsonEncode(migrated.map((c) => c.toJson()).toList()),
      );
    }
    await prefs.remove(secureKey);
    await prefs.remove(ProfileSessionCache.legacyEmergencyContactsKey);
    return migrated;
  }

  Future<void> _persistLocalContacts(List<EmergencyContact> contacts) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    final key = ProfileSessionCache.emergencyContactsKeyFor(userId);
    final raw = jsonEncode(contacts.map((c) => c.toJson()).toList());
    await _secure.write(key: key, value: raw);

    // Scrub any leftover plaintext prefs cache.
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(key),
      prefs.remove(ProfileSessionCache.legacyEmergencyContactsKey),
    ]);
  }

  Future<void> _scrubLocalContacts(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ProfileSessionCache.legacyEmergencyContactsKey);
    if (userId == null || userId.isEmpty) return;
    final key = ProfileSessionCache.emergencyContactsKeyFor(userId);
    await Future.wait([
      _secure.delete(key: key),
      prefs.remove(key),
    ]);
  }

  List<EmergencyContact> _decodeStoredContacts(String raw) {
    try {
      if (raw.trimLeft().startsWith('[')) {
        final decoded = jsonDecode(raw);
        if (decoded is! List) return const [];

        return decoded
            .whereType<Map>()
            .map((item) => EmergencyContact.fromJson(_stringKeyedMap(item)))
            .map((contact) => contact.normalized())
            .where(
              (contact) => contact.name.isNotEmpty && contact.phone.isNotEmpty,
            )
            .toList();
      }

      return raw.split('\n').where((e) => e.trim().isNotEmpty).map((line) {
        final parts = line.split('|');
        return EmergencyContact(
          id: parts.isNotEmpty ? parts[0] : '',
          name: parts.length > 1 ? parts[1] : '',
          phone: parts.length > 2 ? parts[2] : '',
          relation: parts.length > 3 ? parts[3] : 'Emergency Contact',
        ).normalized();
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  List<EmergencyContact> _mergeContacts(
    List<EmergencyContact> secondary,
    List<EmergencyContact> preferred,
  ) {
    final byKey = <String, EmergencyContact>{};
    // Preferred entries overwrite secondary for the same phone/id key.
    for (final contact in [...secondary, ...preferred]) {
      final normalizedContact = contact.normalized();
      if (normalizedContact.name.isEmpty || normalizedContact.phone.isEmpty) {
        continue;
      }
      final key = _contactKey(normalizedContact);
      if (key.isEmpty) continue;
      byKey[key] = normalizedContact;
    }
    final contacts = _withoutLegacyDefaultContacts(byKey.values.toList());
    if (contacts.isNotEmpty && !contacts.any((contact) => contact.isPrimary)) {
      contacts[0] = contacts[0].copyWith(priority: 0);
    }
    contacts.sort((a, b) => a.priority.compareTo(b.priority));
    return contacts;
  }

  String _contactKey(EmergencyContact contact) {
    final phone = EmergencyContact.normalizePhoneNumber(contact.phone);
    if (phone.isNotEmpty) return 'phone:$phone';
    if (contact.id.isNotEmpty) return 'id:${contact.id}';
    return '';
  }

  List<EmergencyContact> _withoutLegacyDefaultContacts(
    List<EmergencyContact> contacts,
  ) {
    const legacyPhones = {'7020094073', '9359264978', '8462969160'};
    return contacts.where((contact) {
      final phone = contact.phone.replaceAll(RegExp(r'\D'), '');
      return !contact.id.startsWith('default_') &&
          !legacyPhones.contains(phone);
    }).toList();
  }

  List<EmergencyContact> _decodeContactsResponse(Object? data) {
    final rawContacts = switch (data) {
      final List<dynamic> list => list,
      final Map map when map['contacts'] is List => map['contacts'] as List,
      final Map map when map['data'] is List => map['data'] as List,
      final Map map when map['emergencyContacts'] is List =>
        map['emergencyContacts'] as List,
      _ => const [],
    };

    return rawContacts
        .whereType<Map>()
        .map((item) => EmergencyContact.fromJson(_stringKeyedMap(item)))
        .toList();
  }

  EmergencyContact _decodeContactResponse(Object? data) {
    final rawContact = switch (data) {
      final Map map when map['contact'] is Map => map['contact'] as Map,
      final Map map when map['data'] is Map => map['data'] as Map,
      final Map map => map,
      _ => const <String, dynamic>{},
    };
    return EmergencyContact.fromJson(_stringKeyedMap(rawContact));
  }

  static Map<String, dynamic> _stringKeyedMap(Map map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }
}
