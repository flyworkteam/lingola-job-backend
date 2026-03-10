import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_app/Models/daily_test_question.dart';
import 'package:lingola_app/Models/word_item.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/Services/word_database_service.dart';
import 'package:lingola_app/Services/word_services.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/utils/user_level.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyTestScreen extends ConsumerStatefulWidget {
  const DailyTestScreen({
    super.key,
    this.trackId,
    this.wordId,
    this.questionType = 'daily_test',
  });

  final int? trackId;
  final int? wordId;
  final String questionType;

  @override
  ConsumerState<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends ConsumerState<DailyTestScreen> {
  static const double _cardWidth = 330;
  static const double _cardRadius = 30;
  static const Color _optionBorder = Color(0xFFBABABA);
  static const Color _wrongColor = Color(0xFFFF0000);
  static const Color _correctColor = Color(0xFF00DF00);

  List<DailyTestQuestion> _questions = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _errorMessage;
  int? _selectedIndex;
  bool _showResult = false;
  int _correctCount = 0;
  int _xpEarnedThisSession = 0;

  static const int _xpPerCorrect = 10;
  static const String _keyProfileLevel = 'profile_level';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportTrackAccess();
      _loadQuestions();
    });
  }

  void _reportTrackAccess() {
    final trackId = widget.trackId;
    if (trackId == null || !mounted) return;
    ref.read(userRepositoryProvider).updateTrackProgress(trackId).ignore();
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userLevel = prefs.getString(_keyProfileLevel);

      // Kelimeleri backend yerine local veritabanından (assets/words.json -> SQLite) al.
      final localeCode = context.locale.languageCode;
      var rawList = await WordDatabaseService.getWords();
      rawList = await WordService.enrichWordsWithTranslations(rawList, localeCode: localeCode);

      final words = rawList.map((e) => WordItem.fromJson(e)).toList();
      final filtered = words
          .where((w) => UserLevel.isAllowedForUser(w.level, userLevel))
          .toList();

      final questions = DailyTestQuestion.fromWords(filtered, maxQuestions: 10);
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _loading = false;
        _errorMessage = questions.isEmpty ? 'daily_test.no_words_min'.tr() : null;
        _currentIndex = 0;
        _selectedIndex = null;
        _showResult = false;
        _correctCount = 0;
        _xpEarnedThisSession = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = '${'daily_test.load_error'.tr()}: $e';
      });
    }
  }

  void _onOptionTap(int i) {
    if (_showResult || _questions.isEmpty) return;
    final question = _questions[_currentIndex];
    final isCorrect = i == question.correctOptionIndex;
    final selectedAnswer = question.options[i];
    setState(() {
      _selectedIndex = i;
      _showResult = true;
      if (isCorrect) {
        _correctCount++;
        _xpEarnedThisSession += _xpPerCorrect;
      }
    });
    if (isCorrect) {
      ref.read(xpProvider).addXp(_xpPerCorrect);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$_xpPerCorrect XP'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _onNext() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _showResult = false;
      });
    } else {
      if (_xpEarnedThisSession > 0 || _correctCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'daily_test.test_complete'.tr(args: ['$_correctCount', '$_xpEarnedThisSession']),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Transform.translate(
            offset: const Offset(6, 0),
            child: Transform.scale(
              scaleX: -1,
              child: SvgPicture.asset(
                'assets/icons/icon_arrow_right.svg',
                width: 20,
                height: 9,
                colorFilter: const ColorFilter.mode(Color(0xFF000000), BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
        title: Text(
          'learn.daily_test'.tr(),
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadQuestions,
            child: Text('daily_test.retry'.tr()),
          ),
        ],
      );
    }
    if (_questions.isEmpty) {
      return Text(
        'daily_test.no_words_empty'.tr(),
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuestionCard(),
        const SizedBox(height: 102),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BackNextButton(
              label: 'common.back'.tr(),
              isPrimary: false,
              onTap: () => Navigator.of(context).pop(),
              isBack: true,
            ),
            const SizedBox(width: 16),
            BackNextButton(
              label: _currentIndex + 1 < _questions.length ? 'common.next'.tr() : 'common.done'.tr(),
              isPrimary: true,
              onTap: _showResult ? _onNext : () {},
              isBack: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey<int>(_currentIndex),
        width: _cardWidth,
        constraints: const BoxConstraints(minHeight: 320),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 28),
            Text(
              'fill blank'.tr(),
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              question.sentence,
              style: GoogleFonts.quicksand(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ...List.generate(question.options.length, (i) {
              final showCorrectAnswer = _showResult;
              final isCorrectOption = i == question.correctOptionIndex;
              final selected = _selectedIndex == i;
              final isWrong = selected && i != question.correctOptionIndex;
              final isCorrect = selected && i == question.correctOptionIndex;
              final borderColor = showCorrectAnswer
                  ? (isCorrectOption
                      ? _correctColor
                      : (isWrong ? _wrongColor : _optionBorder))
                  : (isWrong
                      ? _wrongColor
                      : (isCorrect ? _correctColor : _optionBorder));
              final textColor = showCorrectAnswer
                  ? (isCorrectOption
                      ? _correctColor
                      : (isWrong ? _wrongColor : const Color(0xFF1E1E1E)))
                  : (isWrong
                      ? _wrongColor
                      : (isCorrect ? _correctColor : const Color(0xFF1E1E1E)));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: showCorrectAnswer ? null : () => _onOptionTap(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Text(
                        question.options[i],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
