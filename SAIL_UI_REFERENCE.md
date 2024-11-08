# Sail UI Reference Guide

This document serves as a quick reference for using the sail_ui design system components correctly.

## Text Components

### SailText
Do NOT use:
```dart
SailText.primary16()  // ❌ Wrong
SailText.secondary16() // ❌ Wrong
```

Instead use:
```dart
SailText.primary12(    // ✅ Correct
  'Your text',
)

SailText.secondary12(  // ✅ Correct
  'Your text',
)
```

## Icons

### SailSVGAsset Available Icons
Common icons available in sail_ui:
- `SailSVGAsset.iconHome` - Home/Overview
- `SailSVGAsset.iconWallet` - Wallet management
- `SailSVGAsset.iconTools` - Developer tools/utilities
- `SailSVGAsset.iconTabSettings` - Settings/Configuration
- `SailSVGAsset.iconSend` - Send/Receive/Transfer
- `SailSVGAsset.iconSidechains` - Sidechains/Network
- `SailSVGAsset.iconCoins` - Coins/Balance
- `SailSVGAsset.dividerDot` - Dot separator

Usage:
```dart
QtTab(
  icon: SailSVGAsset.iconHome,
  label: 'Home',
  active: true,
)
```

## Theme Usage

### Colors
Access through SailTheme:
```dart
final theme = SailTheme.of(context);

// Background colors
theme.colors.background
theme.colors.backgroundSecondary

// Text colors
theme.colors.primary
theme.colors.secondary

// Status colors
theme.colors.green
theme.colors.red
theme.colors.orange
```

### Spacing
Use SailStyleValues for consistent spacing:
```dart
SailStyleValues.padding04  // 4.0
SailStyleValues.padding08  // 8.0
SailStyleValues.padding12  // 12.0
SailStyleValues.padding16  // 16.0
SailStyleValues.padding20  // 20.0
```

## Common Components

### Navigation Tabs
```dart
QtTab(
  icon: SailSVGAsset.iconHome,
  label: 'Overview',
  active: tabsRouter.activeIndex == 0,
  onTap: () => tabsRouter.setActiveIndex(0),
)
```

### Theme Toggle
```dart
const ToggleThemeButton()
```

## Best Practices

1. Always get theme from context:
```dart
final theme = SailTheme.of(context);
```

2. Use SailText with proper size:
```dart
SailText.primary12(
  'Title',
)
```

3. Use proper color properties:
```dart
color: theme.colors.primary  // ✅ Correct
color: theme.colors.textPrimary  // ❌ Wrong
```

4. Use SailStyleValues for spacing:
```dart
padding: EdgeInsets.all(SailStyleValues.padding16)  // ✅ Correct
padding: EdgeInsets.all(16)  // ❌ Avoid magic numbers
```

## Common Patterns

### Status Bar
For status bars and info text:
```dart
SailText.secondary12('Status: Connected')
```

### Headers
For section headers:
```dart
SailText.primary12('Section Title')
```

### Navigation
For navigation labels:
```dart
QtTab(
  icon: SailSVGAsset.iconHome,
  label: 'Overview',
  active: tabsRouter.activeIndex == 0,
)
```

### Gradients
For gradient backgrounds:
```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      theme.colors.background,
      theme.colors.backgroundSecondary,
    ],
  ),
),
