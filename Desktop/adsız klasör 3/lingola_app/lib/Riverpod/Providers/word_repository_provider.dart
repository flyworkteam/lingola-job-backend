import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingola_app/Repositories/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) => WordRepository());
