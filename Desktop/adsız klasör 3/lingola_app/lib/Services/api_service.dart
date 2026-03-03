import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lingola_app/Services/auth_service.dart';

/// Backend API base URL. Geliştirme için local IP; production'da değiştir.
const String kBaseApiUrl = 'http://192.168.1.8:3000';

/// Backend API istekleri. Token otomatik eklenir.
class ApiService {
  ApiService._();
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.instance.getIdToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<String?> _requireAuth() async {
    final token = await AuthService.instance.getIdToken();
    if (token == null) return 'Giriş yapılmamış. Önce giriş yapın.';
    return null;
  }

  ApiResult<T> _parseResponse<T>(http.Response response, T Function(dynamic data) parse) {
    try {
      final body = response.body.isEmpty ? null : jsonDecode(response.body) as Map<String, dynamic>?;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body?['data'];
        return ApiResult.ok(parse(data));
      }
      final err = body?['error'];
      final msg = err is Map ? (err['message'] as String?) : null;
      return ApiResult.fail(msg ?? 'HTTP ${response.statusCode}');
    } catch (_) {
      return ApiResult.fail('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// GET /api/users/me — giriş yapmış kullanıcı bilgisini döner.
  Future<ApiResult<String>> getMe() async {
    final authErr = await _requireAuth();
    if (authErr != null) return ApiResult.fail(authErr);
    try {
      final url = Uri.parse('$kBaseApiUrl/api/users/me');
      final response = await http.get(url, headers: await _authHeaders());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.ok(response.body);
      }
      return ApiResult.fail(
        'HTTP ${response.statusCode}: ${response.body.isEmpty ? "No body" : response.body}',
      );
    } catch (e) {
      return ApiResult.fail('İstek hatası: $e');
    }
  }

  /// GET /api/users/me/tracks — kullanıcının track ilerlemesi listesi.
  Future<ApiResult<List<Map<String, dynamic>>>> getUserTracks() async {
    final authErr = await _requireAuth();
    if (authErr != null) return ApiResult.fail(authErr);
    try {
      final url = Uri.parse('$kBaseApiUrl/api/users/me/tracks');
      final response = await http.get(url, headers: await _authHeaders());
      return _parseResponse(response, (data) {
        final list = data is Map && data['tracks'] != null
            ? data['tracks'] as List<dynamic>
            : (data is List ? data : <dynamic>[]);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (e) {
      return ApiResult.fail('İstek hatası: $e');
    }
  }

  /// PATCH /api/users/me/tracks/:trackId — track ilerlemesi güncelle (upsert).
  Future<ApiResult<Map<String, dynamic>>> patchUserTrack(
    int trackId, {
    int? progressPercent,
    int? completedWordsCount,
  }) async {
    final authErr = await _requireAuth();
    if (authErr != null) return ApiResult.fail(authErr);
    try {
      final url = Uri.parse('$kBaseApiUrl/api/users/me/tracks/$trackId');
      final body = <String, dynamic>{};
      if (progressPercent != null) body['progress_percent'] = progressPercent;
      if (completedWordsCount != null) body['completed_words_count'] = completedWordsCount;
      final response = await http.patch(
        url,
        headers: await _authHeaders(),
        body: body.isEmpty ? null : jsonEncode(body),
      );
      return _parseResponse(response, (data) => Map<String, dynamic>.from(data as Map));
    } catch (e) {
      return ApiResult.fail('İstek hatası: $e');
    }
  }

  /// GET /api/words — kelime listesi (opsiyonel: learning_track_id ile filtre).
  Future<ApiResult<List<Map<String, dynamic>>>> getWords({int? learningTrackId}) async {
    try {
      final query = learningTrackId != null ? '?learning_track_id=$learningTrackId' : '';
      final url = Uri.parse('$kBaseApiUrl/api/words$query');
      final response = await http.get(url, headers: await _authHeaders());
      return _parseResponse(response, (data) {
        final list = data is Map && data['words'] != null
            ? data['words'] as List<dynamic>
            : (data is List ? data : <dynamic>[]);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (e) {
      return ApiResult.fail('İstek hatası: $e');
    }
  }

  /// GET /api/learning-tracks — track listesi (opsiyonel: language_code ile filtre).
  Future<ApiResult<List<Map<String, dynamic>>>> getLearningTracks({String? languageCode}) async {
    try {
      final query = languageCode != null && languageCode.isNotEmpty
          ? '?language_code=${Uri.encodeComponent(languageCode)}'
          : '';
      final url = Uri.parse('$kBaseApiUrl/api/learning-tracks$query');
      final response = await http.get(url, headers: await _authHeaders());
      return _parseResponse(response, (data) {
        final list = data is Map && data['tracks'] != null
            ? data['tracks'] as List<dynamic>
            : (data is List ? data : <dynamic>[]);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (e) {
      return ApiResult.fail('İstek hatası: $e');
    }
  }

  /// POST /api/user-answers — kelime cevabı kaydet.
  Future<ApiResult<Map<String, dynamic>>> postUserAnswer({
    required int wordId,
    String? userAnswer,
    required bool isCorrect,
    String? questionType,
  }) async {
    final authErr = await _requireAuth();
    if (authErr != null) return ApiResult.fail(authErr);
    try {
      final url = Uri.parse('$kBaseApiUrl/api/user-answers');
      final body = <String, dynamic>{
        'word_id': wordId,
        'is_correct': isCorrect,
      };
      if (userAnswer != null) body['user_answer'] = userAnswer;
      if (questionType != null) body['question_type'] = questionType;
      final response = await http.post(
        url,
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );
      return _parseResponse(response, (data) => Map<String, dynamic>.from(data as Map));
    } catch (e) {
      return ApiResult.fail('İstek hatası: $e');
    }
  }
}

/// API sonucu: başarılı body veya hata mesajı.
class ApiResult<T> {
  const ApiResult._({this.data, this.error});
  factory ApiResult.ok(T data) => ApiResult._(data: data);
  factory ApiResult.fail(String error) => ApiResult._(error: error);

  final T? data;
  final String? error;
  bool get isOk => error == null;
}

