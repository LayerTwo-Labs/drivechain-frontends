import 'package:sail_ui/sail_ui.dart';

/// Set once the user has been told that voting spends money on chain.
class VoteWarningSeenSetting extends SettingValue<bool> {
  VoteWarningSeenSetting({super.newValue});

  @override
  String get key => 'news_vote_warning_seen';

  @override
  bool defaultValue() => false;

  @override
  String toJson() {
    return value.toString();
  }

  @override
  bool? fromJson(String jsonString) {
    return jsonString == 'true';
  }

  @override
  SettingValue<bool> withValue([bool? value]) {
    return VoteWarningSeenSetting(newValue: value);
  }
}

/// Set once the user has been told that commenting spends money on chain.
class CommentWarningSeenSetting extends SettingValue<bool> {
  CommentWarningSeenSetting({super.newValue});

  @override
  String get key => 'news_comment_warning_seen';

  @override
  bool defaultValue() => false;

  @override
  String toJson() {
    return value.toString();
  }

  @override
  bool? fromJson(String jsonString) {
    return jsonString == 'true';
  }

  @override
  SettingValue<bool> withValue([bool? value]) {
    return CommentWarningSeenSetting(newValue: value);
  }
}
