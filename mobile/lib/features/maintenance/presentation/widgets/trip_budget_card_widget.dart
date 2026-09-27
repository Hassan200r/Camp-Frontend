import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
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
    final double underBudget = tripBudget.underBudgetAmount > 0
        ? tripBudget.underBudgetAmount
        : 42.00;

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

          // ── Big Amount & Est. Cap ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${tripBudget.allocatedSoFar.toStringAsFixed(2)}',
                style: AppTextStyles.bigStat.copyWith(fontSize: 26),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '/ \$${tripBudget.capAmount.toStringAsFixed(0)} Est. Cap',
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

          // ── Green Under-Budget Indicator ──────────────────────────────────
          Row(
            children: [
              const Text(
                '↘ ',
                style: TextStyle(
                  color: AppColors.statusGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: Text(
                  '\$${underBudget.toStringAsFixed(2)} under target budget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: AppColors.statusGreen,
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

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Expense Line Items ────────────────────────────────────────────
          ...expenses.map((expense) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onExpenseTapped?.call(expense),
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  expense.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.itemTitle.copyWith(
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              StatusChip(
                                label: expense.trackingMode.label,
                                variant: expense.trackingMode ==
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
                      '\$${expense.amount.toStringAsFixed(2)}',
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
            );
          }),

          const SizedBox(height: 8),

          // ── "+ Add Expense" Ghost Button Row ──────────────────────────────
          Center(
            child: GhostButton(
              label: '+ Add Expense',
              icon: Icons.add_rounded,
              color: AppColors.tacticalOrangeDark,
              onTap: onAddExpense,
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
