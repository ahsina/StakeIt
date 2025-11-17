import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_constants.dart';

// App Integrations - Connect third-party apps for automatic proof verification
class AppIntegrationsScreen extends ConsumerWidget {
  const AppIntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final integrations = [
      _Integration(
        id: 'strava',
        name: 'Strava',
        icon: '🏃',
        description: 'Activités running, cycling et fitness',
        category: 'Fitness',
        connected: true,
        lastSync: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _Integration(
        id: 'apple_health',
        name: 'Apple Health',
        icon: '❤️',
        description: 'Données de santé et activité',
        category: 'Santé',
        connected: false,
      ),
      _Integration(
        id: 'google_fit',
        name: 'Google Fit',
        icon: '🏋️',
        description: 'Suivi d\'activité physique',
        category: 'Fitness',
        connected: false,
      ),
      _Integration(
        id: 'duolingo',
        name: 'Duolingo',
        icon: '🦉',
        description: 'Apprentissage des langues',
        category: 'Éducation',
        connected: false,
      ),
      _Integration(
        id: 'todoist',
        name: 'Todoist',
        icon: '✓',
        description: 'Gestion des tâches',
        category: 'Productivité',
        connected: false,
      ),
      _Integration(
        id: 'notion',
        name: 'Notion',
        icon: '📝',
        description: 'Notes et organisation',
        category: 'Productivité',
        connected: false,
      ),
      _Integration(
        id: 'fitbit',
        name: 'Fitbit',
        icon: '⌚',
        description: 'Tracker d\'activité',
        category: 'Fitness',
        connected: false,
      ),
      _Integration(
        id: 'garmin',
        name: 'Garmin',
        icon: '📡',
        description: 'Montre et GPS',
        category: 'Fitness',
        connected: false,
      ),
    ];

    final connected = integrations.where((i) => i.connected).toList();
    final available = integrations.where((i) => !i.connected).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intégrations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Connectez vos apps pour valider automatiquement vos preuves',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Connected Apps
          if (connected.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Connectées (${connected.length})',
                  style: AppTextStyles.headingMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...connected.map((integration) => _buildIntegrationCard(context, integration)),
            const SizedBox(height: 24),
          ],

          // Available Apps
          Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Disponibles (${available.length})',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...available.map((integration) => _buildIntegrationCard(context, integration)),
        ],
      ),
    );
  }

  Widget _buildIntegrationCard(BuildContext context, _Integration integration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: integration.connected ? Colors.green[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              integration.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(integration.name),
            if (integration.connected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(integration.description),
            if (integration.connected && integration.lastSync != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dernière sync: ${_formatDate(integration.lastSync!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
        trailing: integration.connected
            ? IconButton(
                icon: const Icon(Icons.settings, color: Colors.grey),
                onPressed: () => _showIntegrationSettings(context, integration),
              )
            : ElevatedButton(
                onPressed: () => _connectIntegration(context, integration),
                child: const Text('Connecter'),
              ),
      ),
    );
  }

  void _connectIntegration(BuildContext context, _Integration integration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(integration.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Text('Connecter ${integration.name}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Autorisations nécessaires :'),
            const SizedBox(height: 12),
            _buildPermissionItem('Lecture des activités'),
            _buildPermissionItem('Statistiques de progression'),
            if (integration.category == 'Fitness')
              _buildPermissionItem('Données de localisation'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vos données restent privées et sécurisées',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${integration.name} connecté avec succès !'),
                ),
              );
            },
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _showIntegrationSettings(BuildContext context, _Integration integration) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(integration.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(integration.name, style: AppTextStyles.headingMedium),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Synchroniser maintenant'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synchronisation en cours...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique de sync'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_off, color: Colors.red),
              title: const Text('Déconnecter', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${integration.name} déconnecté')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }
}

class _Integration {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String category;
  final bool connected;
  final DateTime? lastSync;

  _Integration({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.category,
    this.connected = false,
    this.lastSync,
  });
}
