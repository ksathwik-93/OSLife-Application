import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/metric_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Focus Hours',
                    value: '128h',
                    subtitle: '+14% vs last month',
                    icon: Icons.timer_outlined,
                    accentColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Tasks Done',
                    value: '342',
                    subtitle: '94% completion rate',
                    icon: Icons.check_circle_outline,
                    accentColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Cognitive Performance Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Focus Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final heights = [0.4, 0.6, 0.85, 0.7, 0.9, 0.5, 0.3];
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 24,
                              height: 100 * heights[index],
                              decoration: BoxDecoration(
                                color: index == 4 ? AppColors.primary : AppColors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(days[index], style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
