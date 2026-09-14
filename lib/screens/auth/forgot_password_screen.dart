import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/action_button.dart';
import '../../widgets/glass_card.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitted = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailError = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email address is required';
      });
      return false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return false;
    }
    return true;
  }

  void _handleReset() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    if (!_validateForm()) return;

    final success = await authProvider.resetPassword(_emailController.text.trim());
    if (success && mounted) {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              borderRadius: 32,
              child: _isSubmitted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
                        const SizedBox(height: 20),
                        const Text(
                          'Check Your Inbox',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We have sent password reset instructions to ${_emailController.text.trim()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        ActionButton(
                          label: 'Back to Login',
                          onPressed: () {
                            authProvider.clearError();
                            context.go('/login');
                          },
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Forgot Password',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your account email to receive a password reset link.',
                          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 28),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'name@example.com',
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleReset(),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant),
                          onChanged: (_) {
                            if (_emailError != null) setState(() => _emailError = null);
                          },
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
                                    style: const TextStyle(
                                        color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ActionButton(
                          label: 'Send Reset Link',
                          isLoading: authProvider.isLoading,
                          onPressed: _handleReset,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              authProvider.clearError();
                              context.pop();
                            },
                            child: const Text('Back to Sign In', style: TextStyle(color: AppColors.primary)),
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
}
