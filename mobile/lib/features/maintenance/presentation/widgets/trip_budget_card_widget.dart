import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../domain/expense_model.dart';
import '../../domain/trip_budget_model.dart';
import 'delete_trip_dialog_widget.dart';
import 'download_report_card_widget.dart';
import 'trip_options_menu_widget.dart';

/// Trip Budget & Fuel Economics card widget
class TripBudgetCardWidget extends StatelessWidget {
  const TripBudgetCardWidget({
    required this.tripBudget,
    required this.expenses,
    required this.onEditTrip,
    required this.onDeleteTrip,
    required this.onAddExpense,
    super.key,
    this.onExpenseTapped,
  });

  final TripBudget tripBudget;
  final List<Expense> expenses;
  final VoidCallback onEditTrip;
  final VoidCallback onDeleteTrip;
  final VoidCallback onAddExpense;
  final ValueChanged<Expense>? onExpenseTapped;

  @override
  Widget build(BuildContext context) {
    final double underBudget = tripBudget.underBudgetAmount;
    final bool isUnder = underBudget >= 0;

    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Trip Chip & 3-dot Menu ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Trip name chip with edit pencil
              Flexible(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onEditTrip,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.clayDark,
                      borderRadius: BorderRadius.circular(AppColors.radiusPill),
                      boxShadow: AppColors.skeuRaisedSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '🏔 ${tripBudget.tripName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: AppColors.darkCharcoal,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors.mutedText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 3-dot popup menu
              TripOptionsMenuWidget(
                onEditBudget: onEditTrip,
                onDeleteTrip: () {
                  DeleteTripDialogWidget.show(
                    context,
                    tripName: tripBudget.tripName,
                    onConfirmDelete: onDeleteTrip,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Section Title ────────────────────────────────────────────────
          Text(
            'Trip Budget & Fuel Economics',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // ── Big Amount & Budget Cap ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatPkr(tripBudget.allocatedSoFar),
                style: AppTextStyles.bigStat.copyWith(fontSize: 26),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '/ ${formatPkr(tripBudget.capAmount)} Budget Cap',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onEditTrip,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ── Under/Over-Budget Indicator ──────────────────────────────────
          Row(
            children: [
              Text(
                isUnder ? '↘ ' : '↗ ',
                style: TextStyle(
                  color: isUnder ? AppColors.statusGreen : AppColors.alertRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: Text(
                  isUnder
                      ? '${formatPkr(underBudget)} under target budget'
                      : '${formatPkr(-underBudget)} over target budget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: isUnder ? AppColors.statusGreen : AppColors.alertRed,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Allocation Progress Bar ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Allocation Spent', style: AppTextStyles.overline),
              Text(
                '${tripBudget.spentPercentInt}% used',
                style: GoogleFonts.manrope(
                  color: AppColors.darkCharcoal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radiusPill),
            child: LinearProgressIndicator(
              value: tripBudget.spentRatio,
              minHeight: 8,
              backgroundColor: AppColors.clayDark,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.tacticalOrange,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Cost per km & Category Breakdown ─────────────────────────────
          Builder(
            builder: (context) {
              final activeBike = ActiveBikeController.instance.activeBike;
              final num? distanceKm = (activeBike != null && activeBike.odometerKm > 0)
                  ? activeBike.odometerKm
                  : null;
              final num totalCost = tripBudget.allocatedSoFar;
              final String costPerKmDisplay =
                  (distanceKm != null && distanceKm > 0 && totalCost > 0)
                      ? '${formatPkr(totalCost / distanceKm)}/km'
                      : '-';

              final categoryTotals = <ExpenseCategory, double>{};
              for (final exp in expenses) {
                categoryTotals[exp.category] =
                    (categoryTotals[exp.category] ?? 0.0) + exp.amount;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cost per km',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        costPerKmDisplay,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  if (categoryTotals.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: categoryTotals.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.clayDark,
                            borderRadius:
                                BorderRadius.circular(AppColors.radiusPill),
                          ),
                          child: Text(
                            '${entry.key.displayName}: ${formatPkr(entry.value)}',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Expense Line Items ────────────────────────────────────────────
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 32,
                      color: AppColors.mutedLight,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add your first expense',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...expenses.map((expense) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onExpenseTapped?.call(expense),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.clay,
                    borderRadius: BorderRadius.circular(AppColors.radiusTile),
                    boxShadow: AppColors.skeuRaisedSmall,
                  ),
                  child: Row(
                    children: [
                      // Category icon tile
                      IconTile(
                        icon: expense.category.icon,
                        size: 38,
                        iconSize: 18,
                        isInset: true,
                      ),
                      const SizedBox(width: 12),

                      // Title, Mode chip & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 2,
                              children: [
                                Text(
                                  expense.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.itemTitle.copyWith(
                                    fontSize: 13.5,
                                  ),
                                ),
                                StatusChip(
                                  label: expense.trackingMode.label,
                                  variant:
                                      expense.trackingMode ==
                                          ExpenseTrackingMode.manualEntry
                                      ? StatusChipVariant.gold
                                      : StatusChipVariant.neutral,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                ),
                              ],
                            ),
                            if (expense.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                expense.subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Amount
                      Text(
                        formatPkr(expense.amount),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.mutedLight,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 0),

          // ── "Add Expense" tile ────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAddExpense,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.tacticalOrangeDark,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add Expense',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.tacticalOrangeDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.mutedText,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Download Budget Report ────────────────────────────────────────
          const DownloadReportCardWidget(
            label: 'Download Budget Report (PDF)',
            subtitle: 'Expense breakdown & trip summary',
          ),
        ],
      ),
    );
  }
}
