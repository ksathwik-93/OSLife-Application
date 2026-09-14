import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PromptItem {
  final String text;
  final IconData icon;

  const PromptItem({required this.text, required this.icon});
}

class PromptChips extends StatelessWidget {
  final Function(String) onPromptSelected;

  const PromptChips({
    super.key,
    required this.onPromptSelected,
  });

  static const List<PromptItem> defaultPrompts = [
    PromptItem(
      text: 'What should I do today?',
      icon: Icons.today_outlined,
    ),
    PromptItem(
      text: 'Show my pending tasks',
      icon: Icons.checklist_outlined,
    ),
    PromptItem(
      text: 'How much did I spend this month?',
      icon: Icons.account_balance_wallet_outlined,
    ),
    PromptItem(
      text: 'What are my current goals?',
      icon: Icons.track_changes_outlined,
    ),
    PromptItem(
      text: 'Help me plan my study time',
      icon: Icons.school_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: defaultPrompts.map((prompt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _PromptChipWidget(
                item: prompt,
                onTap: () => onPromptSelected(prompt.text),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PromptChipWidget extends StatefulWidget {
  final PromptItem item;
  final VoidCallback onTap;

  const _PromptChipWidget({
    required this.item,
    required this.onTap,
  });

  @override
  State<_PromptChipWidget> createState() => _PromptChipWidgetState();
}

class _PromptChipWidgetState extends State<_PromptChipWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.primaryContainer.withAlpha(50)
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary
                  : AppColors.outlineVariant.withAlpha(100),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.item.icon,
                size: 15,
                color: _isHovered ? AppColors.primary : AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.item.text,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: _isHovered ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
