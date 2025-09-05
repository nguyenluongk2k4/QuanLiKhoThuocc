import 'dart:io' if (dart.library.io) 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/ingredient_info_widget.dart';
import './widgets/preview_mode_widget.dart';
import './widgets/qr_code_display_widget.dart';

class QrCodeGeneration extends StatefulWidget {
  const QrCodeGeneration({Key? key}) : super(key: key);

  @override
  State<QrCodeGeneration> createState() => _QrCodeGenerationState();
}

class _QrCodeGenerationState extends State<QrCodeGeneration> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isLoading = false;
  bool _isPreviewMode = false;

  // Mock ingredient data - in real app this would come from navigation arguments
  final Map<String, dynamic> _ingredientData = {
    "id": "ing_001",
    "name": "Acetaminophen 500mg",
    "qrCodeId": "QR_ACE_500_001_2025",
    "quantity": 2500.0,
    "unitTypes": ["tablet", "blister", "box"],
    "smallestUnit": "tablet",
    "currentStock": 2500.0,
    "lastUpdated": "2025-08-12T02:26:29.441091",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ingredient Information
              IngredientInfoWidget(
                ingredientName: _ingredientData["name"] as String,
                currentStock: _ingredientData["currentStock"] as double,
                unit: _ingredientData["smallestUnit"] as String,
              ),
              SizedBox(height: 3.h),

              // QR Code Display
              Center(
                child: RepaintBoundary(
                  key: _qrKey,
                  child: QrCodeDisplayWidget(
                    qrCodeId: _ingredientData["qrCodeId"] as String,
                    ingredientName: _ingredientData["name"] as String,
                    size: 60.w,
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Preview Mode Toggle
              PreviewModeWidget(
                qrCodeId: _ingredientData["qrCodeId"] as String,
                ingredientName: _ingredientData["name"] as String,
                isPreviewMode: _isPreviewMode,
                onTogglePreview: _togglePreviewMode,
              ),
              SizedBox(height: 4.h),

              // Action Buttons
              ActionButtonsWidget(
                onDownload: _downloadQrCode,
                onShare: _shareQrCode,
                onPrint: _printQrCode,
                isLoading: _isLoading,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      elevation: AppTheme.lightTheme.appBarTheme.elevation,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QR Code Generation',
            style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
          ),
          Text(
            'Generate & Download QR Label',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showQrInfo,
          icon: CustomIconWidget(
            iconName: 'info_outline',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });

    HapticFeedback.lightImpact();

    Fluttertoast.showToast(
      msg: _isPreviewMode
          ? "Preview mode enabled - See how QR appears when scanned"
          : "Preview mode disabled",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor:
          AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.8),
      textColor: AppTheme.lightTheme.colorScheme.surface,
      fontSize: 14.sp,
    );
  }

  Future<void> _downloadQrCode() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('QR Code not found');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception('Failed to generate QR image');
      }

      final fileName =
          'QR_${_ingredientData["name"]?.toString().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';

      if (kIsWeb) {
        // Web download implementation
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile download implementation - save to gallery/downloads
        await _savePngToDevice(pngBytes, fileName);
      }

      HapticFeedback.mediumImpact();

      Fluttertoast.showToast(
        msg: "QR Code downloaded successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        textColor: AppTheme.lightTheme.colorScheme.surface,
        fontSize: 14.sp,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to download QR Code. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.surface,
        fontSize: 14.sp,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePngToDevice(Uint8List pngBytes, String fileName) async {
    if (!kIsWeb && Platform.isAndroid) {
      // Android implementation - save to Downloads folder
      try {
        final directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pngBytes);
      } catch (e) {
        // Fallback to app documents directory
        final directory = Directory('/data/data/com.example.pharmastock/files');
        await directory.create(recursive: true);
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(pngBytes);
      }
    } else if (!kIsWeb && Platform.isIOS) {
      // iOS implementation - save to Photos library would require photo_manager package
      // For now, save to app documents directory
      final directory =
          Directory('/var/mobile/Containers/Data/Application/Documents');
      await directory.create(recursive: true);
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);
    }
  }

  Future<void> _shareQrCode() async {
    if (_isLoading) return;

    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('QR Code not found');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        throw Exception('Failed to generate QR image');
      }

      final fileName =
          'QR_${_ingredientData["name"]?.toString().replaceAll(' ', '_')}.png';

      if (kIsWeb) {
        // Web sharing implementation - copy to clipboard or download
        await Clipboard.setData(ClipboardData(
            text:
                'QR Code for ${_ingredientData["name"]} - ID: ${_ingredientData["qrCodeId"]}'));

        Fluttertoast.showToast(
          msg: "QR Code details copied to clipboard!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          textColor: AppTheme.lightTheme.colorScheme.surface,
          fontSize: 14.sp,
        );
      } else {
        // Mobile sharing implementation
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'QR Code for ${_ingredientData["name"]} - Pharmaceutical Inventory',
          subject: 'PharmaStock QR Code',
        );
      }

      HapticFeedback.lightImpact();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to share QR Code. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.surface,
        fontSize: 14.sp,
      );
    }
  }

  Future<void> _printQrCode() async {
    if (_isLoading) return;

    try {
      if (kIsWeb) {
        // Web printing implementation
        final printContent = '''
          <html>
            <head>
              <title>QR Code - ${_ingredientData["name"]}</title>
              <style>
                body { font-family: Arial, sans-serif; text-align: center; padding: 20px; }
                .qr-container { margin: 20px auto; }
                .ingredient-info { margin-bottom: 20px; }
                .qr-id { font-family: monospace; font-size: 12px; margin-top: 10px; }
              </style>
            </head>
            <body>
              <div class="ingredient-info">
                <h2>${_ingredientData["name"]}</h2>
                <p>Current Stock: ${(_ingredientData["currentStock"] as double).toStringAsFixed(0)} ${_ingredientData["smallestUnit"]}</p>
              </div>
              <div class="qr-container">
                <div id="qr-code"></div>
                <div class="qr-id">${_ingredientData["qrCodeId"]}</div>
              </div>
              <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
              <script>
                QRCode.toCanvas(document.getElementById('qr-code'), '${_ingredientData["qrCodeId"]}', {
                  width: 200,
                  margin: 2,
                  color: { dark: '#000000', light: '#FFFFFF' }
                });
                window.print();
              </script>
            </body>
          </html>
        ''';

        final blob = html.Blob([printContent], 'text/html');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile printing would require printing package
        // For now, show a message about printing capability
        Fluttertoast.showToast(
          msg: "Print functionality available on web version",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.8),
          textColor: AppTheme.lightTheme.colorScheme.surface,
          fontSize: 14.sp,
        );
      }

      HapticFeedback.lightImpact();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Print feature not available. Please download and print manually.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.surface,
        fontSize: 14.sp,
      );
    }
  }

  void _showQrInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.dialogTheme.backgroundColor,
          shape: AppTheme.lightTheme.dialogTheme.shape,
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'qr_code',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'QR Code Information',
                style: AppTheme.lightTheme.dialogTheme.titleTextStyle,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This QR code contains the unique identifier for pharmaceutical inventory tracking.',
                style: AppTheme.lightTheme.dialogTheme.contentTextStyle,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR Code Features:',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildInfoRow('High error correction level'),
                    _buildInfoRow('Optimized for pharmaceutical environments'),
                    _buildInfoRow('Compatible with standard QR scanners'),
                    _buildInfoRow('Contains unique ingredient identifier'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
