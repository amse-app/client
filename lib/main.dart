import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

//TODO: android config
//TODO: web config

void main() {
  runApp(const ProviderScope(
    child: AmseApp(),
  ));
}
