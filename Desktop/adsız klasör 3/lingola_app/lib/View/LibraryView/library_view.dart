import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/Riverpod/Controllers/all_controllers.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/dismiss_keyboard.dart';

/// Library sayfası: header, arama + filtre butonu, Library / Dictionary sekmeleri.
/// Sekme, filtre ve favori durumu Riverpod [libraryControllerProvider] ile yönetilir.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({
    super.key,
    this.onBackTap,
    this.initialTabIndex,
    this.onInitialTabHandled,
  });

  final VoidCallback? onBackTap;
  /// Ana sayfadan Dictionary kartı ile geldiğinde açılacak sekme (1 = Dictionary).
  final int? initialTabIndex;
  final VoidCallback? onInitialTabHandled;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const double _headerExpandedHeight = 200;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(libraryControllerProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
    if (widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(libraryControllerProvider.notifier)
              .setTab(widget.initialTabIndex!);
        }
        widget.onInitialTabHandled?.call();
      });
    }
  }

  @override
  void didUpdateWidget(LibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex != oldWidget.initialTabIndex) {
      ref
          .read(libraryControllerProvider.notifier)
          .setTab(widget.initialTabIndex!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInitialTabHandled?.call();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryControllerProvider);
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FC),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: _headerExpandedHeight,
                pinned: false,
                floating: false,
                stretch: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: const Color(0xFFF2F5FC),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(child: _buildSearchInput()),
                            const SizedBox(width: AppSpacing.sm),
                            _buildFilterButton(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildTabButtons(),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: state.selectedTabIndex == 0
                    ? _buildLibrarySliverList(state)
                    : _buildDictionarySliverList(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Profil sayfasındaki gibi: geri butonu + başlık.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onBackTap ?? () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Transform.scale(
                  scaleX: -1,
                  child: SvgPicture.asset(
                    'assets/icons/icon_arrow_right.svg',
                    width: 20,
                    height: 9,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF000000),
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Library',
            style: AppTypography.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Word...',
          hintStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SvgPicture.asset(
              'assets/icons/icon_search_library.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                AppColors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: 14,
            bottom: 10,
          ),
        ),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  /// Attığın Button.svg ile aynı stil: mavi yuvarlak köşe, filtre ikonu.
  Widget _buildFilterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showFilterBottomSheet,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 52,
          height: 37,
          child: SvgPicture.asset(
            'assets/icons/icon_filter_button.svg',
            width: 52,
            height: 37,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final current = ref.read(libraryControllerProvider);
        return _LibraryFilterBottomSheet(
          initialSelectedIds: Set.from(current.selectedFilterIds),
          onSave: (selectedIds) {
            ref
                .read(libraryControllerProvider.notifier)
                .setFilters(selectedIds);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildTabButtons() {
    final state = ref.watch(libraryControllerProvider);
    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            label: 'Library',
            isSelected: state.selectedTabIndex == 0,
            onTap: () =>
                ref.read(libraryControllerProvider.notifier).setTab(0),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildTabButton(
            label: 'Dictionary',
            isSelected: state.selectedTabIndex == 1,
            onTap: () =>
                ref.read(libraryControllerProvider.notifier).setTab(1),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBrand
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryDropShadow.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primaryBrand,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const List<_LibraryWordItem> _libraryWords = [
    _LibraryWordItem(word: 'Arbitrage', category: 'Finance', translation: 'Arbitraj'),
    _LibraryWordItem(word: 'Synergy', category: 'Business', translation: 'Sinerji'),
    _LibraryWordItem(word: 'Scalability', category: 'Technology', translation: 'Ölçeklenebilirlik'),
    _LibraryWordItem(word: 'Heuristic', category: 'Psychology', translation: 'Heuristic'),
  ];

  static const List<_DictionaryWordItem> _dictionaryWords = [
    _DictionaryWordItem(word: 'Acquisition', translation: 'Satın alma, devralma'),
    _DictionaryWordItem(word: 'Agenda', translation: 'Gündem, yapılacaklar listesi'),
    _DictionaryWordItem(word: 'Allocate', translation: 'Tahsis etmek, ayırmak'),
    _DictionaryWordItem(word: 'Asset', translation: 'Varlık, kıymet'),
    _DictionaryWordItem(word: 'Appraisal', translation: 'Değerleme, kıymet takdiri'),
    _DictionaryWordItem(word: 'Audit', translation: 'Denetim, teftiş'),
    _DictionaryWordItem(word: 'Arbitrage', translation: 'Arbitraj'),
    _DictionaryWordItem(word: 'Synergy', translation: 'Sinerji'),
    _DictionaryWordItem(word: 'Scalability', translation: 'Ölçeklenebilirlik'),
    _DictionaryWordItem(word: 'Heuristic', translation: 'Heuristic'),
  ];

  List<_LibraryWordItem> _filteredWords(LibraryState state) {
    final fromStatic = state.selectedFilterIds.isEmpty
        ? _libraryWords
        : _libraryWords
            .where((item) => state.selectedFilterIds.contains(item.category))
            .toList();
    final showSaved = state.selectedFilterIds.isEmpty ||
        state.selectedFilterIds.contains('Saved');
    if (!showSaved) return fromStatic;
    final fromDictionary = state.favoritedDictionaryWords.map((word) {
      final match = _dictionaryWords.where((e) => e.word == word).toList();
      final translation = match.isEmpty ? '' : match.first.translation;
      return _LibraryWordItem(
        word: word,
        category: 'Saved',
        translation: translation,
      );
    }).toList();
    return [...fromStatic, ...fromDictionary];
  }

  Widget _buildLibrarySliverList(LibraryState state) {
    final words = _filteredWords(state);
    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          '${words.length} Words',
          style: AppTypography.title.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...words.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LibraryWordCard(
              item: item,
              isFavorited:
                  state.favoritedDictionaryWords.contains(item.word),
              onStarTap: state.favoritedDictionaryWords.contains(item.word)
                  ? () {
                      ref
                          .read(libraryControllerProvider.notifier)
                          .toggleFavorite(item.word);
                    }
                  : null,
            ),
        )),
        const SizedBox(height: 120),
      ]),
    );
  }

  List<_DictionaryWordItem> _filteredDictionaryWords(LibraryState state) {
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _dictionaryWords;
    return _dictionaryWords
        .where((item) =>
            item.word.toLowerCase().contains(q) ||
            item.translation.toLowerCase().contains(q))
        .toList();
  }

  Widget _buildDictionarySliverList(LibraryState state) {
    final words = _filteredDictionaryWords(state);
    return SliverList(
      delegate: SliverChildListDelegate([
        Text(
          '${words.length} Words',
          style: AppTypography.title.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...words.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _DictionaryWordCard(
            item: item,
            isFavorited:
                state.favoritedDictionaryWords.contains(item.word),
            onStarTap: () {
              ref
                  .read(libraryControllerProvider.notifier)
                  .toggleFavorite(item.word);
            },
          ),
        )),
        const SizedBox(height: 120),
      ]),
    );
  }
}

