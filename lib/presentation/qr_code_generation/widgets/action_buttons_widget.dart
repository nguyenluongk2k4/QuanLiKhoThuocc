import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onPrint;
  final bool isLoading;

  const ActionButtonsWidget({
    Key? key,
    required this.onDownload,
    required this.onShare,
    required this.onPrint,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Action - Download
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onDownload,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'download',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
            label: Text(
              isLoading ? 'Downloading...' : 'Download QR Code',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: AppTheme.lightTheme.elevatedButtonTheme.style?.copyWith(
              backgroundColor: WidgetStateProperty.all(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        // Secondary Actions Row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onShare,
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Share',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onPrint,
                  icon: CustomIconWidget(
                    iconName: 'print',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Print',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
