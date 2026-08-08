import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/api_service.dart';

/// Notifications API — keeps Dio out of UI screens.
class NotificationsRepository {
  NotificationsRepository({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<Map<String, dynamic>>> listActive() async {
    final response = await _api.get(ApiConstants.notifications);
    final data = response.data;
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .toList(growable: false);
  }

  Future<void> acknowledge(String notificationId) async {
    if (notificationId.isEmpty) return;
    await _api.post(ApiConstants.notificationAck(notificationId));
  }
}
