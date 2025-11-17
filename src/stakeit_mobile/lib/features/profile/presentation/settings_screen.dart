import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

// Settings State Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final bool notificationsEnabled;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String language;
  final bool darkMode;
  final String currency;
  final bool biometricAuth;
  final bool autoBackup;

  SettingsState({
    this.notificationsEnabled = true,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.language = 'fr',
    this.darkMode = false,
    this.currency = 'EUR',
    this.biometricAuth = false,
    this.autoBackup = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? language,
    bool? darkMode,
    String? currency,
    bool? biometricAuth,
    bool? autoBackup,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      currency: currency ?? this.currency,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      autoBackup: autoBackup ?? this.autoBackup,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      pushNotifications: prefs.getBool('pushNotifications') ?? true,
      emailNotifications: prefs.getBool('emailNotifications') ?? true,
      smsNotifications: prefs.getBool('smsNotifications') ?? false,
      soundEnabled: prefs.getBool('soundEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      language: prefs.getString('language') ?? 'fr',
      darkMode: prefs.getBool('darkMode') ?? false,
      currency: prefs.getString('currency') ?? 'EUR',
      biometricAuth: prefs.getBool('biometricAuth') ?? false,
      autoBackup: prefs.getBool('autoBackup') ?? true,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', state.notificationsEnabled);
    await prefs.setBool('pushNotifications', state.pushNotifications);
    await prefs.setBool('emailNotifications', state.emailNotifications);
    await prefs.setBool('smsNotifications', state.smsNotifications);
    await prefs.setBool('soundEnabled', state.soundEnabled);
    await prefs.setBool('vibrationEnabled', state.vibrationEnabled);
    await prefs.setString('language', state.language);
    await prefs.setBool('darkMode', state.darkMode);
    await prefs.setString('currency', state.currency);
    await prefs.setBool('biometricAuth', state.biometricAuth);
    await prefs.setBool('autoBackup', state.autoBackup);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
    _saveSettings();
  }

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
    _saveSettings();
  }

  void toggleEmailNotifications(bool value) {
    state = state.copyWith(emailNotifications: value);
    _saveSettings();
  }

  void toggleSmsNotifications(bool value) {
    state = state.copyWith(smsNotifications: value);
    _saveSettings();
  }

  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
    _saveSettings();
  }

  void toggleVibration(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    _saveSettings();
  }

  void setLanguage(String value) {
    state = state.copyWith(language: value);
    _saveSettings();
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
    _saveSettings();
  }

  void setCurrency(String value) {
    state = state.copyWith(currency: value);
    _saveSettings();
  }

  void toggleBiometricAuth(bool value) {
    state = state.copyWith(biometricAuth: value);
    _saveSettings();
  }

  void toggleAutoBackup(bool value) {
    state = state.copyWith(autoBackup: value);
    _saveSettings();
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            context,
            title: 'Activer les notifications',
            subtitle: 'Recevoir des notifications',
            value: settings.notificationsEnabled,
            onChanged: (value) => ref.read(settingsProvider.notifier).toggleNotifications(value),
            icon: Icons.notifications,
          ),
          if (settings.notificationsEnabled) ...[
            _buildSwitchTile(
              context,
              title: 'Notifications push',
              subtitle: 'Sur votre appareil',
              value: settings.pushNotifications,
              onChanged: (value) => ref.read(settingsProvider.notifier).togglePushNotifications(value),
              icon: Icons.phone_android,
            ),
            _buildSwitchTile(
              context,
              title: 'Notifications email',
              subtitle: 'Par email',
              value: settings.emailNotifications,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleEmailNotifications(value),
              icon: Icons.email,
            ),
            _buildSwitchTile(
              context,
              title: 'Notifications SMS',
              subtitle: 'Par message texte',
              value: settings.smsNotifications,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleSmsNotifications(value),
              icon: Icons.sms,
            ),
          ],
          const Divider(),

          // Sound & Vibration Section
          _buildSectionHeader('Son & Vibration'),
          _buildSwitchTile(
            context,
            title: 'Son',
            subtitle: 'Sons de notification',
            value: settings.soundEnabled,
            onChanged: (value) => ref.read(settingsProvider.notifier).toggleSound(value),
            icon: Icons.volume_up,
          ),
          _buildSwitchTile(
            context,
            title: 'Vibration',
            subtitle: 'Vibrer lors des notifications',
            value: settings.vibrationEnabled,
            onChanged: (value) => ref.read(settingsProvider.notifier).toggleVibration(value),
            icon: Icons.vibration,
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('Apparence'),
          _buildSwitchTile(
            context,
            title: 'Mode sombre',
            subtitle: 'Thème sombre pour l\'application',
            value: settings.darkMode,
            onChanged: (value) => ref.read(settingsProvider.notifier).toggleDarkMode(value),
            icon: Icons.dark_mode,
          ),
          _buildSelectTile(
            context,
            title: 'Langue',
            subtitle: _getLanguageName(settings.language),
            icon: Icons.language,
            onTap: () => _showLanguageSelector(context, ref, settings.language),
          ),
          const Divider(),

          // Regional Section
          _buildSectionHeader('Région & Devise'),
          _buildSelectTile(
            context,
            title: 'Devise',
            subtitle: settings.currency,
            icon: Icons.euro,
            onTap: () => _showCurrencySelector(context, ref, settings.currency),
          ),
          const Divider(),

          // Security Section
          _buildSectionHeader('Sécurité'),
          _buildSwitchTile(
            context,
            title: 'Authentification biométrique',
            subtitle: 'Face ID / Touch ID',
            value: settings.biometricAuth,
            onChanged: (value) => ref.read(settingsProvider.notifier).toggleBiometricAuth(value),
            icon: Icons.fingerprint,
          ),
          _buildSelectTile(
            context,
            title: 'Changer le mot de passe',
            subtitle: 'Modifier votre mot de passe',
            icon: Icons.lock,
            onTap: () => _changePassword(context),
          ),
          _buildSelectTile(
            context,
            title: 'Authentification à deux facteurs',
            subtitle: 'Sécurité renforcée',
            icon: Icons.security,
            onTap: () => _setup2FA(context),
          ),
          const Divider(),

          // Data & Privacy Section
          _buildSectionHeader('Données & Confidentialité'),
          _buildSwitchTile(
            context,
            title: 'Sauvegarde automatique',
            subtitle: 'Sauvegarder automatiquement vos données',
            value: settings.autoBackup,
            onChanged: (value) => ref.read(settingsProvider.notifier).toggleAutoBackup(value),
            icon: Icons.backup,
          ),
          _buildSelectTile(
            context,
            title: 'Télécharger mes données',
            subtitle: 'Exporter toutes vos données (GDPR)',
            icon: Icons.download,
            onTap: () => _downloadData(context),
          ),
          _buildSelectTile(
            context,
            title: 'Confidentialité',
            subtitle: 'Gérer la confidentialité de votre profil',
            icon: Icons.privacy_tip,
            onTap: () => _managePrivacy(context),
          ),
          const Divider(),

          // Account Section
          _buildSectionHeader('Compte'),
          _buildSelectTile(
            context,
            title: 'Méthodes de paiement',
            subtitle: 'Gérer vos cartes bancaires',
            icon: Icons.payment,
            onTap: () => _managePaymentMethods(context),
          ),
          _buildSelectTile(
            context,
            title: 'Supprimer mon compte',
            subtitle: 'Supprimer définitivement',
            icon: Icons.delete_forever,
            textColor: Colors.red,
            onTap: () => _deleteAccount(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSelectTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: textColor),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return 'Français';
    }
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir la langue',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, ref, '🇫🇷 Français', 'fr', current),
            _buildLanguageOption(context, ref, '🇬🇧 English', 'en', current),
            _buildLanguageOption(context, ref, '🇪🇸 Español', 'es', current),
            _buildLanguageOption(context, ref, '🇩🇪 Deutsch', 'de', current),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String label, String code, String current) {
    return ListTile(
      title: Text(label),
      trailing: code == current ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setLanguage(code);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Langue changée en $label')),
        );
      },
    );
  }

  void _showCurrencySelector(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir la devise',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 16),
            _buildCurrencyOption(context, ref, '€ Euro (EUR)', 'EUR', current),
            _buildCurrencyOption(context, ref, '\$ Dollar (USD)', 'USD', current),
            _buildCurrencyOption(context, ref, '£ Livre (GBP)', 'GBP', current),
            _buildCurrencyOption(context, ref, '₣ Franc (CHF)', 'CHF', current),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(BuildContext context, WidgetRef ref, String label, String code, String current) {
    return ListTile(
      title: Text(label),
      trailing: code == current ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        ref.read(settingsProvider.notifier).setCurrency(code);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Devise changée en $code')),
        );
      },
    );
  }

  void _changePassword(BuildContext context) {
    // TODO: Implement password change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en cours de développement')),
    );
  }

  void _setup2FA(BuildContext context) {
    // TODO: Implement 2FA setup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en cours de développement')),
    );
  }

  void _downloadData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Télécharger mes données'),
        content: const Text(
          'Vous allez recevoir un email contenant toutes vos données personnelles dans les 24 heures.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Request data export
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demande envoyée !')),
              );
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _managePrivacy(BuildContext context) {
    // TODO: Implement privacy management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en cours de développement')),
    );
  }

  void _managePaymentMethods(BuildContext context) {
    // TODO: Navigate to payment methods screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité en cours de développement')),
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer le compte'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible et vous perdrez toutes vos données.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete account
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
