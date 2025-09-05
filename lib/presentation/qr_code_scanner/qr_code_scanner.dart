import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/manual_entry_sheet_widget.dart';
import './widgets/scanner_controls_widget.dart';
import './widgets/scanner_overlay_widget.dart';
import 'widgets/manual_entry_sheet_widget.dart';
import 'widgets/scanner_controls_widget.dart';
import 'widgets/scanner_overlay_widget.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key}) : super(key: key);

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner>
    with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? _scannerController;
  bool _isFlashOn = false;
  bool _isScanning = true;
  bool _hasPermission = false;
  bool _isProcessingCode = false;
  String? _lastScannedCode;

  // Mock ingredient data for demonstration
  final List<Map<String, dynamic>> _mockIngredients = [
    {
      "id": "ing_001",
      "name": "Paracetamol",
      "qrCodeId": "QR001PARA500",
      "unitTypes": ["tablet", "blister", "box"],
      "quantity": 5000,
      "smallestUnit": "tablet",
      "conversionRates": {"tablet": 1, "blister": 10, "box": 100},
    },
    {
      "id": "ing_002",
      "name": "Amoxicillin",
      "qrCodeId": "QR002AMOX250",
      "unitTypes": ["capsule", "strip", "bottle"],
      "quantity": 2400,
      "smallestUnit": "capsule",
      "conversionRates": {"capsule": 1, "strip": 12, "bottle": 144},
    },
    {
      "id": "ing_003",
      "name": "Ibuprofen",
      "qrCodeId": "QR003IBU400",
      "unitTypes": ["tablet", "blister", "pack"],
      "quantity": 3200,
      "smallestUnit": "tablet",
      "conversionRates": {"tablet": 1, "blister": 8, "pack": 80},
    },
    {
      "id": "ing_004",
      "name": "Aspirin",
      "qrCodeId": "QR004ASP100",
      "unitTypes": ["tablet", "bottle"],
      "quantity": 1500,
      "smallestUnit": "tablet",
      "conversionRates": {"tablet": 1, "bottle": 100},
    },
    {
      "id": "ing_005",
      "name": "Metformin",
      "qrCodeId": "QR005MET500",
      "unitTypes": ["tablet", "strip", "box"],
      "quantity": 4800,
      "smallestUnit": "tablet",
      "conversionRates": {"tablet": 1, "strip": 15, "box": 150},
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController();
    _requestCameraPermission();
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    // Reset orientation preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _scannerController;
    if (controller == null) return;

    if (state == AppLifecycleState.inactive) {
      controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      controller.start();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });

    if (!status.isGranted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Camera Permission Required',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This app needs camera access to scan QR codes for ingredient identification. Please grant camera permission to continue.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (!_isProcessingCode && barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        _handleScannedCode(barcode.rawValue!);
      }
    }
  }

  Future<void> _handleScannedCode(String code) async {
    if (_isProcessingCode || code == _lastScannedCode) return;

    setState(() {
      _isProcessingCode = true;
      _isScanning = false;
      _lastScannedCode = code;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Pause camera during processing
    _scannerController?.stop();

    try {
      // Simulate Firebase query delay
      await Future.delayed(Duration(milliseconds: 500));

      // Find ingredient by QR code ID
      final ingredient = _mockIngredients.firstWhere(
        (ing) => (ing["qrCodeId"] as String) == code,
        orElse: () => {},
      );

      if (ingredient.isNotEmpty) {
        // Show success toast
        Fluttertoast.showToast(
          msg: "Ingredient found: ${ingredient["name"]}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          textColor: Colors.white,
        );

        // Navigate to dispensing dialog
        Navigator.pushNamed(
          context,
          '/dispensing-dialog',
          arguments: ingredient,
        ).then((_) {
          // Reset scanner when returning
          _resetScanner();
        });
      } else {
        // Show error toast for ingredient not found
        Fluttertoast.showToast(
          msg: "Ingredient not found. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          textColor: Colors.white,
        );
        _resetScanner();
      }
    } catch (e) {
      // Show error toast
      Fluttertoast.showToast(
        msg: "Error processing QR code. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: Colors.white,
      );
      _resetScanner();
    }
  }

  void _resetScanner() {
    setState(() {
      _isProcessingCode = false;
      _isScanning = true;
      _lastScannedCode = null;
    });
  }

  Future<void> _toggleFlash() async {
    try {
      await _scannerController?.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Flash not available on this device",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        textColor: Colors.white,
      );
    }
  }

  void _showManualEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualEntrySheetWidget(
        onCodeEntered: (code) {
          Navigator.of(context).pop();
          _handleScannedCode(code);
        },
      ),
    );
  }

  void _closeScanner() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_hasPermission
          ? _buildPermissionDeniedView()
          : Stack(
              children: [
                // QR Camera View
                MobileScanner(
                  key: qrKey,
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),

                // Scanner overlay with animated frame
                ScannerOverlayWidget(
                  isScanning: _isScanning && !_isProcessingCode,
                  onManualEntry: _showManualEntrySheet,
                ),

                // Scanner controls
                ScannerControlsWidget(
                  isFlashOn: _isFlashOn,
                  onFlashToggle: _toggleFlash,
                  onClose: _closeScanner,
                ),

                // Processing overlay
                if (_isProcessingCode)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12.w,
                              height: 12.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'Processing QR Code...',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  Text(
                    'QR Code Scanner',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'camera_alt',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 60,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Camera Permission Required',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'To scan QR codes for ingredient identification, this app needs access to your device camera. Please grant camera permission to continue.',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            openAppSettings();
                          },
                          child: Text('Open Settings'),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _requestCameraPermission,
                          child: Text('Try Again'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}