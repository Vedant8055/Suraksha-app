import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/constants/api_constants.dart';
import 'package:suraksha_women_safety_app/core/network/dio_client.dart';

class AiChatResult {
  const AiChatResult({
    required this.reply,
    required this.source,
    required this.intent,
    required this.actions,
    required this.usedFallback,
    this.model,
    this.conversationId,
  });

  final String reply;
  final String source;
  final String intent;
  final List<String> actions;
  final bool usedFallback;
  final String? model;
  final String? conversationId;

  factory AiChatResult.fromJson(Map<String, dynamic> json) {
    final source = json['source']?.toString() ?? 'fallback';
    final actionsRaw = json['actions'];
    return AiChatResult(
      reply: (json['reply']?.toString() ?? '').trim(),
      source: source,
      intent: json['intent']?.toString() ?? 'general',
      actions: actionsRaw is List
          ? actionsRaw.map((item) => item.toString()).toList(growable: false)
          : const <String>[],
      usedFallback: json['usedFallback'] == true || source == 'fallback',
      model: json['model']?.toString(),
      conversationId: json['conversationId']?.toString(),
    );
  }
}

class AIService {
  final Dio _dio = DioClient().dio;

  Future<AiChatResult> getSafetyAdvice(String query) async {
    try {
      final response = await _dio.post(
        ApiConstants.aiChat,
        data: {'message': query},
      );
      final data = response.data;
      if (data is Map) {
        final result = AiChatResult.fromJson(Map<String, dynamic>.from(data));
        if (result.reply.isNotEmpty) return result;
      }
      return const AiChatResult(
        reply: 'I could not generate a reliable answer right now.',
        source: 'fallback',
        intent: 'general',
        actions: ['open_safety_map'],
        usedFallback: true,
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response!.data as Map)['message']?.toString()
          : null;
      return AiChatResult(
        reply: (message != null && message.trim().isNotEmpty)
            ? message.trim()
            : 'I am unable to connect right now. Showing limited offline guidance. Please check internet and try again.',
        source: 'fallback',
        intent: 'general',
        actions: const ['call_112', 'open_safety_map'],
        usedFallback: true,
      );
    } catch (_) {
      return const AiChatResult(
        reply:
            'I am unable to answer right now. Showing limited offline guidance. Please try again in a moment.',
        source: 'fallback',
        intent: 'general',
        actions: ['call_112', 'open_safety_map'],
        usedFallback: true,
      );
    }
  }

  Future<void> clearConversation() async {
    await _dio.delete(ApiConstants.aiConversation);
  }

  Future<void> sendFeedback({
    required String rating,
    String? comment,
  }) async {
    await _dio.post(
      ApiConstants.aiFeedback,
      data: {
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      },
    );
  }
}
