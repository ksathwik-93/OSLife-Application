import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;

  const ChatInputBar({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (hasTextNow != _hasText) {
        setState(() {
          _hasText = hasTextNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.isEnabled) return;
    widget.onSendMessage(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withAlpha(60),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _hasText
                  ? AppColors.primary.withAlpha(150)
                  : AppColors.outlineVariant.withAlpha(80),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Voice mic icon (with helpful tooltip)
              IconButton(
                icon: const Icon(Icons.mic_none_outlined, size: 20),
                color: AppColors.onSurfaceVariant,
                tooltip: 'Voice dictation (Coming soon)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice dictation is coming soon. Please type your message!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              // Text Field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.isEnabled,
                  textInputAction: TextInputAction.send,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ask OSLife Assistant...',
                    hintStyle: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              // Clear or Send button
              if (_hasText)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: AppColors.onSurfaceVariant,
                  tooltip: 'Clear input',
                  onPressed: () => _controller.clear(),
                ),
              // Send Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _hasText && widget.isEnabled
                      ? const LinearGradient(
                          colors: [AppColors.primaryContainer, AppColors.inversePrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _hasText && widget.isEnabled
                      ? null
                      : AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  boxShadow: _hasText && widget.isEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.primaryContainer.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    size: 18,
                    color: _hasText && widget.isEnabled
                        ? AppColors.onPrimaryContainer
                        : AppColors.outline,
                  ),
                  onPressed: _hasText && widget.isEnabled ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
