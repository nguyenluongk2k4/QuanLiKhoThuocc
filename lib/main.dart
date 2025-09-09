import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmastock_manager/services/supabase_service.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../models/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };

  // Initialize Supabase once using the singleton service.
  // Assumption: env asset is at assets/env.json (update if different).
  await SupabaseService.instance.initFromAsset(assetPath: 'assets/env.json');

  // Initialize Hive and register adapters for local storage.
  // Assumption: UsersAdapter is generated via build_runner (users.g.dart).
  await Hive.initFlutter();
  Hive.registerAdapter(UsersAdapter());
  await Hive.openBox<Users>('users_box');

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'pharmastock_manager',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}
