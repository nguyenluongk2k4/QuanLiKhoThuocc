import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScannerOverlayWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onManualEntry;

  const ScannerOverlayWidget({
    Key? key,
    required this.isScanning,
    this.onManualEntry,
  }) : super(key: key);

  @override
  State<ScannerOverlayWidget> createState() => _ScannerOverlayWidgetState();
}

class _ScannerOverlayWidgetState extends State<ScannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isScanning) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScannerOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Dark overlay with transparent scanning area
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // Scanning frame with animated corners
          Center(
            child: Container(
              width: 70.w,
              height: 70.w,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                              left: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                              right: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                              left: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                              right: BorderSide(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(
                                        alpha: 0.8 + 0.2 * _animation.value),
                                width: 4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning instruction text
          Positioned(
            bottom: 25.h,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                children: [
                  Text(
                    'Position QR code within the frame',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  widget.isScanning
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 4.w,
                                height: 4.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Scanning...',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),

          // Manual entry button
          Positioned(
            bottom: 15.h,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton(
                onPressed: widget.onManualEntry,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'keyboard',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Enter Code Manually',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
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
}
