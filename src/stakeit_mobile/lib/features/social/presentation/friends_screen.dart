import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/social_model.dart';
import '../data/providers/social_provider.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsState = ref.watch(friendsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Amis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddFriendDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
        child: friendsState.isLoading && friendsState.friends.isEmpty
            ? const LoadingIndicator(message: 'Chargement des amis...')
            : friendsState.error != null
                ? ErrorDisplay(
                    message: friendsState.error!.toString(),
                    onRetry: () => ref.read(friendsProvider.notifier).refresh(),
                  )
                : friendsState.friends.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: 'Aucun ami',
                        subtitle: 'Ajoutez des amis pour voir leurs activités',
                        actionButton: CustomButton(
                          text: 'Ajouter un ami',
                          icon: Icons.person_add,
                          onPressed: () => _showAddFriendDialog(context, ref),
                          type: ButtonType.primary,
                          size: ButtonSize.large,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: friendsState.friends.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSizes.paddingS),
                        itemBuilder: (context, index) {
                          final friend = friendsState.friends[index];
                          return _buildFriendCard(context, ref, friend);
                        },
                      ),
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, WidgetRef ref, FriendModel friend) {
    return Card(
      child: ListTile(
        leading: AvatarWidget(
          name: friend.fullName,
          imageUrl: friend.avatarUrl,
          size: 48,
        ),
        title: Text(
          friend.fullName,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Row(
          children: [
            Icon(Icons.star, size: 14, color: Colors.amber[700]),
            const SizedBox(width: 4),
            Text('Niveau ${friend.currentLevel}'),
            const SizedBox(width: 12),
            Icon(Icons.local_fire_department, size: 14, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text('${friend.currentStreak} jours'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showFriendOptions(context, ref, friend),
        ),
      ),
    );
  }

  void _showFriendOptions(BuildContext context, WidgetRef ref, FriendModel friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text('Retirer des amis'),
              onTap: () {
                Navigator.pop(context);
                _confirmRemoveFriend(context, ref, friend);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveFriend(
    BuildContext context,
    WidgetRef ref,
    FriendModel friend,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Retirer cet ami',
      message: 'Êtes-vous sûr de vouloir retirer ${friend.fullName} de vos amis ?',
      confirmText: 'Retirer',
      isDangerous: true,
      icon: Icons.person_remove,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(friendsProvider.notifier).removeFriend(friend.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${friend.fullName} retiré de vos amis'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMapper.mapError(e)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un ami'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: 'Email de votre ami',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer une adresse email'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                await ref.read(friendRequestsProvider.notifier).sendFriendRequest(email);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demande d\'ami envoyée'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ErrorMapper.mapError(e)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
