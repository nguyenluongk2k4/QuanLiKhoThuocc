import 'package:flutter/material.dart';
import '../presentation/google_sign_in_screen/google_sign_in_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/qr_code_generation/qr_code_generation.dart';
import '../presentation/qr_code_scanner/qr_code_scanner.dart';
import '../presentation/dispensing_dialog/dispensing_dialog.dart';
import '../presentation/inventory_dashboard/inventory_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String googleSignIn = '/google-sign-in-screen';
  static const String splash = '/splash-screen';
  static const String qrCodeGeneration = '/qr-code-generation';
  static const String qrCodeScanner = '/qr-code-scanner';
  static const String dispensingDialog = '/dispensing-dialog';
  static const String inventoryDashboard = '/inventory-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    googleSignIn: (context) => const GoogleSignInScreen(),
    splash: (context) => const SplashScreen(),
    qrCodeGeneration: (context) => const QrCodeGeneration(),
    qrCodeScanner: (context) => const QrCodeScanner(),
    dispensingDialog: (context) => const DispensingDialog(),
    inventoryDashboard: (context) => const InventoryDashboard(),
    // TODO: Add your other routes here
  };
}
