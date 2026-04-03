import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final logger = LoggerService();

  // Catch Flutter framework errors (widget build, layout, painting)
  FlutterError.onError = (details) {
    logger.error(
      'FlutterError',
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Catch async errors not caught by Flutter (Dart zone errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('PlatformDispatcher', error.toString(), error, stack);
    return true;
  };

  runApp(const ProviderScope(child: ScardApp()));
}
