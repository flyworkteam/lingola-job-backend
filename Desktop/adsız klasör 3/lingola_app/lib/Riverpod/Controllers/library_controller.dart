import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Library ekranının sekme, filtre ve favori durumunu tutan state modeli.
@immutable
class LibraryState {
  const LibraryState({
    this.selectedTabIndex = 0,
    this.selectedFilterIds = const {'Psychology', 'Technology', 'Saved'},
    this.favoritedDictionaryWords = const {},
    this.searchQuery = '',
  });

  final int selectedTabIndex; // 0: Library, 1: Dictionary
  final Set<String> selectedFilterIds;
  final Set<String> favoritedDictionaryWords;
  final String searchQuery;

  LibraryState copyWith({
    int? selectedTabIndex,
    Set<String>? selectedFilterIds,
    Set<String>? favoritedDictionaryWords,
    String? searchQuery,
  }) {
    return LibraryState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedFilterIds: selectedFilterIds ?? this.selectedFilterIds,
      favoritedDictionaryWords:
          favoritedDictionaryWords ?? this.favoritedDictionaryWords,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Library ekranı için Riverpod controller.
final libraryControllerProvider =
    StateNotifierProvider<LibraryController, LibraryState>(
  (ref) => LibraryController(),
);

class LibraryController extends StateNotifier<LibraryState> {
  LibraryController() : super(const LibraryState());

  void setTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void setFilters(Set<String> ids) {
    state = state.copyWith(selectedFilterIds: ids);
  }

  void toggleFavorite(String word) {
    final next = Set<String>.from(state.favoritedDictionaryWords);
    if (next.contains(word)) {
      next.remove(word);
    } else {
      next.add(word);
    }
    state = state.copyWith(favoritedDictionaryWords: next);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

