import 'package:flutter/material.dart';

import '../../presentation/themes/app_theme.dart';

class AppThemeHelper {
  // Get the custom theme extension from the current theme
  static CustomThemeExtension getCustomTheme(BuildContext context) {
    return Theme.of(context).extension<CustomThemeExtension>() ?? 
           const CustomThemeExtension(
             primaryGradient: AppTheme.primaryGradient,
             surfaceGradient: AppTheme.surfaceGradient,
             backgroundGradient: AppTheme.backgroundGradient,
             cardBorderRadius: 16.0,
             cardElevation: 2.0,
             cardMargin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
             iconContainerPadding: 12.0,
             iconContainerBorderRadius: 12.0,
             navigationCardAspectRatio: 1.1,
             navigationCardSpacing: 16.0,
             statCardPadding: 16.0,
             statCardBorderRadius: 16.0,
             welcomeSectionPadding: 24.0,
             welcomeSectionBorderRadius: 20.0,
             appBarPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
             appBarIconContainerPadding: 12.0,
             appBarIconContainerBorderRadius: 12.0,
           );
  }

  // Common container decorations
  static BoxDecoration getBackgroundGradientDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: getCustomTheme(context).backgroundGradient,
    );
  }

  static BoxDecoration getCardDecoration(BuildContext context) {
    final theme = getCustomTheme(context);
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(theme.cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getPrimaryGradientDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: getCustomTheme(context).primaryGradient,
      borderRadius: BorderRadius.circular(getCustomTheme(context).iconContainerBorderRadius),
    );
  }

  static BoxDecoration getIconContainerDecoration(BuildContext context, Color color) {
    final theme = getCustomTheme(context);
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(theme.iconContainerBorderRadius),
    );
  }

  static BoxDecoration getNavigationCardDecoration(BuildContext context, Color color) {
    final theme = getCustomTheme(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(theme.cardBorderRadius),
      border: Border.all(
        color: color.withOpacity(0.2),
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration getWelcomeSectionDecoration(BuildContext context) {
    final theme = getCustomTheme(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(theme.welcomeSectionBorderRadius),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
    );
  }

  static BoxDecoration getAppBarDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Common padding and spacing
  static EdgeInsets getStandardPadding(BuildContext context) {
    return const EdgeInsets.all(20);
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    return EdgeInsets.all(getCustomTheme(context).statCardPadding);
  }

  static EdgeInsets getWelcomeSectionPadding(BuildContext context) {
    return EdgeInsets.all(getCustomTheme(context).welcomeSectionPadding);
  }

  static EdgeInsets getAppBarPadding(BuildContext context) {
    return getCustomTheme(context).appBarPadding;
  }

  // Common text styles
  static TextStyle getHeadlineStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
    ) ?? const TextStyle();
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
    ) ?? const TextStyle();
  }

  static TextStyle getBodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.grey[600],
    ) ?? const TextStyle();
  }

  // Common spacing
  static const double standardSpacing = 32.0;
  static const double smallSpacing = 16.0;
  static const double tinySpacing = 8.0;
}
