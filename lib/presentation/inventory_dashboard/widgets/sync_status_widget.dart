import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const SyncStatusWidget({
    Key? key,
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline && !isSyncing) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSyncing
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.warningLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSyncing
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
              : AppTheme.warningLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            )
          else
            CustomIconWidget(
              iconName: isOnline ? 'sync' : 'sync_disabled',
              color: isOnline
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.warningLight,
              size: 16,
            ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              isSyncing
                  ? 'Syncing data...'
                  : isOnline
                      ? 'Data synced'
                      : lastSyncTime != null
                          ? 'Offline - Last sync: ${_formatTime(lastSyncTime!)}'
                          : 'Offline - No recent sync',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSyncing
                    ? AppTheme.lightTheme.colorScheme.primary
                    : isOnline
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.warningLight,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
