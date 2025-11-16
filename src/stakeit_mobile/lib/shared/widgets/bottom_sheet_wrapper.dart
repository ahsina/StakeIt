import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class BottomSheetWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  final bool showHandle;
  final Widget? trailing;

  const BottomSheetWrapper({
    super.key,
    required this.title,
    required this.child,
    this.height,
    this.showHandle = true,
    this.trailing,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double? height,
    bool showHandle = true,
    Widget? trailing,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetWrapper(
        title: title,
        height: height,
        showHandle: showHandle,
        trailing: trailing,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final defaultHeight = mediaQuery.size.height * 0.75;

    return Container(
      height: height ?? defaultHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXL),
          topRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: AppSizes.paddingS),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class ScrollableBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showHandle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const ScrollableBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.showHandle = true,
    this.trailing,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool showHandle = true,
    Widget? trailing,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => ScrollableBottomSheet(
        title: title,
        showHandle: showHandle,
        trailing: trailing,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusXL),
              topRight: Radius.circular(AppSizes.radiusXL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showHandle) ...[
                const SizedBox(height: AppSizes.paddingS),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: padding ??
                      const EdgeInsets.all(AppSizes.paddingL),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
