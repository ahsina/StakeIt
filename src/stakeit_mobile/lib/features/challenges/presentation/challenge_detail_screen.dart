import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../shared/models/challenge_model.dart';
import '../../../shared/models/stake_model.dart';
import '../../../core/router/app_router.dart';
import '../data/providers/challenge_provider.dart';
import '../../../shared/services/signalr_service.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final int challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState
    extends ConsumerState<ChallengeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final List<ChallengeMessageEvent> _realtimeMessages = [];
  StreamSubscription<ChallengeMessageEvent>? _messageSubscription;
  StreamSubscription<ProofSubmittedEvent>? _proofSubscription;
  StreamSubscription<LeaderboardUpdatedEvent>? _leaderboardSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _connectToSignalR();
  }

  @override
  void dispose() {
    _disconnectFromSignalR();
    _tabController.dispose();
    _messageController.dispose();
    _messageSubscription?.cancel();
    _proofSubscription?.cancel();
    _leaderboardSubscription?.cancel();
    super.dispose();
  }

  Future<void> _connectToSignalR() async {
    try {
      final signalR = ref.read(signalRServiceProvider);

      // Connect to SignalR hub
      await signalR.connect();

      // Join this challenge's room
      await signalR.joinChallenge(widget.challengeId);

      // Listen to new messages
      _messageSubscription = signalR.onMessageReceived.listen((event) {
        if (event.challengeId == widget.challengeId) {
          setState(() {
            _realtimeMessages.add(event);
          });
          // Scroll to bottom when new message arrives
          _scrollToBottom();
        }
      });

      // Listen to proof submissions
      _proofSubscription = signalR.onProofSubmitted.listen((event) {
        if (event.challengeId == widget.challengeId) {
          // Refresh leaderboard
          ref.refresh(leaderboardProvider(widget.challengeId));
          // Show snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${event.userName} a soumis une preuve!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      });

      // Listen to leaderboard updates
      _leaderboardSubscription = signalR.onLeaderboardUpdated.listen((event) {
        if (event.challengeId == widget.challengeId) {
          // Refresh leaderboard
          ref.refresh(leaderboardProvider(widget.challengeId));
        }
      });
    } catch (e) {
      print('SignalR connection error: $e');
    }
  }

  Future<void> _disconnectFromSignalR() async {
    try {
      final signalR = ref.read(signalRServiceProvider);
      await signalR.leaveChallenge(widget.challengeId);
    } catch (e) {
      print('SignalR disconnect error: $e');
    }
  }

  void _scrollToBottom() {
    // Delay to ensure message is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      // This would need a ScrollController in the chat tab
      // For now, we'll just let it auto-scroll
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(challengeDetailProvider(widget.challengeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du Challenge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context, ref),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Détails', icon: Icon(Icons.info_outline)),
            Tab(text: 'Classement', icon: Icon(Icons.leaderboard)),
            Tab(text: 'Chat', icon: Icon(Icons.chat)),
          ],
        ),
      ),
      body: challengeAsync.when(
        data: (challenge) => TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(context, ref, challenge),
            _buildLeaderboardTab(context, ref),
            _buildChatTab(context, ref, challenge),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur de chargement'),
              const SizedBox(height: 8),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(challengeDetailProvider(widget.challengeId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(
      BuildContext context, WidgetRef ref, ChallengeModel challenge) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(challengeDetailProvider(widget.challengeId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Badge
          _buildStatusBadge(context, challenge),
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
                      _getCategoryIcon(challenge.category),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  if (challenge.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      challenge.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Entry Fee and Prize Pool
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frais d\'entrée',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${challenge.entryFeeEUR.toStringAsFixed(0)}€',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cagnotte totale',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${challenge.totalPrizePool.toStringAsFixed(0)}€',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Participants Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participants',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${challenge.currentParticipants} / ${challenge.maxParticipants}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${challenge.fillPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: challenge.fillPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 12),
                  if (challenge.isFull)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          const Text('Challenge complet'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dates Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dates',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Début',
                    _formatDate(challenge.startDate),
                    Icons.play_circle,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Fin',
                    _formatDate(challenge.endDate),
                    Icons.stop_circle,
                  ),
                  if (!challenge.isStarted) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Démarre dans',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(challenge.timeUntilStart),
                                style:
                                    Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (!challenge.isEnded) ...[
                    const Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Temps restant',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(challenge.timeRemaining),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.orange,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Type',
                    _getChallengeTypeName(challenge.challengeType),
                    Icons.emoji_events,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Objectif',
                    '${challenge.targetCount} fois',
                    Icons.flag,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Mode de preuve',
                    _getProofModeName(challenge.proofMode),
                    Icons.verified,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    'Créateur',
                    challenge.creatorName,
                    Icons.person,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Join/Leave Button
          if (!challenge.isEnded)
            _buildActionButton(context, ref, challenge),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider(widget.challengeId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(leaderboardProvider(widget.challengeId));
      },
      child: leaderboardAsync.when(
        data: (participants) {
          if (participants.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Aucun participant pour le moment'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return _buildLeaderboardItem(context, participant);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(leaderboardProvider(widget.challengeId)),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
      BuildContext context, ChallengeParticipantModel participant) {
    Color rankColor;
    IconData rankIcon;

    if (participant.rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (participant.rank == 2) {
      rankColor = Colors.grey[400]!;
      rankIcon = Icons.workspace_premium;
    } else if (participant.rank == 3) {
      rankColor = Colors.brown;
      rankIcon = Icons.military_tech;
    } else {
      rankColor = Colors.grey;
      rankIcon = Icons.tag;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: participant.rank <= 3
                    ? Icon(rankIcon, color: rankColor, size: 24)
                    : Text(
                        '${participant.rank}',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.userName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: participant.progressPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${participant.progressPercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Score
            Column(
              children: [
                Text(
                  '${participant.currentCount}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (participant.hasCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(
      BuildContext context, WidgetRef ref, ChallengeModel challenge) {
    final messagesAsync = ref.watch(messagesProvider(widget.challengeId));

    return Column(
      children: [
        // Messages List
        Expanded(
          child: messagesAsync.when(
            data: (historicalMessages) {
              // Combine historical and real-time messages
              final allMessagesCount = historicalMessages.length + _realtimeMessages.length;

              if (allMessagesCount == 0) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Aucun message pour le moment'),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allMessagesCount,
                reverse: true,
                itemBuilder: (context, index) {
                  // Realtime messages appear at the bottom (newest)
                  if (index < _realtimeMessages.length) {
                    final rtIndex = _realtimeMessages.length - 1 - index;
                    final event = _realtimeMessages[rtIndex];
                    return _buildRealtimeMessageItem(context, event);
                  }

                  // Historical messages appear above
                  final histIndex = index - _realtimeMessages.length;
                  final message = historicalMessages[historicalMessages.length - 1 - histIndex];
                  return _buildMessageItem(context, message);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.refresh(messagesProvider(widget.challengeId)),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Message Input
        if (challenge.status == ChallengeStatus.active)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrivez un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(ref),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _sendMessage(ref),
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageItem(
      BuildContext context, ChallengeMessageModel message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  message.senderName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(message.sentAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(message.message),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeMessageItem(
      BuildContext context, ChallengeMessageEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  event.userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                event.userName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(event.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(event.message),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ChallengeModel challenge) {
    Color color;
    String text;
    IconData icon;

    switch (challenge.status) {
      case ChallengeStatus.open:
        color = Colors.blue;
        text = 'Ouvert';
        icon = Icons.door_front_door;
        break;
      case ChallengeStatus.active:
        color = Colors.green;
        text = 'En cours';
        icon = Icons.play_circle;
        break;
      case ChallengeStatus.completed:
        color = Colors.purple;
        text = 'Terminé';
        icon = Icons.check_circle;
        break;
      case ChallengeStatus.cancelled:
        color = Colors.grey;
        text = 'Annulé';
        icon = Icons.cancel;
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

  Widget _buildActionButton(
      BuildContext context, WidgetRef ref, ChallengeModel challenge) {
    final isParticipant =
        challenge.participants.any((p) => p.userId == /* current user id */ 0);

    if (isParticipant) {
      if (!challenge.isStarted) {
        return OutlinedButton(
          onPressed: () => _handleLeaveChallenge(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Quitter le challenge'),
        );
      }
      return const SizedBox.shrink();
    } else {
      if (challenge.isFull) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('Challenge complet'),
          ),
        );
      }

      return ElevatedButton(
        onPressed: () => _handleJoinChallenge(context, ref),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Rejoindre le challenge'),
      );
    }
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

  String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.firstToComplete:
        return 'Premier à compléter';
      case ChallengeType.highestScore:
        return 'Score le plus élevé';
      case ChallengeType.teamBased:
        return 'En équipe';
    }
  }

  String _getProofModeName(ProofMode mode) {
    switch (mode) {
      case ProofMode.gps:
        return 'GPS';
      case ProofMode.photo:
        return 'Photo';
      case ProofMode.manual:
        return 'Manuel';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}j ${duration.inHours % 24}h';
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
              title: const Text('Annuler le challenge'),
              onTap: () {
                Navigator.pop(context);
                _handleCancelChallenge(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleJoinChallenge(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(challengesProvider.notifier).joinChallenge(widget.challengeId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous avez rejoint le challenge !'),
          backgroundColor: Colors.green,
        ),
      );

      ref.refresh(challengeDetailProvider(widget.challengeId));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLeaveChallenge(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter le challenge'),
        content: const Text(
          'Êtes-vous sûr de vouloir quitter ce challenge ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(challengesProvider.notifier)
            .leaveChallenge(widget.challengeId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez quitté le challenge'),
            backgroundColor: Colors.green,
          ),
        );

        context.go(AppRoutes.home);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelChallenge(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le challenge'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler ce challenge ? '
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
        await ref
            .read(challengesProvider.notifier)
            .cancelChallenge(widget.challengeId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Challenge annulé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        context.go(AppRoutes.home);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(WidgetRef ref) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      // Send message via SignalR for real-time delivery
      final signalR = ref.read(signalRServiceProvider);
      await signalR.sendMessage(widget.challengeId, message);

      _messageController.clear();

      // Note: The message will be received via the SignalR stream
      // and added to _realtimeMessages automatically
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi du message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
