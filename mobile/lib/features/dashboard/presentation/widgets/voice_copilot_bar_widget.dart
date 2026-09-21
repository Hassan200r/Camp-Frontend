import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Voice Copilot Bar — recessed inset surface with glowing orange AI button
class VoiceCopilotBarWidget extends StatefulWidget {
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onVoicePressed;
  final VoidCallback? onAiPressed;

  const VoiceCopilotBarWidget({
    super.key,
    this.onSubmitted,
    this.onVoicePressed,
    this.onAiPressed,
  });

  @override
  State<VoiceCopilotBarWidget> createState() => _VoiceCopilotBarWidgetState();
}

class _VoiceCopilotBarWidgetState extends State<VoiceCopilotBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Raised outer ring — matches clay background for depth
    return SkeuomorphicContainer(
      borderRadius: 32,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          // ── Left: Raised mic button ────────────────────────────────────
          GestureDetector(
            onTap: widget.onVoicePressed,
            child: SkeuomorphicContainer(
              borderRadius: 100,
              shadows: AppColors.skeuRaisedSmall,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Center(
                  child: Icon(
                    Icons.mic_none_rounded,
                    color: AppColors.terracotta,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Middle: Recessed input field ────────────────────────────────
          Expanded(
            child: SkeuomorphicInsetContainer(
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: TextField(
                controller: _controller,
                onSubmitted: widget.onSubmitted,
                style: const TextStyle(
                  color: AppColors.darkCharcoal,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: '"Hey CAMP, how\'s tire pressure on trail..."',
                  hintStyle: TextStyle(
                    color: Color(0xFF7A7570),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Right: Glowing extruded orange AI button ────────────────────
          SkeuomorphicOrangeIconButton(
            icon: Icons.smart_toy_rounded,
            size: 44,
            onTap: widget.onAiPressed,
          ),
        ],
      ),
    );
  }
}
