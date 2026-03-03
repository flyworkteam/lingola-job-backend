import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/Repositories/user_repository.dart';
import 'package:lingola_app/Services/auth_service.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_icon_button.dart';

/// Profil sayfası: header, avatar, ayar listesi, versiyon.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.userName = 'Jhon Doe',
    this.userEmail = 'jhon@gmail.com',
    this.isPremium = false,
    this.onUserNameChanged,
    this.onBackTap,
    this.onNotificationsTap,
  });

  final String userName;
  final String userEmail;
  final bool isPremium;
  /// Profil ayarlarından ad güncellendiğinde MainScreen state'ini güncellemek için.
  final ValueChanged<String>? onUserNameChanged;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationsTap;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  late String _userName;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName) _userName = widget.userName;
  }

  void _onSignOutConfirmed() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    context.go(AppPaths.onboarding);
  }

  static const double _headerExpandedHeight = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                background: _buildAppBar(context),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl + 100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildProfileHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildMenuList(context),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'version 2.1.0',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
            'Profile',
            style: AppTypography.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          AppIconButton(
            onTap: widget.onNotificationsTap ?? () {},
            child: SvgPicture.asset(
              'assets/icons/bildirim2.svg',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.splashGradientStart,
            shape: BoxShape.circle,
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
        const SizedBox(height: AppSpacing.md),
        Text(
          _userName,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.userEmail,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF9E9E9E).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Text(
            widget.isPremium ? 'Premium' : 'Free',
            style: AppTypography.labelLarge.copyWith(
              color: const Color(0xFF5C5C5C),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _SignOutDialog(onConfirmSignOut: _onSignOutConfirmed),
    );
  }

  Future<void> _testBackend(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Backend test ediliyor...'),
              ],
            ),
          ),
        ),
      ),
    );
    final result = await _userRepository.testBackend();
    if (!context.mounted) return;
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(result.isOk ? 'Backend OK' : 'Backend Hata'),
        content: SingleChildScrollView(
          child: Text(
            result.isOk
                ? (result.data ?? '')
                : (result.error ?? 'Bilinmeyen hata'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.5,
          color: const Color(0xFFCDD0D8),
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/nav_profil.svg',
          label: 'Profile Settings',
          onTap: () async {
            final result = await context.push<ProfileSettingsResult?>(
              AppPaths.profileSettings,
              extra: ProfileSettingsRouteArgs(initialName: _userName),
            );
            if (result != null && mounted) {
              setState(() => _userName = result.name);
              widget.onUserNameChanged?.call(result.name);
            }
          },
        ),
        _ProfileMenuItemWithSwitch(
          iconAsset: 'assets/icons/icon_notifications_list.svg',
          label: 'Notifications',
          value: _notificationsEnabled,
          onChanged: (v) => setState(() => _notificationsEnabled = v),
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/icon_premium.svg',
          label: 'Premium',
          onTap: () {},
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/icon_share.svg',
          label: 'Share with Friend',
          onTap: () {},
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/icon_faq.svg',
          label: 'F.A.Q.',
          onTap: () => context.push(AppPaths.faq),
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/icon_rate.svg',
          label: 'Rate Us',
          onTap: () {},
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/icon_faq.svg',
          label: 'Backend Test',
          onTap: () => _testBackend(context),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: const Color(0xFFCDD0D8),
        ),
        _ProfileMenuItem(
          iconAsset: 'assets/icons/icon_signout.svg',
          label: 'Sign Out',
          showArrow: false,
          onTap: () => _showSignOutDialog(context),
        ),
      ],
    );
  }
}

/// Sign out onay popup'ı (Delete Account ile aynı tasarım).
class _SignOutDialog extends StatelessWidget {
  const _SignOutDialog({required this.onConfirmSignOut});

  final VoidCallback onConfirmSignOut;

  static const Color _signOutRed = Color(0xFFC1443D);
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
              'Are you sure you want to log out of your account?',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirmSignOut();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _signOutRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
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

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.showArrow = true,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/rectangle_141.svg',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFC4C4C4),
                        BlendMode.srcIn,
                      ),
                    ),
                    SvgPicture.asset(
                      iconAsset,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      colorFilter: ColorFilter.mode(
                        AppColors.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                    fontSize: 15,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: AppColors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItemWithSwitch extends StatelessWidget {
  const _ProfileMenuItemWithSwitch({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  final String iconAsset;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.onSurfaceVariant;
    final useNativeColor = iconAsset.contains('icon_notifications_list');
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/rectangle_141.svg',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFC4C4C4),
                    BlendMode.srcIn,
                  ),
                ),
                if (useNativeColor)
                  SvgPicture.asset(
                    iconAsset,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  )
                else
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
                fontSize: 15,
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.splashGradientStart,
              ),
            ),
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

