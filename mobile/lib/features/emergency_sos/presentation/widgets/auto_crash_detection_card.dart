import 'package:flutter/material.dart';
import 'emergency_dispatch_card.dart';

/// Legacy card alias redirected to [EmergencyDispatchCard].
class AutoCrashDetectionCard extends StatelessWidget {
  const AutoCrashDetectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmergencyDispatchCard();
  }
}
