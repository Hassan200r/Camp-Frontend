import 'package:flutter/material.dart';
import 'auto_crash_detection_card.dart';

/// Legacy alias / wrapper for [AutoCrashDetectionCard] to maintain backward compatibility.
class AutomatedRescueProtocolsCard extends StatelessWidget {
  const AutomatedRescueProtocolsCard({
    super.key,
    this.onManageIcePressed,
  });

  final VoidCallback? onManageIcePressed;

  @override
  Widget build(BuildContext context) {
    return const AutoCrashDetectionCard();
  }
}
