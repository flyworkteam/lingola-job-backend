import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/dismiss_keyboard.dart';

/// Profil ayarları sayfası: avatar, ad, e-posta alanları.
class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.initialName = '',
  });

  final String initialName;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _nameController;
  final GlobalKey _cameraButtonKey = GlobalKey();

  String? _selectedLanguage;
  String? _selectedAppLanguage;
  String? _selectedLevel;
  String? _selectedProfession;

  static const List<_ProfileLanguage> _languages = [
    _ProfileLanguage(id: 'english', title: 'English', flagAsset: 'assets/bayrak/flag_english.svg'),
    _ProfileLanguage(id: 'german', title: 'German', flagAsset: 'assets/bayrak/flag_german.svg'),
    _ProfileLanguage(id: 'italian', title: 'Italian', flagAsset: 'assets/bayrak/flag_italian.svg'),
    _ProfileLanguage(id: 'french', title: 'French', flagAsset: 'assets/bayrak/flag_french.svg'),
    _ProfileLanguage(id: 'japanese', title: 'Japanese', flagAsset: 'assets/bayrak/flag_japanese.svg'),
    _ProfileLanguage(id: 'spanish', title: 'Spanish', flagAsset: 'assets/bayrak/Spain.png'),
    _ProfileLanguage(id: 'russian', title: 'Russian', flagAsset: 'assets/bayrak/flag_russian.svg'),
    _ProfileLanguage(id: 'turkish', title: 'Turkish', flagAsset: 'assets/bayrak/flag_turkish.svg'),
    _ProfileLanguage(id: 'korean', title: 'Korean', flagAsset: 'assets/bayrak/flag_korean.svg'),
    _ProfileLanguage(id: 'hindi', title: 'Hindi', flagAsset: 'assets/bayrak/flag_hindi.svg'),
    _ProfileLanguage(id: 'portuguese', title: 'Portuguese', flagAsset: 'assets/bayrak/flag_portuguese.svg'),
  ];

  static const List<_ProfileLevel> _levels = [
    _ProfileLevel(id: 'a1', title: 'A1 Beginner'),
    _ProfileLevel(id: 'a2', title: 'A2 Elementary'),
    _ProfileLevel(id: 'b1', title: 'B1 Intermediate'),
    _ProfileLevel(id: 'b2', title: 'B2 Upper-Intermediate'),
    _ProfileLevel(id: 'c1', title: 'C1 Advanced'),
    _ProfileLevel(id: 'c2', title: 'C2 Proficient'),
  ];

  static const List<_ProfileProfession> _professions = [
    _ProfileProfession(id: 'legal', title: 'Legal'),
    _ProfileProfession(id: 'tech', title: 'Tech'),
    _ProfileProfession(id: 'medicine', title: 'Medicine'),
    _ProfileProfession(id: 'finance', title: 'Finance'),
    _ProfileProfession(id: 'marketing', title: 'Marketing'),
    _ProfileProfession(id: 'engineering', title: 'Engineering'),
    _ProfileProfession(id: 'education', title: 'Education'),
    _ProfileProfession(id: 'tourism', title: 'Tourism & Hospitality'),
    _ProfileProfession(id: 'sales', title: 'Sales'),
    _ProfileProfession(id: 'support', title: 'Customer Support'),
    _ProfileProfession(id: 'hr', title: 'Human Resources'),
    _ProfileProfession(id: 'entrepreneurship', title: 'Entrepreneurship'),
    _ProfileProfession(id: 'logistics', title: 'Logistic & Trade'),
    _ProfileProfession(id: 'it', title: 'Information Technology Fields'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  static const double _headerHeight = 110;
  static const double _avatarSize = 100;
  static const double _avatarOverlap = 50; // avatar'ın header altına taşan kısmı

  Widget _buildGradientHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      height: _headerHeight + topPadding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0575E6), Color(0xFF021B79)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
            children: [
              IconButton(
                icon: Transform.scale(
                  scaleX: -1,
                  child: SvgPicture.asset(
                    'assets/icons/icon_arrow_right.svg',
                    width: 20,
                    height: 9,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Profile Settings',
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final avatarTop = _headerHeight + topPadding - _avatarOverlap;
    const contentTopPadding = 72.0; // avatar'ın altı için boşluk

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FC),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGradientHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      contentTopPadding,
                      AppSpacing.xl,
                      AppSpacing.xxl,
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSelectRow(
                      label: 'Select Language',
                      value: _languageTitle(_selectedLanguage),
                      onTap: () => _showLanguageSheet(context, (id) => setState(() => _selectedLanguage = id)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSelectRow(
                      label: 'Select App Language',
                      value: _languageTitle(_selectedAppLanguage),
                      onTap: () => _showLanguageSheet(context, (id) => setState(() => _selectedAppLanguage = id)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSelectRow(
                      label: 'Select Your Language Level',
                      value: _levelTitle(_selectedLevel),
                      onTap: () => _showLevelSheet(context, (id) => setState(() => _selectedLevel = id)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSelectRow(
                      label: 'Select Your Profession',
                      value: _professionTitle(_selectedProfession),
                      onTap: () => _showProfessionSheet(context, (id) => setState(() => _selectedProfession = id)),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSaveButton(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDeleteAccount(context),
                  ],
                ),
              ),
            ),
          ],
        ),
            Positioned(
              top: avatarTop,
              left: 0,
              right: 0,
              child: Center(child: _buildAvatar()),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoSourceSheet(BuildContext context) {
    final box = _cameraButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    const double arrowWidth = 14;
    const double arrowHeight = 8;
    const double menuWidth = 220;
    const double itemHeight = 52;
    const double borderRadius = 12;
    final double menuHeight = arrowHeight + itemHeight * 2;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    double left = offset.dx + size.width / 2 - menuWidth / 2;
    left = left.clamp(16, screenWidth - menuWidth - 16);
    final double top = offset.dy + size.height + 6;

    late OverlayEntry overlayEntry;
    void dismiss() {
      overlayEntry.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: dismiss,
            child: const SizedBox.expand(),
          ),
          Positioned(
            left: left,
            top: top,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(borderRadius),
              child: SizedBox(
                width: menuWidth,
                height: menuHeight,
                child: CustomPaint(
                  painter: _DropdownArrowPainter(
                    arrowCenterX: (offset.dx + size.width / 2 - left).clamp(arrowWidth, menuWidth - arrowWidth),
                    arrowHeight: arrowHeight,
                    color: AppColors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: arrowHeight),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(borderRadius),
                          bottomRight: Radius.circular(borderRadius),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _photoDropdownOption(
                            context,
                            iconAsset: 'assets/icons/icon_photo_camera.svg',
                            label: 'Take a Photo',
                            onTap: () {
                              dismiss();
                              // TODO: Kamera aç
                            },
                          ),
                          Divider(height: 1, indent: 48, endIndent: 12, color: AppColors.onSurfaceVariant.withValues(alpha: 0.2)),
                          _photoDropdownOption(
                            context,
                            iconAsset: 'assets/icons/icon_photo_gallery.svg',
                            label: 'Select from Gallery',
                            onTap: () {
                              dismiss();
                              // TODO: Galeri aç
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  Widget _photoDropdownOption(
    BuildContext context, {
    required String iconAsset,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(Color(0xFF1C1B1F), BlendMode.srcIn),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C1B1F),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDropShadow.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/dummy/image 2.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _showPhotoSourceSheet(context),
              child: KeyedSubtree(
                key: _cameraButtonKey,
                child: Container(
                  width: 32,
                  height: 32,
                decoration: BoxDecoration(
                  color: AppColors.splashGradientStart,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  String? _languageTitle(String? id) {
    if (id == null) return null;
    for (final l in _languages) if (l.id == id) return l.title;
    return null;
  }

  String? _levelTitle(String? id) {
    if (id == null) return null;
    for (final l in _levels) if (l.id == id) return l.title;
    return null;
  }

  String? _professionTitle(String? id) {
    if (id == null) return null;
    for (final p in _professions) if (p.id == id) return p.title;
    return null;
  }

  Widget _buildSelectRow({
    required String label,
    required String? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? 'Select',
                      style: AppTypography.body.copyWith(
                        color: value != null
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageSheet(BuildContext context, ValueChanged<String> onSelected) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
                itemCount: _languages.length,
                itemBuilder: (ctx, i) {
                  final lang = _languages[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onSelected(lang.id);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 30,
                              child: lang.flagAsset.toLowerCase().endsWith('.png')
                                  ? Image.asset(lang.flagAsset, width: 40, height: 30, fit: BoxFit.contain)
                                  : SvgPicture.asset(
                                      lang.flagAsset,
                                      width: 40,
                                      height: 30,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                lang.title,
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelSheet(BuildContext context, ValueChanged<String> onSelected) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._levels.map(
              (level) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onSelected(level.id);
                    Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            level.title,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfessionSheet(BuildContext context, ValueChanged<String> onSelected) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
                itemCount: _professions.length,
                itemBuilder: (ctx, i) {
                  final p = _professions[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onSelected(p.id);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text(
                          p.title,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.body.copyWith(
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(
                color: AppColors.splashGradientStart,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onSave,
        borderRadius: AppRadius.large,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryBrand,
            borderRadius: AppRadius.large,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/icon_save.svg',
                width: 20,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Save',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _DeleteAccountDialog(onConfirmDelete: _onAccountDeleted),
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDeleteAccountDialog(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/rectangle_141.svg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFFFC3C3),
                        BlendMode.srcIn,
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/icon_delete.svg',
                      width: 20,
                      height: 24,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFE30A17),
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Delete Account',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _keyProfileName = 'profile_name';
  static const String _keyProfileLanguage = 'profile_language';
  static const String _keyProfileAppLanguage = 'profile_app_language';
  static const String _keyProfileLevel = 'profile_level';
  static const String _keyProfileProfession = 'profile_profession';

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name', style: GoogleFonts.nunitoSans()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileName, name);
    if (_selectedLanguage != null) await prefs.setString(_keyProfileLanguage, _selectedLanguage!);
    if (_selectedAppLanguage != null) await prefs.setString(_keyProfileAppLanguage, _selectedAppLanguage!);
    if (_selectedLevel != null) await prefs.setString(_keyProfileLevel, _selectedLevel!);
    if (_selectedProfession != null) await prefs.setString(_keyProfileProfession, _selectedProfession!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile saved successfully', style: GoogleFonts.nunitoSans(color: Colors.white)),
        backgroundColor: AppColors.primaryBrand,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop(ProfileSettingsResult(name: name));
  }

  void _onAccountDeleted() {
    context.go(AppPaths.onboarding);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your account has been deleted', style: GoogleFonts.nunitoSans(color: Colors.white)),
        backgroundColor: const Color(0xFFC1443D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Hesap silme onay popup'ı: metin, "I approve" checkbox, Cancel / Delete butonları.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.onConfirmDelete});

  final VoidCallback onConfirmDelete;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _approved = false;

  static const Color _deleteRed = Color(0xFFC1443D);
  static const Color _cancelGray = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => setState(() => _approved = !_approved),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _approved,
                        onChanged: (v) => setState(() => _approved = v ?? false),
                        activeColor: _deleteRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'I approve',
                      style: GoogleFonts.nunitoSans(
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: _cancelGray,
                      foregroundColor: const Color(0xFF000000),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: _approved
                        ? () {
                            Navigator.of(context).pop();
                            widget.onConfirmDelete();
                          }
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: _deleteRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _deleteRed.withOpacity(0.5),
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileLanguage {
  const _ProfileLanguage({required this.id, required this.title, required this.flagAsset});
  final String id;
  final String title;
  final String flagAsset;
}

class _ProfileLevel {
  const _ProfileLevel({required this.id, required this.title});
  final String id;
  final String title;
}

class _ProfileProfession {
  const _ProfileProfession({required this.id, required this.title});
  final String id;
  final String title;
}

/// Dropdown üstündeki kamera ikonuna bakan beyaz ok.
class _DropdownArrowPainter extends CustomPainter {
  _DropdownArrowPainter({
    required this.arrowCenterX,
    required this.arrowHeight,
    required this.color,
  });

  final double arrowCenterX;
  final double arrowHeight;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double halfWidth = 7;
    final path = Path()
      ..moveTo(arrowCenterX, 0)
      ..lineTo(arrowCenterX - halfWidth, arrowHeight)
      ..lineTo(arrowCenterX + halfWidth, arrowHeight)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DropdownArrowPainter oldDelegate) =>
      oldDelegate.arrowCenterX != arrowCenterX || oldDelegate.arrowHeight != arrowHeight || oldDelegate.color != color;
}

