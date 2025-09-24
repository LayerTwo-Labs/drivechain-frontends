import 'dart:convert';

class Settings {
  final int configureHomeButtonPressCount;
  final bool hasConfiguredHomepage;
  // Add more settings fields here as needed in the future

  Settings({
    this.configureHomeButtonPressCount = 0,
    this.hasConfiguredHomepage = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'configureHomeButtonPressCount': configureHomeButtonPressCount,
      'hasConfiguredHomepage': hasConfiguredHomepage,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      configureHomeButtonPressCount: map['configureHomeButtonPressCount'] ?? 0,
      hasConfiguredHomepage: map['hasConfiguredHomepage'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Settings.fromJson(String source) {
    try {
      return Settings.fromMap(json.decode(source));
    } catch (e) {
      // Return default if parsing fails
      return Settings();
    }
  }

  Settings copyWith({
    int? configureHomeButtonPressCount,
    bool? hasConfiguredHomepage,
  }) {
    return Settings(
      configureHomeButtonPressCount: configureHomeButtonPressCount ?? this.configureHomeButtonPressCount,
      hasConfiguredHomepage: hasConfiguredHomepage ?? this.hasConfiguredHomepage,
    );
  }

  bool get shouldShowPrimaryButton {
    // Show primary variant if press count < 2 AND homepage not configured
    return configureHomeButtonPressCount < 2 && !hasConfiguredHomepage;
  }
}
