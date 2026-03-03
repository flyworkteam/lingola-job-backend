import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/View/HomeView/home_view.dart';
import 'package:lingola_app/View/LearnTabView/learn_tab_view.dart';
import 'package:lingola_app/View/LibraryView/library_view.dart';
import 'package:lingola_app/View/ProfileView/profile_view.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ana kabuk: ortak alt navigasyon bar + seçilen sekme.
/// Kayıtlı kelime sayısı [savedWordsProvider] ile reaktif okunur.
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.isPremium = false,
  });

  final int initialIndex;
  final bool isPremium;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _currentIndex;
  String _userName = 'Jhon Doe';
  String? _pendingLearnRoute;
  int? _pendingLibraryTabIndex;

  static const List<AppNavItem> _navItems = [
    AppNavItem(iconAsset: 'assets/icons/nav_home.svg', label: 'Home'),
    AppNavItem(iconAsset: 'assets/icons/nav_learn.svg', label: 'Learn'),
    AppNavItem(iconAsset: 'assets/icons/nav_library.svg', label: 'Library'),
    AppNavItem(iconAsset: 'assets/icons/nav_profil.svg', label: 'Profile'),
  ];

  static const String _keyProfileName = 'profile_name';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadSavedProfileName();
  }

  int get _savedWordsCount => ref.watch(savedWordsProvider).count;

  Future<void> _loadSavedProfileName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_keyProfileName);
    if (savedName != null && savedName.isNotEmpty && mounted) {
      setState(() => _userName = savedName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Stack(
        children: [
          // Sayfa tam ekran; içerik barın arkasına kadar uzanır, beyaz boşluk yok
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(
                  userName: _userName,
                  isPremium: widget.isPremium,
                  savedWordsCount: _savedWordsCount,
                  onLearnNewWordsTap: () => setState(() {
                    _currentIndex = 1;
                    _pendingLearnRoute = '/word_practice';
                  }),
                  onSavedWordsTap: () => setState(() {
                    _currentIndex = 1;
                    _pendingLearnRoute = '/saved_word';
                  }),
                  onDictionaryTap: () => setState(() {
                    _currentIndex = 2;
                    _pendingLibraryTabIndex = 1;
                  }),
                ),
                LearnTab(
                  userName: _userName,
                  savedWordsCount: _savedWordsCount,
                  onBackTap: () => setState(() => _currentIndex = 0),
                  pendingRoute: _pendingLearnRoute,
                  onPendingRouteHandled: () => setState(() => _pendingLearnRoute = null),
                ),
                LibraryScreen(
                  onBackTap: () => setState(() => _currentIndex = 0),
                  initialTabIndex: _pendingLibraryTabIndex,
                  onInitialTabHandled: () => setState(() => _pendingLibraryTabIndex = null),
                ),
                ProfileScreen(
                  userName: _userName,
                  isPremium: widget.isPremium,
                  onUserNameChanged: (name) => setState(() => _userName = name),
                  onBackTap: () => setState(() => _currentIndex = 0),
                  onNotificationsTap: () {
                    context.push(
                      AppPaths.notifications,
                      extra: NotificationsRouteArgs(isPremium: widget.isPremium),
                    );
                  },
                ),
              ],
            ),
          ),
          // Pill bar altta, sayfanın üzerinde
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavBar(
              items: _navItems,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Center(
        child: Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

