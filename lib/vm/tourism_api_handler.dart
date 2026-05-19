import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

/// FastAPI 서버와 통신하는 전담 계층이다.
///
/// Flutter 앱은 배포 환경별 FastAPI 주소를 주입받고, 서버가 제공하는
/// TourAPI·Ollama·Chroma·Transformer 결과를 같은 HTTP 계약으로 사용한다.
class TourismApiHandler {
  TourismApiHandler({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> health(String apiBase) async {
    final response = await _client
        .get(Uri.parse('${_normalized(apiBase)}/health'))
        .timeout(const Duration(seconds: 4));
    return _decodeObject(response);
  }

  Future<List<Map<String, dynamic>>> fetchRegions(String apiBase) async {
    final response = await _client
        .get(Uri.parse('${_normalized(apiBase)}/tourism/regions'))
        .timeout(const Duration(seconds: 4));
    final payload = _decodeObject(response);
    final areas = payload['areas'];
    if (areas is! List) return [];
    return areas
        .whereType<Map>()
        .map((area) => Map<String, dynamic>.from(area))
        .toList();
  }

  Future<Map<String, dynamic>> chat({
    required String apiBase,
    required String message,
    required String sessionId,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${_normalized(apiBase)}/tourism/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message, 'session_id': sessionId}),
        )
        .timeout(const Duration(seconds: 25));
    return _decodeObject(response);
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    final payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (payload is! Map<String, dynamic>) {
      throw TourismApiException(response.statusCode, '응답 형식이 올바르지 않습니다.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = payload['detail'];
      final message = detail is Map
          ? '${detail['message'] ?? '요청 처리 중 문제가 발생했습니다.'}'
          : '${detail ?? '요청 처리 중 문제가 발생했습니다.'}';
      throw TourismApiException(response.statusCode, message);
    }
    return payload;
  }

  String _normalized(String apiBase) {
    return AppConfig.normalizeApiBase(apiBase);
  }
}

class TourismApiException implements Exception {
  const TourismApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
