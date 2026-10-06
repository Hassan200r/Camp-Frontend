import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../../controllers/navigation_controller.dart';

/// Top dark obsidian turn-by-turn banner displaying next maneuver icon,
/// distance countdown, instruction with highlighted street name, next maneuver subtitle,
/// and speaker mute toggle.
class NavTurnBanner extends StatelessWidget {
  const NavTurnBanner({
    required this.controller,
    super.key,
  });

  final NavigationController controller;

  @override
  Widget build(BuildContext context) {
    final step = controller.currentStep;
    final next = controller.nextStep;
    final units = SettingsController.instance.units;

    if (step == null) {
      return const SizedBox.shrink();
    }

    final distanceStr = step.formattedDistance(units).toUpperCase();
    final street = step.streetName;
    final nextInstruction = next != null
        ? 'Then ${next.instruction.toLowerCase()}'
        : 'Heading to ${controller.destination?.name ?? "destination"}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Maneuver Icon inside Orange Squircle
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.tacticalOrangeLight,
                  AppColors.tacticalOrange,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tacticalOrange.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                step.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Maneuver Text: Distance, Instruction with Orange Street, Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  distanceStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: step.instruction.contains(street) && street.isNotEmpty
                            ? step.instruction.substring(0, step.instruction.indexOf(street))
                            : step.instruction,
                      ),
                      if (step.instruction.contains(street) && street.isNotEmpty)
                        TextSpan(
                          text: street,
                          style: const TextStyle(
                            color: AppColors.tacticalOrange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nextInstruction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Speaker Button (Mute / Unmute Toggle)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF26262A),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: IconButton(
              icon: Icon(
                controller.isMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
                color: controller.isMuted
                    ? const Color(0xFF9CA3AF)
                    : Colors.white,
                size: 20,
              ),
              onPressed: controller.toggleMute,
              tooltip: controller.isMuted ? 'Unmute prompts' : 'Mute prompts',
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
