import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

enum TripOptionAction {
  editBudget,
  deleteTrip,
}

/// 3-dot popup menu widget for trip options: Edit Budget & Delete Trip
class TripOptionsMenuWidget extends StatelessWidget {
  const TripOptionsMenuWidget({
    required this.onEditBudget,
    required this.onDeleteTrip,
    super.key,
  });

  final VoidCallback onEditBudget;
  final VoidCallback onDeleteTrip;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TripOptionAction>(
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.mutedText,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      color: AppColors.clay,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusTile),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      onSelected: (action) {
        switch (action) {
          case TripOptionAction.editBudget:
            onEditBudget();
            break;
          case TripOptionAction.deleteTrip:
            onDeleteTrip();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<TripOptionAction>(
          value: TripOptionAction.editBudget,
          height: 42,
          child: Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 17,
                color: AppColors.darkCharcoal,
              ),
              const SizedBox(width: 10),
              Text(
                'Edit Budget',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<TripOptionAction>(
          value: TripOptionAction.deleteTrip,
          height: 42,
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 17,
                color: AppColors.alertRed,
              ),
              const SizedBox(width: 10),
              Text(
                'Delete Trip',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.alertRed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
