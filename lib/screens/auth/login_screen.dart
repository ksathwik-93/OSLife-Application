import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/action_button.dart';
import '../../widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty) {
        _emailError = 'Email or Username is required';
        isValid = false;
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
        isValid = false;
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
        isValid = false;
      }
    });
    return isValid;
  }

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    if (!_validateForm()) return;

    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  void _handleGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    setState(() {
      _isGoogleLoading = true;
    });

    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      setState(() {
        _isGoogleLoading = false;
      });
      if (success) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletMaxWidth;
    final authProvider = Provider.of<AuthProvider>(context);

    Widget formContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign in to resume your intelligence-first journey.',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email or Username',
          hintText: 'alex.morgan or name@example.com',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: '••••••••',
          errorText: _passwordError,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (val) => setState(() => _rememberMe = val ?? true),
                  activeColor: AppColors.primaryContainer,
                ),
                const Text(
                  'Remember Me',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.primary, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (authProvider.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ActionButton(
          label: 'Login',
          isLoading: authProvider.isLoading && !_isGoogleLoading,
          onPressed: (authProvider.isLoading || _isGoogleLoading) ? null : _handleLogin,
        ),
        const SizedBox(height: 28),
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.outlineVariant)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
              ),
            ),
            Expanded(child: Divider(color: AppColors.outlineVariant)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'Google',
                icon: Icons.g_mobiledata,
                variant: ActionButtonVariant.outline,
                isLoading: _isGoogleLoading,
                onPressed: (authProvider.isLoading || _isGoogleLoading) ? null : _handleGoogleLogin,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                label: 'Apple',
                icon: Icons.apple,
                variant: ActionButtonVariant.outline,
                onPressed: (authProvider.isLoading || _isGoogleLoading) ? null : _handleLogin,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ", style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
            GestureDetector(
              onTap: () {
                authProvider.clearError();
                context.push('/register');
              },
              child: const Text(
                'Register Now',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 32,
              child: Row(
                children: [
                  if (isDesktop)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.surfaceContainerLowest, AppColors.surfaceContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OSLife',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Your personal neural architect for high-performance living.',
                                  style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 60),
                            Column(
                              children: [
                                _buildFeatureItem(
                                  Icons.auto_awesome,
                                  'Contextual AI',
                                  'Real-time situational intelligence.',
                                ),
                                const SizedBox(height: 24),
                                _buildFeatureItem(
                                  Icons.security,
                                  'Zero Trust Privacy',
                                  'Your data, fully encrypted, always.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 48 : 24),
                      child: formContent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppColors.onPrimaryContainer),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
