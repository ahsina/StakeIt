import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/social_model.dart';
import '../../../features/auth/data/providers/auth_provider.dart';
import '../data/providers/social_provider.dart';

class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsState = ref.watch(friendRequestsProvider);
    final currentUser = ref.watch(currentUserProvider);

    final receivedRequests = requestsState.requests
        .where((r) =>
            r.receiverId == currentUser?.id &&
            r.status == FriendRequestStatus.pending)
        .toList();

    final sentRequests = requestsState.requests
        .where((r) =>
            r.senderId == currentUser?.id &&
            r.status == FriendRequestStatus.pending)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Demandes d\'ami'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reçues'),
              Tab(text: 'Envoyées'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(friendRequestsProvider.notifier).refresh(),
          child: TabBarView(
            children: [
              // Received Requests
              _buildReceivedRequests(context, ref, requestsState, receivedRequests),
              // Sent Requests
              _buildSentRequests(context, ref, requestsState, sentRequests),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedRequests(
    BuildContext context,
    WidgetRef ref,
    FriendRequestsState state,
    List<FriendRequestModel> requests,
  ) {
    if (state.isLoading && requests.isEmpty) {
      return const LoadingIndicator(message: 'Chargement des demandes...');
    }

    if (state.error != null) {
      return ErrorDisplay(
        message: state.error!.toString(),
        onRetry: () => ref.read(friendRequestsProvider.notifier).refresh(),
      );
    }

    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Aucune demande',
        subtitle: 'Vous n\'avez pas de demandes d\'ami en attente',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.paddingS),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildReceivedRequestCard(context, ref, request);
      },
    );
  }

  Widget _buildReceivedRequestCard(
    BuildContext context,
    WidgetRef ref,
    FriendRequestModel request,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AvatarWidget(
              name: request.senderFullName,
              imageUrl: request.senderAvatarUrl,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.senderFullName,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.senderEmail,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatRelativeTime(request.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.check, size: 20),
                  onPressed: () => _respondToRequest(context, ref, request.id, true),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton.outlined(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _respondToRequest(context, ref, request.id, false),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentRequests(
    BuildContext context,
    WidgetRef ref,
    FriendRequestsState state,
    List<FriendRequestModel> requests,
  ) {
    if (state.isLoading && requests.isEmpty) {
      return const LoadingIndicator(message: 'Chargement des demandes...');
    }

    if (state.error != null) {
      return ErrorDisplay(
        message: state.error!.toString(),
        onRetry: () => ref.read(friendRequestsProvider.notifier).refresh(),
      );
    }

    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.outbox_outlined,
        title: 'Aucune demande envoyée',
        subtitle: 'Vous n\'avez pas envoyé de demandes d\'ami',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.paddingS),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildSentRequestCard(context, ref, request);
      },
    );
  }

  Widget _buildSentRequestCard(
    BuildContext context,
    WidgetRef ref,
    FriendRequestModel request,
  ) {
    return Card(
      child: ListTile(
        leading: AvatarWidget(
          name: request.receiverFullName,
          imageUrl: request.receiverAvatarUrl,
          size: 48,
        ),
        title: Text(request.receiverFullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.receiverEmail),
            const SizedBox(height: 4),
            Text(
              'Envoyée ${DateFormatter.formatRelativeTime(request.createdAt)}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _cancelRequest(context, ref, request),
        ),
      ),
    );
  }

  Future<void> _respondToRequest(
    BuildContext context,
    WidgetRef ref,
    int requestId,
    bool accept,
  ) async {
    try {
      await ref.read(friendRequestsProvider.notifier).respondToRequest(requestId, accept);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? 'Demande acceptée' : 'Demande refusée'),
            backgroundColor: accept ? AppColors.success : AppColors.info,
          ),
        );

        // Refresh friends list if accepted
        if (accept) {
          ref.read(friendsProvider.notifier).refresh();
        }
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

  Future<void> _cancelRequest(
    BuildContext context,
    WidgetRef ref,
    FriendRequestModel request,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Annuler la demande',
      message: 'Voulez-vous annuler la demande d\'ami envoyée à ${request.receiverFullName} ?',
      confirmText: 'Annuler',
      isDangerous: true,
      icon: Icons.cancel,
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(friendRequestsProvider.notifier).cancelRequest(request.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande annulée'),
              backgroundColor: AppColors.info,
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
}
