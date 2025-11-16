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
import '../data/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await ref.read(authProvider.notifier).login(request);

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: AppSizes.iconXXL,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                // Title
                Text(
                  'Bienvenue !',
                  style: AppTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Connectez-vous pour continuer',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'votre@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                // Password Field
                CustomTextField(
                  label: 'Mot de passe',
                  hint: '••••••••',
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
                  validator: Validators.validateRequired,
                ),
                const SizedBox(height: 24),
                // Login Button
                CustomButton(
                  text: 'Se connecter',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  type: ButtonType.primary,
                  size: ButtonSize.large,
                  isFullWidth: true,
                ),
                const SizedBox(height: 16),
                // Forgot Password
                CustomButton(
                  text: 'Mot de passe oublié ?',
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  type: ButtonType.text,
                  isFullWidth: true,
                ),
                const SizedBox(height: 32),
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                      child: Text(
                        'OU',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXXL),
                // Register Button
                CustomButton(
                  text: 'Créer un compte',
                  onPressed: () {
                    context.go(AppRoutes.register);
                  },
                  type: ButtonType.outlined,
                  size: ButtonSize.large,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
