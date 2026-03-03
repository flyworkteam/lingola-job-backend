import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingola_app/Repositories/user_repository.dart';

/// Backend kullanıcı işlemleri (user_tracks, user_answers, getMe) için provider.
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
