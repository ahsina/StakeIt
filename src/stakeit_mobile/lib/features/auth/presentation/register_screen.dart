import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/utils/error_mapper.dart';
import '../../../shared/utils/date_formatter.dart';
import '../data/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      helpText: 'Date de naissance',
    );

    if (date != null) {
      setState(() {
        _dateOfBirth = date;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner votre date de naissance'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = RegisterRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
      );

      await ref.read(authProvider.notifier).register(request);

      if (!mounted) return;

      // Navigate to home on success
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMapper.mapAuthError(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally{
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Créer un compte',
                  style: AppTextStyles.displayLarge,
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Rejoignez StakeIt aujourd\'hui',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                // First Name
                CustomTextField(
                  label: 'Prénom',
                  controller: _firstNameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Le prénom'),
                ),
                const SizedBox(height: AppSizes.paddingM),
                // Last Name
                CustomTextField(
                  label: 'Nom',
                  controller: _lastNameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) => Validators.validateRequired(value, fieldName: 'Le nom'),
                ),
                const SizedBox(height: AppSizes.paddingM),
                // Email
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppSizes.paddingM),
                // Date of Birth
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? 'Sélectionnez votre date de naissance'
                          : DateFormatter.formatLongDate(_dateOfBirth!),
                      style: _dateOfBirth == null
                          ? TextStyle(color: AppColors.textSecondary)
                          : AppTextStyles.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                // Password
                CustomTextField(
                  label: 'Mot de passe',
                  hint: 'Au moins 8 caractères',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: Validators.validateStrongPassword,
                ),
                const SizedBox(height: AppSizes.paddingM),
                // Confirm Password
                CustomTextField(
                  label: 'Confirmer le mot de passe',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) => Validators.validatePasswordConfirmation(value, _passwordController.text),
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                // Register Button
                CustomButton(
                  text: 'S\'inscrire',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSizes.paddingM),
                // Terms and Privacy
                Text(
                  'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
