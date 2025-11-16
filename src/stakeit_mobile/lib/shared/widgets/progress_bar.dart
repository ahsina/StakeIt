import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final String? label;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.showPercentage = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = progress.clamp(0.0, 1.0);
    final percentage = (effectiveProgress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (showPercentage)
                Text(
                  '$percentage%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXS),
        ],
        ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: effectiveProgress,
              backgroundColor: backgroundColor ?? AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                progressColor ?? AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final String? label;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
    this.showPercentage = false,
    this.label,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _animation = Tween<double>(
        begin: _previousProgress.clamp(0.0, 1.0),
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ProgressBar(
          progress: _animation.value,
          height: widget.height,
          backgroundColor: widget.backgroundColor,
          progressColor: widget.progressColor,
          borderRadius: widget.borderRadius,
          showPercentage: widget.showPercentage,
          label: widget.label,
        );
      },
    );
  }
}

class StakeProgressBar extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final bool showLabel;

  const StakeProgressBar({
    super.key,
    required this.currentDay,
    required this.totalDays,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalDays > 0 ? currentDay / totalDays : 0.0;
    final daysRemaining = totalDays - currentDay;

    return AnimatedProgressBar(
      progress: progress,
      height: 12,
      progressColor: _getProgressColor(progress),
      showPercentage: false,
      label: showLabel ? 'Jour $currentDay/$totalDays ($daysRemaining jours restants)' : null,
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.stakeCompleted;
    if (progress >= 0.5) return AppColors.secondary;
    if (progress >= 0.25) return AppColors.warning;
    return AppColors.primary;
  }
}

class CircularProgressIndicatorCustom extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? center;

  const CircularProgressIndicatorCustom({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: effectiveProgress,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? AppColors.border,
              valueColor: AlwaysStoppedAnimation(
                progressColor ?? AppColors.primary,
              ),
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int nextLevelXP;
  final int currentLevel;

  const XPProgressBar({
    super.key,
    required this.currentXP,
    required this.nextLevelXP,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    final xpInCurrentLevel = currentXP % nextLevelXP;
    final progress = xpInCurrentLevel / nextLevelXP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Niveau $currentLevel',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$xpInCurrentLevel / $nextLevelXP XP',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingS),
        AnimatedProgressBar(
          progress: progress,
          height: 12,
          progressColor: AppColors.secondary,
        ),
      ],
    );
  }
}
