import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? _getColorFromName(name);
    final effectiveTextColor = textColor ?? Colors.white;
    final initials = _getInitials(name);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveBackgroundColor,
        border: showBorder
            ? Border.all(
                color: borderColor ?? Colors.white,
                width: borderWidth,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials(initials, effectiveTextColor);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildInitials(initials, effectiveTextColor);
                },
              ),
            )
          : _buildInitials(initials, effectiveTextColor),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildInitials(String initials, Color textColor) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  Color _getColorFromName(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.categoryFitness,
      AppColors.categoryEducation,
      AppColors.categoryProductivity,
      AppColors.categoryFinance,
      AppColors.categoryPersonalDevelopment,
      AppColors.categoryFamily,
      AppColors.categoryCreativity,
      AppColors.categoryHome,
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

class ParticipantAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isWinner;
  final int? rank;
  final double size;

  const ParticipantAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.isWinner = false,
    this.rank,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AvatarWidget(
          imageUrl: imageUrl,
          name: name,
          size: size,
          showBorder: isWinner,
          borderColor: _getBorderColor(),
          borderWidth: 3,
        ),
        if (rank != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: _getRankColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color? _getBorderColor() {
    if (!isWinner || rank == null) return null;

    switch (rank) {
      case 1:
        return AppColors.medalGold;
      case 2:
        return AppColors.medalSilver;
      case 3:
        return AppColors.medalBronze;
      default:
        return AppColors.secondary;
    }
  }

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return AppColors.medalGold;
      case 2:
        return AppColors.medalSilver;
      case 3:
        return AppColors.medalBronze;
      default:
        return AppColors.textSecondary;
    }
  }
}

class AvatarStack extends StatelessWidget {
  final List<String> names;
  final List<String?> imageUrls;
  final double size;
  final int maxVisible;
  final double overlap;

  const AvatarStack({
    super.key,
    required this.names,
    this.imageUrls = const [],
    this.size = 32,
    this.maxVisible = 3,
    this.overlap = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = names.length > maxVisible ? maxVisible : names.length;
    final extraCount = names.length - maxVisible;

    return SizedBox(
      width: size + (size * overlap * (visibleCount - 1)) + (extraCount > 0 ? size * overlap : 0),
      height: size,
      child: Stack(
        children: [
          ...List.generate(visibleCount, (index) {
            return Positioned(
              left: index * size * overlap,
              child: AvatarWidget(
                imageUrl: index < imageUrls.length ? imageUrls[index] : null,
                name: names[index],
                size: size,
                showBorder: true,
                borderWidth: 2,
              ),
            );
          }),
          if (extraCount > 0)
            Positioned(
              left: visibleCount * size * overlap,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textSecondary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
