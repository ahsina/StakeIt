import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/utils/error_mapper.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/image_service.dart';
import '../data/providers/stake_provider.dart';

class StakeDetailScreen extends ConsumerWidget {
  final int stakeId;

  const StakeDetailScreen({super.key, required this.stakeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stakeAsync = ref.watch(stakeDetailProvider(stakeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du Stake'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => stakeAsync.whenData((stake) {
              _showOptionsMenu(context, ref, stake);
            }).value,
          ),
        ],
      ),
      body: stakeAsync.when(
        data: (stake) => _buildStakeDetail(context, ref, stake),
        loading: () => const LoadingIndicator(message: 'Chargement du stake...'),
        error: (error, stack) => ErrorDisplay(
          message: ErrorMapper.mapStakeError(error),
          onRetry: () => ref.refresh(stakeDetailProvider(stakeId)),
        ),
      ),
      floatingActionButton: stakeAsync.whenData((stake) {
        if (stake.isActive && !stake.isExpired) {
          return FloatingActionButton.extended(
            onPressed: () => _showSubmitProofDialog(context, ref, stake),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Soumettre une preuve'),
          );
        }
        return null;
      }).value,
    );
  }

  Widget _buildStakeDetail(BuildContext context, WidgetRef ref, StakeModel stake) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(stakeDetailProvider(stakeId));
        ref.refresh(stakeProofsProvider(stakeId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Badge
          StatusBadge.fromStakeStatus(stake.status, isLarge: true),
          const SizedBox(height: AppSizes.paddingM),

          // Title and Description Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getCategoryIcon(stake.category),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stake.title,
                          style: AppTextStyles.headingMedium,
                        ),
                      ),
                    ],
                  ),
                  if (stake.description != null) ...[
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      stake.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.paddingM),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingM),
                  // Amount
                  Row(
                    children: [
                      const Icon(Icons.euro, color: AppColors.secondary),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        CurrencyFormatter.format(stake.amountEUR),
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progression',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  AnimatedProgressBar(
                    progress: stake.progressPercentage / 100,
                    height: 12,
                    showPercentage: true,
                    label: '${stake.currentCount} / ${stake.requiredCount} preuves',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Time Remaining Card
          if (stake.isActive && !stake.isExpired)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: AppColors.primary),
                        const SizedBox(width: AppSizes.paddingS),
                        Text(
                          'Temps restant',
                          style: AppTextStyles.headingSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      DateFormatter.formatTimeRemaining(stake.endDate),
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      'Se termine le ${DateFormatter.formatLongDate(stake.endDate)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails',
                    style: AppTextStyles.headingMedium,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  _buildDetailRow(
                    context,
                    'Catégorie',
                    stake.categoryName,
                    Icons.category,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Mode de preuve',
                    _getProofModeName(stake.proofMode),
                    Icons.verified,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Mode d\'échec',
                    _getFailureModeName(stake.failureMode),
                    Icons.warning,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Fréquence',
                    stake.frequencyName,
                    Icons.repeat,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Créé le',
                    DateFormatter.formatLongDate(stake.createdAt),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Proofs Section
          _buildProofsSection(context, ref, stake),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconM, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Text(
                value,
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProofsSection(BuildContext context, WidgetRef ref, StakeModel stake) {
    final proofsAsync = ref.watch(stakeProofsProvider(stakeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preuves soumises',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppSizes.paddingM),
            proofsAsync.when(
              data: (proofs) {
                if (proofs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.assignment,
                    title: 'Aucune preuve',
                    subtitle: 'Vous n\'avez pas encore soumis de preuve',
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: proofs.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final proof = proofs[index];
                    return _buildProofItem(context, proof);
                  },
                );
              },
              loading: () => const LoadingIndicator(message: 'Chargement des preuves...'),
              error: (error, __) => ErrorDisplay(
                message: ErrorMapper.mapError(error),
                onRetry: () => ref.refresh(stakeProofsProvider(stakeId)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofItem(BuildContext context, StakeProofModel proof) {
    Color statusColor;
    IconData statusIcon;

    switch (proof.validationStatus) {
      case 'Approved':
        statusColor = AppColors.stakeCompleted;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = AppColors.stakeFailed;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(statusIcon, color: statusColor, size: AppSizes.iconM),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(
              child: Text(
                DateFormatter.formatContextualDate(proof.submittedAt),
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Text(
              proof.validationStatus,
              style: AppTextStyles.labelMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (proof.notes != null) ...[
          const SizedBox(height: AppSizes.paddingS),
          Text(
            proof.notes!,
            style: AppTextStyles.bodySmall,
          ),
        ],
        if (proof.rejectionReason != null) ...[
          const SizedBox(height: AppSizes.paddingS),
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text(
              'Raison: ${proof.rejectionReason}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _getCategoryIcon(StakeCategory category) {
    IconData icon;
    Color color;

    switch (category) {
      case StakeCategory.fitness:
        icon = Icons.fitness_center;
        color = Colors.red;
        break;
      case StakeCategory.education:
        icon = Icons.school;
        color = Colors.blue;
        break;
      case StakeCategory.productivity:
        icon = Icons.work;
        color = Colors.purple;
        break;
      case StakeCategory.finance:
        icon = Icons.account_balance;
        color = Colors.green;
        break;
      case StakeCategory.personalDevelopment:
        icon = Icons.self_improvement;
        color = Colors.orange;
        break;
      case StakeCategory.family:
        icon = Icons.family_restroom;
        color = Colors.pink;
        break;
      case StakeCategory.creativity:
        icon = Icons.palette;
        color = Colors.deepPurple;
        break;
      case StakeCategory.home:
        icon = Icons.home;
        color = Colors.brown;
        break;
      case StakeCategory.digitalDetox:
        icon = Icons.phone_disabled;
        color = Colors.teal;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  String _getProofModeName(ProofMode mode) {
    switch (mode) {
      case ProofMode.gps:
        return 'GPS (Localisation)';
      case ProofMode.photo:
        return 'Photo';
      case ProofMode.manual:
        return 'Manuel';
    }
  }

  String _getFailureModeName(FailureMode mode) {
    switch (mode) {
      case FailureMode.allOrNothing:
        return 'Tout ou rien';
      case FailureMode.proRata:
        return 'Prorata';
      case FailureMode.progressive:
        return 'Progressif';
    }
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref, StakeModel stake) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stake.canCancel) ...[
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Annuler le stake'),
                subtitle: Text(
                  'Temps restant: ${_formatDuration(stake.cancellationTimeRemaining)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleCancelStake(context, ref);
                },
              ),
            ] else if (stake.status == StakeStatus.pending) ...[
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.textSecondary),
                title: const Text('Annulation non disponible'),
                subtitle: const Text(
                  'Vous pouvez annuler uniquement dans les 2h après création',
                  style: TextStyle(fontSize: 12),
                ),
                enabled: false,
              ),
            ],
            if (!stake.canCancel || stake.status != StakeStatus.pending) ...[
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Options'),
                subtitle: const Text('Aucune action disponible pour le moment'),
                enabled: false,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '0m';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Future<void> _handleCancelStake(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Annuler le stake',
      message: 'Êtes-vous sûr de vouloir annuler ce stake ? Cette action est irréversible.',
      confirmText: 'Oui, annuler',
      isDangerous: true,
      icon: Icons.cancel,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(stakesProvider.notifier).cancelStake(stakeId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Stake annulé avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AppRoutes.home);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMapper.mapStakeError(e)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showSubmitProofDialog(BuildContext context, WidgetRef ref, StakeModel stake) {
    showDialog(
      context: context,
      builder: (context) => _SubmitProofDialog(
        stake: stake,
        stakeId: stakeId,
      ),
    );
  }
}

// Submit Proof Dialog Widget
class _SubmitProofDialog extends ConsumerStatefulWidget {
  final StakeModel stake;
  final int stakeId;

  const _SubmitProofDialog({
    required this.stake,
    required this.stakeId,
  });

  @override
  ConsumerState<_SubmitProofDialog> createState() => _SubmitProofDialogState();
}

class _SubmitProofDialogState extends ConsumerState<_SubmitProofDialog> {
  final _notesController = TextEditingController();
  LocationData? _location;
  ImageData? _photo;
  bool _isLoadingLocation = false;
  bool _isLoadingPhoto = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          _location = location;
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localisation capturée !'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMapper.mapLocationError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    setState(() => _isLoadingPhoto = true);

    try {
      final imageService = ref.read(imageServiceProvider);

      // Show options: camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sélectionner une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null || !mounted) {
        setState(() => _isLoadingPhoto = false);
        return;
      }

      final photo = source == ImageSource.camera
          ? await imageService.pickFromCamera()
          : await imageService.pickFromGallery();

      if (mounted) {
        setState(() {
          _photo = photo;
          _isLoadingPhoto = false;
        });

        if (photo != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo capturée !'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPhoto = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la capture de photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitProof() async {
    try {
      // Convert photo to base64 if present
      String? photoBase64;
      if (_photo != null) {
        final imageService = ref.read(imageServiceProvider);
        photoBase64 = await imageService.imageToBase64(_photo!);
      }

      final request = SubmitProofRequest(
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        latitude: _location?.latitude,
        longitude: _location?.longitude,
        photoUrl: photoBase64, // Backend will handle base64 to URL conversion
      );

      await ref.read(stakesProvider.notifier).submitProof(widget.stakeId, request);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preuve soumise avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );

        ref.refresh(stakeDetailProvider(widget.stakeId));
        ref.refresh(stakeProofsProvider(widget.stakeId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMapper.mapStakeError(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requiresGPS = widget.stake.proofMode == ProofMode.gps;
    final requiresPhoto = widget.stake.proofMode == ProofMode.photo;

    return AlertDialog(
      title: const Text('Soumettre une preuve'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proof mode info
            InfoCard(
              message: 'Mode: ${_getProofModeName(widget.stake.proofMode)}',
              icon: Icons.info_outline,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.paddingM),

            // GPS Section
            if (requiresGPS) ...[
              Text(
                'Localisation GPS',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingS),
              if (_location != null)
                SuccessCard(
                  message: 'Position: ${_location!.latitude.toStringAsFixed(6)}, ${_location!.longitude.toStringAsFixed(6)}\nPrécision: ${_location!.accuracy.toStringAsFixed(1)}m',
                  icon: Icons.check_circle,
                )
              else
                CustomButton(
                  text: 'Capturer la localisation',
                  icon: Icons.my_location,
                  onPressed: _isLoadingLocation ? null : _captureLocation,
                  type: ButtonType.outlined,
                  size: ButtonSize.medium,
                  isLoading: _isLoadingLocation,
                  isFullWidth: true,
                ),
              const SizedBox(height: AppSizes.paddingM),
            ],

            // Photo Section
            if (requiresPhoto) ...[
              Text(
                'Photo',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.paddingS),
              if (_photo != null) ...[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    image: DecorationImage(
                      image: FileImage(_photo!.file),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Row(
                  children: [
                    Expanded(
                      child: SuccessCard(
                        message: 'Photo capturée\nTaille: ${_photo!.sizeInMB} MB',
                        icon: Icons.check_circle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => setState(() => _photo = null),
                    ),
                  ],
                ),
              ] else
                CustomButton(
                  text: 'Ajouter une photo',
                  icon: Icons.camera_alt,
                  onPressed: _isLoadingPhoto ? null : _capturePhoto,
                  type: ButtonType.outlined,
                  size: ButtonSize.medium,
                  isLoading: _isLoadingPhoto,
                  isFullWidth: true,
                ),
              const SizedBox(height: AppSizes.paddingM),
            ],

            // Notes
            Text(
              'Notes (optionnel)',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingS),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Ajoutez des détails...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        CustomButton(
          text: 'Soumettre',
          onPressed: _canSubmit() ? _submitProof : null,
          type: ButtonType.primary,
          size: ButtonSize.medium,
        ),
      ],
    );
  }

  bool _canSubmit() {
    if (widget.stake.proofMode == ProofMode.gps && _location == null) {
      return false;
    }
    if (widget.stake.proofMode == ProofMode.photo && _photo == null) {
      return false;
    }
    return true;
  }

  String _getProofModeName(ProofMode mode) {
    switch (mode) {
      case ProofMode.manual:
        return 'Manuel';
      case ProofMode.gps:
        return 'GPS';
      case ProofMode.photo:
        return 'Photo';
    }
  }
}