class _DictionaryWordItem {
  const _DictionaryWordItem({
    required this.word,
    required this.translation,
  });
  final String word;
  final String translation;
}

class _LibraryWordItem {
  const _LibraryWordItem({
    required this.word,
    required this.category,
    required this.translation,
  });
  final String word;
  final String category;
  final String translation;
}

/// Beyaz kart: kelime, kategori etiketi, çeviri, ses ve yıldız ikonu.
class _LibraryWordCard extends StatelessWidget {
  const _LibraryWordCard({
    required this.item,
    this.isFavorited = false,
    this.onStarTap,
  });

  final _LibraryWordItem item;
  final bool isFavorited;
  final VoidCallback? onStarTap;

  @override
  Widget build(BuildContext context) {
    final starWidget = Transform.translate(
      offset: const Offset(0, -4),
      child: SvgPicture.asset(
        'assets/icons/yıldız.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryBrand,
          BlendMode.srcIn,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      item.word,
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0575E6).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: AppTypography.label.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.translation,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icons/ses.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9B9B9B),
                    BlendMode.srcIn,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              if (onStarTap != null)
                GestureDetector(
                  onTap: onStarTap,
                  behavior: HitTestBehavior.opaque,
                  child: starWidget,
                )
              else
                starWidget,
            ],
          ),
        ],
      ),
    );
  }
}

/// Dictionary kelime kartı: kelime, çeviri, ses ve yıldız ikonu.
class _DictionaryWordCard extends StatelessWidget {
  const _DictionaryWordCard({
    required this.item,
    required this.isFavorited,
    required this.onStarTap,
  });

  final _DictionaryWordItem item;
  final bool isFavorited;
  final VoidCallback onStarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.word,
                  style: AppTypography.title.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.translation,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icons/ses.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9B9B9B),
                    BlendMode.srcIn,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              GestureDetector(
                onTap: onStarTap,
                behavior: HitTestBehavior.opaque,
                child: Transform.translate(
                    offset: const Offset(0, -4),
                    child: SvgPicture.asset(
                      'assets/icons/yıldız.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isFavorited ? AppColors.primaryBrand : const Color(0xFFD9D9D9),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Filtre bottom sheet: üstte tutacak çizgi, pill etiketler, Save butonu.
class _LibraryFilterBottomSheet extends StatefulWidget {
  const _LibraryFilterBottomSheet({
    required this.initialSelectedIds,
    required this.onSave,
  });

  final Set<String> initialSelectedIds;
  final void Function(Set<String> selectedIds) onSave;

  @override
  State<_LibraryFilterBottomSheet> createState() => _LibraryFilterBottomSheetState();
}

class _LibraryFilterBottomSheetState extends State<_LibraryFilterBottomSheet> {
  static const List<String> _filterCategories = [
    'Saved',
    'Psychology',
    'Business',
    'Finance',
    'Technology',
    'Marketing',
    'Engineering',
    'Medicine',
    'Legal',
  ];

  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üstte tutacak çizgi (grab handle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Pill etiketler
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _filterCategories.map((category) {
                  final isSelected = _selectedIds.contains(category);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        final next = Set<String>.from(_selectedIds);
                        if (isSelected) {
                          next.remove(category);
                        } else {
                          next.add(category);
                        }
                        _selectedIds = next;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBrand : AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBrand
                              : AppColors.outline.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        category,
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Save butonu
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onSave(_selectedIds),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save',
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

