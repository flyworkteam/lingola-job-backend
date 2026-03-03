import 'package:lingola_app/Services/api_service.dart';

/// Kelime ve learning track verilerini backend'den çeker.
class WordRepository {
  WordRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;

  /// Belirli bir track veya tüm kelimeleri getirir.
  Future<ApiResult<List<Map<String, dynamic>>>> getWords({int? learningTrackId}) {
    return _api.getWords(learningTrackId: learningTrackId);
  }

  /// Learning track listesini getirir (opsiyonel dil filtresi).
  Future<ApiResult<List<Map<String, dynamic>>>> getLearningTracks({String? languageCode}) {
    return _api.getLearningTracks(languageCode: languageCode);
  }
}
