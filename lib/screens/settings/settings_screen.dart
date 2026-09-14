import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _zeroTrustEnabled = true;
  bool _proactiveSuggestions = true;
  bool _pushNotifications = true;
  double _aiAutonomyLevel = 0.8;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('AI & AUTONOMY'),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Proactive AI Suggestions', style: TextStyle(color: AppColors.onSurface)),
                  subtitle: const Text('Allow AI to analyze calendar gaps & suggest study sessions.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  value: _proactiveSuggestions,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _proactiveSuggestions = val),
                ),
                const Divider(height: 1, color: AppColors.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('AI Intervention Threshold', style: TextStyle(fontSize: 14, color: AppColors.onSurface)),
                          Text('${(_aiAutonomyLevel * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      Slider(
                        value: _aiAutonomyLevel,
                        min: 0.1,
                        max: 1.0,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.surfaceContainerHighest,
                        onChanged: (val) => setState(() => _aiAutonomyLevel = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('PRIVACY & ENCRYPTION'),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Zero Trust Encryption', style: TextStyle(color: AppColors.onSurface)),
                  subtitle: const Text('End-to-end client-side encryption for all notes and financial logs.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  value: _zeroTrustEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _zeroTrustEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('PREFERENCES & SYSTEM'),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications', style: TextStyle(color: AppColors.onSurface)),
                  value: _pushNotifications,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1, color: AppColors.outlineVariant),
                SwitchListTile(
                  title: const Text('Dark Mode Theme', style: TextStyle(color: AppColors.onSurface)),
                  subtitle: const Text('Charcoal & Electric Purple (Default)', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  value: themeProvider.isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'OSLife v1.0.0 (Build 1024)\nDesigned with Electric Purple & Dark Charcoal Theme',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
