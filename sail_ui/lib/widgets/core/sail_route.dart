import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

/// Platform page route so apps don't import Material for navigation.
Route<T> sailRoute<T>({required WidgetBuilder builder}) {
  return MaterialPageRoute<T>(builder: builder);
}
