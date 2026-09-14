import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/action_button.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Neural Graph'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Banner Avatar Card
            GlassCard(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person, size: 48, color: AppColors.onPrimaryContainer),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Alex Morgan',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'alex.morgan@lifeos.ai',
                    style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      user?.tier.toUpperCase() ?? 'PRO MEMBER',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // User Stat Highlights
            Row(
              children: [
                _buildStatBox('14 Days', 'Streak', Icons.local_fire_department, AppColors.tertiary),
                const SizedBox(width: 12),
                _buildStatBox('342', 'Completed', Icons.check_circle_outline, AppColors.primary),
                const SizedBox(width: 12),
                _buildStatBox('128h', 'Focus Time', Icons.schedule, AppColors.secondary),
              ],
            ),
            const SizedBox(height: 24),
            // Settings links
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune, color: AppColors.primary),
                    title: const Text('AI Autonomy Level', style: TextStyle(color: AppColors.onSurface)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    onTap: () => context.push('/settings'),
                  ),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.security, color: AppColors.secondary),
                    title: const Text('Zero Trust Encryption', style: TextStyle(color: AppColors.onSurface)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    onTap: () => context.push('/settings'),
                  ),
                  const Divider(height: 1, color: AppColors.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: AppColors.tertiary),
                    title: const Text('Support & Feedback', style: TextStyle(color: AppColors.onSurface)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ActionButton(
              label: 'Sign Out',
              variant: ActionButtonVariant.outline,
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
