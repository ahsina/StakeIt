import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/stake_model.dart';
import '../../../shared/models/social_model.dart';
import '../../../core/theme/app_constants.dart';
import '../../../features/social/data/providers/social_provider.dart';

class FailureDestinationSelector extends ConsumerStatefulWidget {
  final FailureDestination selectedDestination;
  final ValueChanged<FailureDestination> onDestinationChanged;
  final int? selectedFriendId;
  final ValueChanged<int?>? onFriendSelected;
  final String? selectedCharityId;
  final ValueChanged<String?>? onCharitySelected;

  const FailureDestinationSelector({
    super.key,
    required this.selectedDestination,
    required this.onDestinationChanged,
    this.selectedFriendId,
    this.onFriendSelected,
    this.selectedCharityId,
    this.onCharitySelected,
  });

  @override
  ConsumerState<FailureDestinationSelector> createState() => _FailureDestinationSelectorState();
}

class _FailureDestinationSelectorState extends ConsumerState<FailureDestinationSelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'En cas d\'échec',
                  style: AppTextStyles.headingSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choisissez où ira votre mise si vous échouez :',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Platform (Default)
            _buildDestinationTile(
              destination: FailureDestination.platform,
              icon: Icons.business,
              title: 'Commission plateforme',
              subtitle: '10% de commission pour StakeIt',
              color: Colors.blue,
            ),

            // Charity
            _buildDestinationTile(
              destination: FailureDestination.charity,
              icon: Icons.favorite,
              title: 'Don à une association',
              subtitle: 'Votre mise ira à une œuvre caritative',
              color: Colors.red,
            ),

            // Friend
            _buildDestinationTile(
              destination: FailureDestination.friend,
              icon: Icons.people,
              title: 'Donner à un ami',
              subtitle: 'Votre ami recevra votre mise',
              color: Colors.green,
            ),

            // Pool
            _buildDestinationTile(
              destination: FailureDestination.pool,
              icon: Icons.pool,
              title: 'Pot de gains',
              subtitle: 'Contribue au pot pour les futurs gagnants',
              color: Colors.purple,
            ),

            // Additional Selectors
            if (widget.selectedDestination == FailureDestination.friend) ...[
              const SizedBox(height: 16),
              _buildFriendSelector(),
            ],
            if (widget.selectedDestination == FailureDestination.charity) ...[
              const SizedBox(height: 16),
              _buildCharitySelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationTile({
    required FailureDestination destination,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = widget.selectedDestination == destination;

    return InkWell(
      onTap: () => widget.onDestinationChanged(destination),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendSelector() {
    final friendsAsync = ref.watch(friendsProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.person_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Aucun ami ajouté'),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to add friends
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Ajouter des amis'),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<int>(
          value: widget.selectedFriendId,
          decoration: const InputDecoration(
            labelText: 'Sélectionner un ami',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          items: friends.map((friend) {
            return DropdownMenuItem<int>(
              value: friend.userId,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text(friend.firstName.substring(0, 1).toUpperCase()),
                  ),
                  const SizedBox(width: 12),
                  Text('${friend.firstName} ${friend.lastName}'),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => widget.onFriendSelected?.call(value),
          validator: (value) {
            if (value == null) {
              return 'Veuillez sélectionner un ami';
            }
            return null;
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Erreur lors du chargement des amis'),
    );
  }

  Widget _buildCharitySelector() {
    final charities = [
      {'id': 'unicef', 'name': 'UNICEF Luxembourg', 'icon': '🧒'},
      {'id': 'red_cross', 'name': 'Croix-Rouge luxembourgeoise', 'icon': '❤️'},
      {'id': 'caritas', 'name': 'Caritas Luxembourg', 'icon': '🤝'},
      {'id': 'wwf', 'name': 'WWF Luxembourg', 'icon': '🐼'},
      {'id': 'handicap', 'name': 'Info-Handicap', 'icon': '♿'},
      {'id': 'cancer', 'name': 'Fondation Cancer', 'icon': '🎗️'},
    ];

    return DropdownButtonFormField<String>(
      value: widget.selectedCharityId,
      decoration: const InputDecoration(
        labelText: 'Sélectionner une association',
        prefixIcon: Icon(Icons.favorite),
        border: OutlineInputBorder(),
      ),
      items: charities.map((charity) {
        return DropdownMenuItem<String>(
          value: charity['id'],
          child: Row(
            children: [
              Text(
                charity['icon']!,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  charity['name']!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => widget.onCharitySelected?.call(value),
      validator: (value) {
        if (value == null) {
          return 'Veuillez sélectionner une association';
        }
        return null;
      },
    );
  }
}
