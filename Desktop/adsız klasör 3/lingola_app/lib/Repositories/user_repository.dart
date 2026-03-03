import 'package:lingola_app/Services/api_service.dart';

/// Kullanıcı ile ilgili backend işlemlerini soyutlayan repository.
/// UI ve controller katmanı doğrudan [ApiService] yerine bu katmanı kullanır.
class UserRepository {
  UserRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;

  /// Backend'in çalışıp çalışmadığını kontrol etmek için basit test.
  Future<ApiResult<String>> testBackend() {
    return _api.getMe();
  }

  /// Kullanıcının track bazlı ilerlemesini getirir (user_tracks).
  Future<ApiResult<List<Map<String, dynamic>>>> getUserTracks() {
    return _api.getUserTracks();
  }

  /// Seçilen track için ilerlemeyi günceller veya oluşturur (user_tracks).
  /// Track'e girildiğinde veya ilerleme değiştiğinde çağrılır.
  Future<ApiResult<Map<String, dynamic>>> updateTrackProgress(
    int trackId, {
    int? progressPercent,
    int? completedWordsCount,
  }) {
    return _api.patchUserTrack(
      trackId,
      progressPercent: progressPercent,
      completedWordsCount: completedWordsCount,
    );
  }

  /// Kelime sorusu cevabını backend'e kaydeder (user_answers).
  Future<ApiResult<Map<String, dynamic>>> submitUserAnswer({
    required int wordId,
    String? userAnswer,
    required bool isCorrect,
    String? questionType,
  }) {
    return _api.postUserAnswer(
      wordId: wordId,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      questionType: questionType,
    );
  }
}

