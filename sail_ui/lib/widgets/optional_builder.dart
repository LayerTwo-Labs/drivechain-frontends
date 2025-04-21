import 'package:flutter/material.dart';

abstract class SailOptional<T> extends StatelessWidget {
  const SailOptional({super.key});

  T? get value;
}
