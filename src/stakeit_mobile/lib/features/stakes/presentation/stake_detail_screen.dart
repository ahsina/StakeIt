import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
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
            onPressed: () => _showOptionsMenu(context, ref),
          ),
        ],
      ),
      body: stakeAsync.when(
        data: (stake) => _buildStakeDetail(context, ref, stake),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(stakeDetailProvider(stakeId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
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
          _buildStatusBadge(context, stake),
          const SizedBox(height: 16),

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
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  if (stake.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      stake.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Amount
                  Row(
                    children: [
                      const Icon(Icons.euro, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '${stake.amountEUR.toStringAsFixed(2)} EUR',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progression',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${stake.currentCount} / ${stake.requiredCount}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${stake.progressPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: stake.progressPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Temps restant',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(stake.timeRemaining),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Se termine le ${_formatDate(stake.endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Détails',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
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
                    'Créé le',
                    _formatDate(stake.createdAt),
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

  Widget _buildStatusBadge(BuildContext context, StakeModel stake) {
    Color color;
    String text;
    IconData icon;

    switch (stake.status) {
      case StakeStatus.active:
        color = Colors.blue;
        text = 'Actif';
        icon = Icons.play_circle;
        break;
      case StakeStatus.completed:
        color = Colors.green;
        text = 'Complété';
        icon = Icons.check_circle;
        break;
      case StakeStatus.failed:
        color = Colors.red;
        text = 'Échoué';
        icon = Icons.cancel;
        break;
      case StakeStatus.cancelled:
        color = Colors.grey;
        text = 'Annulé';
        icon = Icons.block;
        break;
      case StakeStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        icon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
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
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preuves soumises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            proofsAsync.when(
              data: (proofs) {
                if (proofs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aucune preuve soumise'),
                    ),
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erreur de chargement des preuves'),
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
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(proof.submittedAt),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              proof.validationStatus,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (proof.notes != null) ...[
          const SizedBox(height: 8),
          Text(
            proof.notes!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (proof.rejectionReason != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Raison: ${proof.rejectionReason}',
              style: const TextStyle(color: Colors.red),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jours ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Annuler le stake'),
              onTap: () {
                Navigator.pop(context);
                _handleCancelStake(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCancelStake(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le stake'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler ce stake ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(stakesProvider.notifier).cancelStake(stakeId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stake annulé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(AppRoutes.home);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showSubmitProofDialog(BuildContext context, WidgetRef ref, StakeModel stake) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soumettre une preuve'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mode de preuve: ${_getProofModeName(stake.proofMode)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Ajoutez des détails...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final request = SubmitProofRequest(
                  notes: notesController.text.isEmpty ? null : notesController.text,
                  // TODO: Add GPS and photo support
                );

                await ref.read(stakesProvider.notifier).submitProof(stakeId, request);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preuve soumise avec succès !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  ref.refresh(stakeDetailProvider(stakeId));
                  ref.refresh(stakeProofsProvider(stakeId));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }
}
