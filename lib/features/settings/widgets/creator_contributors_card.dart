import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/animation_config.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/update/github_contributors_service.dart';
import '../../../core/utils/resource_launcher.dart';
import '../../../core/widgets/glass_card.dart';

/// Displays the app creator profile and GitHub contributors inside Settings.
class CreatorContributorsCard extends StatefulWidget {
  final GithubContributorsService? service;
  final GithubProjectCredits? initialCredits;

  const CreatorContributorsCard({
    super.key,
    this.service,
    this.initialCredits,
  });

  @override
  State<CreatorContributorsCard> createState() =>
      _CreatorContributorsCardState();
}

class _CreatorContributorsCardState extends State<CreatorContributorsCard> {
  late final GithubContributorsService _service;
  late GithubProjectCredits _credits;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? GithubContributorsService.instance;
    _credits = widget.initialCredits ??
        _service.cachedCredits ??
        GithubProjectCredits.offlineDefault();
    if (widget.initialCredits == null && !AppAnimations.isTest) {
      _loadCredits();
    }
  }

  Future<void> _loadCredits({bool forceRefresh = false}) async {
    if (_isRefreshing) return;
    if (mounted && forceRefresh) {
      setState(() => _isRefreshing = true);
    }
    try {
      final loaded = await _service.fetchCredits(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() => _credits = loaded);
      }
    } finally {
      if (mounted && forceRefresh) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColors = RythemColors.of(context);
    final creator = _credits.creator;
    final contributors = _credits.contributors;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator Header Row
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              ResourceLauncher.openResource(
                context,
                url: creator.htmlUrl,
                title: '@${creator.login}',
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                _buildAvatar(
                  avatarUrl: creator.avatarUrl,
                  fallbackInitial: creator.displayName,
                  size: 48,
                  themeColors: themeColors,
                  isDark: isDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              creator.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RythemTypography.titleSmall.copyWith(
                                color: themeColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.10)
                                  : Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CREATOR',
                              style: RythemTypography.labelSmall.copyWith(
                                color: themeColors.textSecondary,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${creator.login}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RythemTypography.labelSmall.copyWith(
                          color: themeColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (creator.bio != null && creator.bio!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          creator.bio!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RythemTypography.bodySmall.copyWith(
                            color: themeColors.textTertiary,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: themeColors.textTertiary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: isDark ? themeColors.glassBorder : const Color(0x12000000),
          ),
          const SizedBox(height: 12),

          // Contributors Subheader & Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONTRIBUTORS (${contributors.length})',
                style: RythemTypography.labelSmall.copyWith(
                  color: themeColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              GestureDetector(
                onTap: _isRefreshing
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        _loadCredits(forceRefresh: true);
                      },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: _isRefreshing
                      ? SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              themeColors.textSecondary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 15,
                          color: themeColors.textTertiary,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Contributors Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contributors.map((contributor) {
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ResourceLauncher.openResource(
                    context,
                    url: contributor.htmlUrl,
                    title: '@${contributor.login}',
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.035),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? themeColors.glassBorder
                          : const Color(0x14000000),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAvatar(
                        avatarUrl: contributor.avatarUrl,
                        fallbackInitial: contributor.login,
                        size: 22,
                        themeColors: themeColors,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '@${contributor.login}',
                        style: RythemTypography.labelSmall.copyWith(
                          color: themeColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (contributor.contributions > 0) ...[
                        const SizedBox(width: 5),
                        Text(
                          '• ${contributor.contributions}',
                          style: RythemTypography.caption.copyWith(
                            color: themeColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required String avatarUrl,
    required String fallbackInitial,
    required double size,
    required RythemThemeColors themeColors,
    required bool isDark,
  }) {
    final initial = fallbackInitial.trim().isNotEmpty
        ? fallbackInitial.trim()[0].toUpperCase()
        : 'R';

    Widget fallbackWidget() {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.08),
        ),
        child: Text(
          initial,
          style: RythemTypography.labelSmall.copyWith(
            color: themeColors.textPrimary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? themeColors.glassBorderHighlight
              : const Color(0x22000000),
          width: 1.0,
        ),
      ),
      child: ClipOval(
        child: AppAnimations.isTest || avatarUrl.isEmpty
            ? fallbackWidget()
            : Image.network(
                avatarUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallbackWidget(),
              ),
      ),
    );
  }
}

