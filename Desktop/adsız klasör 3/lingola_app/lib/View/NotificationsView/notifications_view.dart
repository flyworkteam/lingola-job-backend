import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
/// Tek bildirim öğesi (liste silindiğinde state'ten kaldırılır).
class _NotificationItem {
  const _NotificationItem({
    required this.emoji,
    required this.titleKey,
    required this.subtitleKey,
    required this.time,
  });
  final String emoji;
  final String titleKey;
  final String subtitleKey;
  final String time;
}

/// Bildirimler sayfası — header'daki bildirim ikonuna basınca açılır.
/// Premium değilse en üstte "Premium avantajları" kartı her zaman gösterilir.
/// Alt navigasyon barı sayfada gösterilir (Home'dan geldiği için Home seçili).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.isPremium = false,
  });

  final bool isPremium;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      const _NotificationItem(
        emoji: '☕',
        titleKey: 'notifications.notif1_title',
        subtitleKey: 'notifications.notif1_subtitle',
        time: '17:58',
      ),
      const _NotificationItem(
        emoji: '🤔',
        titleKey: 'notifications.notif2_title',
        subtitleKey: 'notifications.notif2_subtitle',
        time: '14:20',
      ),
    ];
  }

  static const double _headerExpandedHeight = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Stack(
        children: [
          CustomScrollView(
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
                leading: IconButton(
                  icon: Transform.translate(
                    offset: const Offset(6, 0),
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                titleSpacing: 4,
                title: Text(
                  context.tr('notifications.title'),
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                centerTitle: false,
                actions: [
                  PopupMenuButton<String>(
                    position: PopupMenuPosition.under,
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 280,
                      minHeight: 52,
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: Transform.translate(
                      offset: const Offset(-6, 0),
                      child: Icon(Icons.more_vert, size: 24, color: AppColors.onSurface),
                    ),
                    onSelected: (value) {
                      if (value == 'delete_all') {
                        _showDeleteAllConfirmDialog(context, () {
                          setState(() => _notifications.clear());
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete_all',
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/icon_delete.svg',
                                width: 18,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFF00000),
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  context.tr('notifications.delete_all'),
                                  style: AppTypography.labelLarge.copyWith(
                                    color: const Color(0xFFF00000),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
              if (!widget.isPremium) ...[
                _buildPremiumCard(context),
                const SizedBox(height: AppSpacing.lg),
              ],
              ..._notifications.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _buildNotificationCard(
                    context,
                    emoji: n.emoji,
                    title: context.tr(n.titleKey),
                    subtitle: context.tr(n.subtitleKey),
                    time: n.time,
                  ),
                ),
              ),
              if (_notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Text(
                    context.tr('notifications.no_notifications'),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const Color _deleteRed = Color(0xFFE63E3E);
  static const Color _cancelGrey = Color(0xFFF1F1F1);
  static const Color _dialogPinkBg = Color(0xFFFFE5E5);

  static void _showDeleteAllConfirmDialog(BuildContext context, VoidCallback onDeleteConfirmed) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _dialogPinkBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/icon_delete.svg',
                    width: 28,
                    height: 32,
                    colorFilter: const ColorFilter.mode(
                      _deleteRed,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr('notifications.delete_all_confirm'),
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(
                  color: const Color(0xFF1C1B1F),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: _cancelGrey,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Center(
                            child: Text(
                              context.tr('common.cancel'),
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onDeleteConfirmed();
                        },
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: _deleteRed,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Center(
                            child: Text(
                              context.tr('profile_settings.delete'),
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mavi gradient kart: Premium değilse en üstte her zaman gösterilir.
  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.splashGradientStart,
            AppColors.splashGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDropShadow.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/kupa.svg',
            width: 48,
            height: 48,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('notifications.premium_benefits'),
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('notifications.premium_benefits_desc'),
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '17:58',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Beyaz bildirim kartı: emoji, başlık, alt metin, saat.
  Widget _buildNotificationCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

