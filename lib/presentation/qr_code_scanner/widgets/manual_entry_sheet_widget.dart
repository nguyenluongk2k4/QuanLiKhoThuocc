import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ManualEntrySheetWidget extends StatefulWidget {
  final Function(String) onCodeEntered;

  const ManualEntrySheetWidget({
    Key? key,
    required this.onCodeEntered,
  }) : super(key: key);

  @override
  State<ManualEntrySheetWidget> createState() => _ManualEntrySheetWidgetState();
}

class _ManualEntrySheetWidgetState extends State<ManualEntrySheetWidget> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty && !_isProcessing) {
      setState(() {
        _isProcessing = true;
      });
      widget.onCodeEntered(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 3.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter QR Code Manually',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Type the QR code ID if the camera cannot scan it properly',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR Code ID',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  enabled: !_isProcessing,
                  decoration: InputDecoration(
                    hintText: 'Enter QR code ID',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'qr_code',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    suffixIcon: _codeController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    _codeController.clear();
                                    setState(() {});
                                  },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Action buttons
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _codeController.text.trim().isEmpty || _isProcessing
                            ? null
                            : _handleSubmit,
                    child: _isProcessing
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text('Submit'),
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 4.h),
        ],
      ),
    );
  }
}
