import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'features/user/home_screen.dart';
import 'features/operator/dashboard_screen.dart';
import 'providers/camera_provider.dart';
import 'providers/printer_provider.dart';
import 'providers/storage_provider.dart';
import 'providers/grid_provider.dart';
import 'providers/template_provider.dart';
import 'providers/session_provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if running on Windows (Operator) or Android (User)
  if (Platform.isWindows) {
    // Windows - Run Operator App
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1024, 768),
      center: true,
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Photo Booth - Operator',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CameraProvider()),
          ChangeNotifierProvider(create: (_) => PrinterProvider()),
          ChangeNotifierProvider(create: (_) => StorageProvider()),
          ChangeNotifierProvider(create: (_) => GridProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
          ChangeNotifierProvider(create: (_) => SessionProvider()),
        ],
        child: const OperatorApp(),
      ),
    );
  } else {
    // Android/Mobile - Run User App
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CameraProvider()),
          ChangeNotifierProvider(create: (_) => StorageProvider()),
          ChangeNotifierProvider(create: (_) => GridProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
          ChangeNotifierProvider(create: (_) => SessionProvider()),
        ],
        child: const UserApp(),
      ),
    );
  }
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Booth V2 - User',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class OperatorApp extends StatelessWidget {
  const OperatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Booth V2 - Operator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const OperatorDashboardScreen(),
    );
  }
}
