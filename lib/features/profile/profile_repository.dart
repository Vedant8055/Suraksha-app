import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/api_service.dart';

/// Profile API calls — keeps Dio out of [ProfileScreen].
class ProfileRepository {
  ProfileRepository({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Map<String, dynamic>?> patchProfile(Map<String, dynamic> data) async {
    final response = await _api.patch(ApiConstants.profile, data: data);
    final body = response.data;
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }

  Future<Map<String, dynamic>?> uploadPhoto(String photoPath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(photoPath),
    });
    final response = await _api.post(
      '${ApiConstants.profile}/photo',
      data: form,
    );
    final body = response.data;
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }
}
