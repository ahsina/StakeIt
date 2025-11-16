import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../features/challenges/data/providers/challenge_provider.dart';

class ChallengesTab extends ConsumerStatefulWidget {
  const ChallengesTab({super.key});

  @override
  ConsumerState<ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends ConsumerState<ChallengesTab> {
  String _searchQuery = '';
  StakeCategory? _selectedCategory;
  ChallengeStatus? _selectedStatus;
  ChallengeType? _selectedChallengeType;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Load challenges on init
    Future.microtask(() {
      ref.read(challengesProvider.notifier).loadMyChallenges();
      ref.read(challengesProvider.notifier).loadPublicChallenges();
    });
  }

  List<ChallengeModel> _filterChallenges(List<ChallengeModel> challenges) {
    var filtered = challenges;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((challenge) {
        return challenge.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            challenge.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((c) => c.category == _selectedCategory).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((c) => c.status == _selectedStatus).toList();
    }

    // Apply challenge type filter
    if (_selectedChallengeType != null) {
      filtered = filtered.where((c) => c.challengeType == _selectedChallengeType).toList();
    }

    return filtered;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un challenge'),
        content: CustomTextField(
          label: 'Recherche',
          hint: 'Nom ou description...',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          CustomButton(
            text: 'Rechercher',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedStatus = null;
      _selectedChallengeType = null;
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _selectedStatus != null ||
      _selectedChallengeType != null;

  @override
  Widget build(BuildContext context) {
    final challengesState = ref.watch(challengesProvider);

    // Apply filters to challenges
    final filteredMyChallenges = _filterChallenges(challengesState.myChallenges);
    final filteredPublicChallenges = _filterChallenges(challengesState.publicChallenges);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter panel
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres',
                        style: AppTextStyles.titleMedium,
                      ),
                      if (_hasActiveFilters)
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Réinitialiser'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Category filter
                  const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.paddingXS),
                  Wrap(
                    spacing: 8,
                    children: StakeCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(_getCategoryName(category)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Status filter
                  const Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.paddingXS),
                  Wrap(
                    spacing: 8,
                    children: ChallengeStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      return FilterChip(
                        label: Text(_getStatusName(status)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.paddingS),

                  // Challenge type filter
                  const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.paddingXS),
                  Wrap(
                    spacing: 8,
                    children: ChallengeType.values.map((type) {
                      final isSelected = _selectedChallengeType == type;
                      return FilterChip(
                        label: Text(_getChallengeTypeName(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedChallengeType = selected ? type : null;
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Challenges list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(challengesProvider.notifier).loadMyChallenges();
                await ref.read(challengesProvider.notifier).loadPublicChallenges();
              },
              child: CustomScrollView(
          slivers: [
            // My Challenges Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Challenges',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Challenges auxquels vous participez',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // My Challenges List
            if (challengesState.isLoading && challengesState.myChallenges.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: LoadingIndicator(message: 'Chargement de vos challenges...'),
                ),
              )
            else if (filteredMyChallenges.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.people_outline,
                    title: _hasActiveFilters
                        ? 'Aucun résultat'
                        : 'Aucun challenge en cours',
                    subtitle: _hasActiveFilters
                        ? 'Essayez de modifier vos filtres'
                        : 'Rejoignez un challenge public ou créez le vôtre',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final challenge = filteredMyChallenges[index];
                      return _buildChallengeCard(context, challenge, isMyChallenge: true);
                    },
                    childCount: filteredMyChallenges.length,
                  ),
                ),
              ),

            // Public Challenges Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenges Publics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rejoignez un challenge existant',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Public Challenges List
            if (challengesState.isLoading && challengesState.publicChallenges.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: LoadingIndicator(message: 'Chargement des challenges publics...'),
                ),
              )
            else if (challengesState.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ErrorDisplay(
                    message: ErrorMapper.mapChallengeError(challengesState.error!),
                    onRetry: () {
                      ref.read(challengesProvider.notifier).loadPublicChallenges();
                    },
                  ),
                ),
              )
            else if (filteredPublicChallenges.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(
                    icon: Icons.public_off,
                    title: _hasActiveFilters
                        ? 'Aucun résultat'
                        : 'Aucun challenge public disponible',
                    subtitle: _hasActiveFilters
                        ? 'Essayez de modifier vos filtres'
                        : 'Soyez le premier à créer un challenge public !',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final challenge = filteredPublicChallenges[index];
                      return _buildChallengeCard(context, challenge, isMyChallenge: false);
                    },
                    childCount: filteredPublicChallenges.length,
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('${AppRoutes.home}/create-challenge');
        },
        icon: const Icon(Icons.add),
        label: const Text('Créer un Challenge'),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, ChallengeModel challenge, {required bool isMyChallenge}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.home}/challenges/${challenge.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _getCategoryIcon(challenge.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getChallengeTypeName(challenge.challengeType),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.fromChallengeStatus(challenge.status),
                ],
              ),
              const SizedBox(height: 16),

              // Participants and Prize
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${challenge.currentParticipants}/${challenge.maxParticipants} participants',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: challenge.currentParticipants / challenge.maxParticipants,
                          backgroundColor: Colors.grey[300],
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cagnotte',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(challenge.totalPrizePool),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dates and Entry Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateRange(challenge.startDate, challenge.endDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      CurrencyFormatter.format(challenge.entryFeeEUR),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // Join/Full indicator for public challenges
              if (!isMyChallenge && challenge.isFull)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Challenge complet',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
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
      radius: 20,
      child: Icon(icon, color: color, size: 20),
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

  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    if (now.isBefore(start)) {
      return 'Débute le ${start.day}/${start.month}';
    } else if (now.isAfter(end)) {
      return 'Terminé le ${end.day}/${end.month}';
    } else {
      final remaining = end.difference(now);
      if (remaining.inDays > 0) {
        return '${remaining.inDays}j restants';
      } else if (remaining.inHours > 0) {
        return '${remaining.inHours}h restantes';
      } else {
        return 'Se termine bientôt';
      }
    }
  }

  String _getCategoryName(StakeCategory category) {
    switch (category) {
      case StakeCategory.fitness:
        return 'Sport';
      case StakeCategory.education:
        return 'Éducation';
      case StakeCategory.productivity:
        return 'Productivité';
      case StakeCategory.finance:
        return 'Finance';
      case StakeCategory.personalDevelopment:
        return 'Développement personnel';
      case StakeCategory.family:
        return 'Famille';
      case StakeCategory.creativity:
        return 'Créativité';
      case StakeCategory.home:
        return 'Maison';
      case StakeCategory.digitalDetox:
        return 'Détox digitale';
    }
  }

  String _getStatusName(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.pending:
        return 'En attente';
      case ChallengeStatus.active:
        return 'Actif';
      case ChallengeStatus.completed:
        return 'Terminé';
      case ChallengeStatus.cancelled:
        return 'Annulé';
    }
  }
}
