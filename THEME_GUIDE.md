# App Theme System Guide

## Overview
This app now uses a comprehensive theme system that applies the beautiful colors and styling from the home page across all pages. The theme provides consistent visual design and makes it easy to maintain a professional look throughout the app.

## What's Included

### Colors
- **Primary**: Blue gradient (#0158F9 to #02BCF5)
- **Secondary**: Light blue (#02BCF5)
- **Background**: Subtle gradient with primary colors at low opacity
- **Surface**: Clean white/dark surfaces with consistent shadows

### Styling
- **Cards**: Rounded corners (16px), subtle shadows, consistent margins
- **Typography**: Google Fonts (Poppins) with unified sizing and weights
- **Spacing**: Consistent padding and margins throughout
- **Gradients**: Beautiful background gradients on all pages

## How to Use

### 1. Import the Theme Helper
```dart
import '../../core/theme/app_theme_helper.dart';
```

### 2. Apply Background Gradient
```dart
Container(
  decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
  child: YourContent(),
)
```

### 3. Style Cards
```dart
Container(
  decoration: AppThemeHelper.getCardDecoration(context),
  padding: AppThemeHelper.getCardPadding(context),
  margin: AppThemeHelper.getStandardPadding(context),
  child: YourCardContent(),
)
```

### 4. Use Consistent Spacing
```dart
const SizedBox(height: AppThemeHelper.standardSpacing);  // 32px
const SizedBox(height: AppThemeHelper.smallSpacing);    // 16px
const SizedBox(height: AppThemeHelper.tinySpacing);     // 8px
```

### 5. Apply Text Styles
```dart
Text(
  'Your Text',
  style: AppThemeHelper.getHeadlineStyle(context),
)

Text(
  'Subtitle',
  style: AppThemeHelper.getTitleStyle(context),
)

Text(
  'Body text',
  style: AppThemeHelper.getBodyStyle(context),
)
```

## Example Page Structure

```dart
class YourPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Page'),
        // Automatically uses theme colors
      ),
      body: Container(
        decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
        child: Column(
          children: [
            // Header section
            Container(
              padding: AppThemeHelper.getCardPadding(context),
              decoration: AppThemeHelper.getCardDecoration(context),
              margin: AppThemeHelper.getStandardPadding(context),
              child: Text(
                'Welcome',
                style: AppThemeHelper.getHeadlineStyle(context),
              ),
            ),
            
            // Content list
            Expanded(
              child: ListView.builder(
                padding: AppThemeHelper.getStandardPadding(context),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppThemeHelper.smallSpacing),
                    decoration: AppThemeHelper.getCardDecoration(context),
                    child: ListTile(
                      contentPadding: AppThemeHelper.getCardPadding(context),
                      title: Text(
                        'Item $index',
                        style: AppThemeHelper.getTitleStyle(context),
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
}
```

## Benefits

1. **Consistency**: All pages now have the same beautiful look
2. **Maintainability**: Change colors in one place, affects everywhere
3. **Professional**: Unified design language throughout the app
4. **Easy to Use**: Simple helper methods for common styling needs
5. **Theme Support**: Automatic light/dark theme switching

## Migration Guide

To update existing pages:

1. Remove hardcoded colors (AppColors.primaryGreen, etc.)
2. Replace with theme colors (Theme.of(context).colorScheme.primary)
3. Add gradient backgrounds using the helper methods
4. Update card styling to use the theme system
5. Apply consistent spacing and typography

## Available Helper Methods

- `getBackgroundGradientDecoration(context)` - Page background
- `getCardDecoration(context)` - Card styling
- `getPrimaryGradientDecoration(context)` - Primary gradient containers
- `getIconContainerDecoration(context, color)` - Icon backgrounds
- `getNavigationCardDecoration(context, color)` - Navigation cards
- `getWelcomeSectionDecoration(context)` - Welcome sections
- `getAppBarDecoration(context)` - App bar styling

## Theme Extension Values

Access custom theme values:
```dart
final theme = AppThemeHelper.getCustomTheme(context);
final borderRadius = theme.cardBorderRadius;        // 16.0
final padding = theme.statCardPadding;             // 16.0
final spacing = theme.navigationCardSpacing;       // 16.0
```

This theme system ensures your app looks professional and consistent across all pages!
