import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingola_app/src/state/saved_words_store.dart';

/// Kayıtlı kelimeler için global provider.
/// Uygulama genelinde `savedWordsProvider` ile erişilir.
final savedWordsProvider =
    ChangeNotifierProvider<SavedWordsNotifier>((ref) => SavedWordsNotifier());

