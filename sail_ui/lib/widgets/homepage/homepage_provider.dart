import 'package:flutter/foundation.dart';
import 'package:sail_ui/widgets/homepage/homepage_widget_info.dart';
import 'package:sidechain_core/models/homepage_configuration.dart';

/// The saved homepage, and the draft the user changes in edit mode.
abstract class HomepageProvider extends ChangeNotifier {
  HomepageConfiguration configuration;
  List<HomepageWidgetConfig>? _draft;
  bool _saving = false;
  bool _ready = false;
  late final Future<void> loaded;

  HomepageProvider(HomepageConfiguration initial) : configuration = initial {
    loaded = _load();
  }

  Map<String, HomepageWidgetInfo> get catalog;

  Future<HomepageConfiguration> read();
  Future<void> write(HomepageConfiguration configuration);

  bool get editing => _draft != null;
  bool get saving => _saving;

  /// False until the saved layout is read. Edit mode waits for it.
  bool get ready => _ready;

  /// The widgets the homepage shows: the draft in edit mode, else the saved layout.
  List<HomepageWidgetConfig> get widgets => _draft ?? configuration.widgets;

  Future<void> _load() async {
    configuration = await read();
    _ready = true;
    notifyListeners();
  }

  void startEdit() {
    if (!_ready || editing) {
      return;
    }
    _draft = [...configuration.widgets];
    notifyListeners();
  }

  /// Puts the widget at the bottom, or changes its size when it is on the homepage.
  void add(String widgetId, WidgetSize size) {
    final draft = _draft;
    if (draft == null || _saving) {
      return;
    }
    final widget = HomepageWidgetConfig(widgetId: widgetId, size: size);
    final index = draft.indexWhere((w) => w.widgetId == widgetId);
    if (index >= 0) {
      draft[index] = widget;
    } else {
      draft.add(widget);
    }
    notifyListeners();
  }

  void remove(String widgetId) {
    final draft = _draft;
    if (draft == null || _saving) {
      return;
    }
    draft.removeWhere((w) => w.widgetId == widgetId);
    notifyListeners();
  }

  /// Moves [dragged] into the place of [target].
  void moveTo(String dragged, String target) {
    final draft = _draft;
    if (draft == null || _saving || dragged == target) {
      return;
    }
    final from = draft.indexWhere((w) => w.widgetId == dragged);
    final to = draft.indexWhere((w) => w.widgetId == target);
    if (from < 0 || to < 0) {
      return;
    }
    draft.insert(to, draft.removeAt(from));
    notifyListeners();
  }

  /// Saves the draft and ends edit mode. On a failure the draft stays.
  Future<void> finishEdit() async {
    final draft = _draft;
    if (draft == null || _saving) {
      return;
    }
    _saving = true;
    notifyListeners();
    try {
      final next = HomepageConfiguration(widgets: [...draft]);
      await write(next);
      configuration = next;
      _draft = null;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
