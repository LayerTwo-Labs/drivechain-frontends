import 'dart:convert';

class BitwindowSettings {
  final int configureHomeButtonPressCount;
  final bool hasConfiguredHomepage;
  // Add more settings fields here as needed in the future

  BitwindowSettings({
    this.configureHomeButtonPressCount = 0,
    this.hasConfiguredHomepage = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'configureHomeButtonPressCount': configureHomeButtonPressCount,
      'hasConfiguredHomepage': hasConfiguredHomepage,
    };
  }

  factory BitwindowSettings.fromMap(Map<String, dynamic> map) {
    return BitwindowSettings(
      configureHomeButtonPressCount: map['configureHomeButtonPressCount'] ?? 0,
      hasConfiguredHomepage: map['hasConfiguredHomepage'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory BitwindowSettings.fromJson(String source) {
    try {
      return BitwindowSettings.fromMap(json.decode(source));
    } catch (e) {
      // Return default if parsing fails
      return BitwindowSettings();
    }
  }

  BitwindowSettings copyWith({
    int? configureHomeButtonPressCount,
    bool? hasConfiguredHomepage,
  }) {
    return BitwindowSettings(
      configureHomeButtonPressCount: configureHomeButtonPressCount ?? this.configureHomeButtonPressCount,
      hasConfiguredHomepage: hasConfiguredHomepage ?? this.hasConfiguredHomepage,
    );
  }

  bool get shouldShowPrimaryButton {
    // Show primary variant if press count < 2 AND homepage not configured
    return configureHomeButtonPressCount < 2 && !hasConfiguredHomepage;
  }
}
