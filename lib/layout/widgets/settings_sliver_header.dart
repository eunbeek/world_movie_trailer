import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Shared one-line collapsing header used by every settings page.
class SettingsSliverHeader extends StatelessWidget {
  const SettingsSliverHeader({
    super.key,
    required this.title,
    required this.darkIconAsset,
    required this.lightIconAsset,
  });

  final String title;
  final String darkIconAsset;
  final String lightIconAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SettingsHeaderDelegate(
        title: title,
        iconAsset: theme.brightness == Brightness.dark
            ? darkIconAsset
            : lightIconAsset,
        topPadding: MediaQuery.paddingOf(context).top,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _SettingsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SettingsHeaderDelegate({
    required this.title,
    required this.iconAsset,
    required this.topPadding,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String title;
  final String iconAsset;
  final double topPadding;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  double get minExtent => topPadding + 56;

  @override
  double get maxExtent => topPadding + 88;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final fontSize = lerpDouble(24, 19, progress)!;
    final iconWidth = lerpDouble(26, 0, progress)!;
    final iconGap = lerpDouble(12, 0, progress)!;

    return Material(
      color: backgroundColor,
      elevation: overlapsContent ? 1 : 0,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: foregroundColor,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
            ),
            CustomSingleChildLayout(
              delegate: _MovingTitleLayout(progress),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: iconWidth,
                    height: 26,
                    child: Opacity(
                      opacity: 1 - progress,
                      child: Image.asset(
                        iconAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: iconGap),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SettingsHeaderDelegate oldDelegate) =>
      title != oldDelegate.title ||
      iconAsset != oldDelegate.iconAsset ||
      topPadding != oldDelegate.topPadding ||
      backgroundColor != oldDelegate.backgroundColor ||
      foregroundColor != oldDelegate.foregroundColor;
}

class _MovingTitleLayout extends SingleChildLayoutDelegate {
  const _MovingTitleLayout(this.progress);

  final double progress;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    const expandedLeft = 56.0;
    final centeredLeft = (size.width - childSize.width) / 2;
    final left = lerpDouble(expandedLeft, centeredLeft, progress)!;
    return Offset(left, (size.height - childSize.height) / 2);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().copyWith(maxWidth: constraints.maxWidth - 64);

  @override
  bool shouldRelayout(covariant _MovingTitleLayout oldDelegate) =>
      progress != oldDelegate.progress;
}
