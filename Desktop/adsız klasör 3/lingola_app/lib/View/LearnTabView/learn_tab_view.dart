import 'package:flutter/material.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/View/DailyTestView/daily_test_view.dart';
import 'package:lingola_app/View/LearnView/learn_view.dart';
import 'package:lingola_app/View/ReadingTestView/reading_test_view.dart';
import 'package:lingola_app/View/SavedWordView/saved_word_view.dart';
import 'package:lingola_app/View/WordPracticeView/word_practice_view.dart';

/// Learn sekmesi için iç navigator.
/// Amaç: Learn içindeki alt sayfalara geçerken `MainScreen`'deki ortak alt barın görünür kalması.
class LearnTab extends StatefulWidget {
  const LearnTab({
    super.key,
    this.userName = 'Jhon Doe',
    this.savedWordsCount = 0,
    this.onBackTap,
    this.pendingRoute,
    this.onPendingRouteHandled,
  });

  final String userName;
  final int savedWordsCount;
  final VoidCallback? onBackTap;
  /// Ana sayfadan (Home) Learn New Words ile geldiğinde açılacak route.
  final String? pendingRoute;
  /// pendingRoute push edildikten sonra parent'ın temizlemesi için.
  final VoidCallback? onPendingRouteHandled;

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void didUpdateWidget(LearnTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pendingRoute != null && widget.pendingRoute != oldWidget.pendingRoute) {
      final route = widget.pendingRoute!;
      final onHandled = widget.onPendingRouteHandled;
      final onBackTap = widget.onBackTap;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = route == '/word_practice'
            ? const LearnWordPracticeArgs(returnToHomeOnPop: true)
            : route == '/saved_word'
                ? const LearnSavedWordArgs(returnToHomeOnPop: true)
                : null;
        _navigatorKey.currentState?.pushNamed(route, arguments: args).then((result) {
          onHandled?.call();
          if (result == true && onBackTap != null) {
            onBackTap();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final nav = _navigatorKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
          return;
        }
        widget.onBackTap?.call();
      },
      child: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => LearnScreen(
                  userName: widget.userName,
                  savedWordsCount: widget.savedWordsCount,
                  onBackTap: widget.onBackTap,
                ),
              );
            case '/word_practice': {
              final args = settings.arguments as LearnWordPracticeArgs?;
              final returnToHome = args?.returnToHomeOnPop ?? false;
              final trackId = args?.trackId;
              return MaterialPageRoute<bool>(
                settings: settings,
                builder: (_) => WordPracticeScreen(
                  returnToHomeOnPop: returnToHome,
                  trackId: trackId,
                ),
              );
            }
            case '/daily_test': {
              final args = settings.arguments as DailyTestRouteArgs?;
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => DailyTestScreen(
                  trackId: args?.trackId,
                  wordId: args?.wordId,
                  questionType: args?.questionType ?? 'daily_test',
                ),
              );
            }
            case '/saved_word': {
              final args = settings.arguments as LearnSavedWordArgs?;
              final returnToHome = args?.returnToHomeOnPop ?? false;
              return MaterialPageRoute<bool>(
                settings: settings,
                builder: (_) => SavedWordScreen(
                  savedWordsCount: widget.savedWordsCount,
                  returnToHomeOnPop: returnToHome,
                ),
              );
            }
            case '/reading_test':
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const ReadingTestScreen(),
              );
            default:
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => LearnScreen(
                  userName: widget.userName,
                  savedWordsCount: widget.savedWordsCount,
                  onBackTap: widget.onBackTap,
                ),
              );
          }
        },
      ),
    );
  }
}


