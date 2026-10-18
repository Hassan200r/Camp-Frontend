import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../controllers/post_ride_report_controller.dart';
import '../../controllers/trip_budget_controller.dart';
import '../../domain/cost_per_km_calculator.dart';
import '../../domain/expense_model.dart';
import '../../domain/trip_budget_model.dart';
import '../../services/pdf_report_service.dart';
import '../screens/add_expense_screen.dart';
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

  void _showExpenseActionSheet(BuildContext context, Expense expense) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: AppColors.skeuRaised,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.clayDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                IconTile(
                  icon: expense.category.icon,
                  size: 36,
                  iconSize: 18,
                  isInset: true,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      Text(
                        formatPkr(expense.amount),
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tacticalOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppColors.darkCharcoal),
              title: Text(
                'Edit Expense',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              onTap: () async {
                Navigator.of(ctx).pop();
                final updated = await Navigator.of(context).push<Expense>(
                  MaterialPageRoute(
                    builder: (context) =>
                        AddExpenseScreen(initialExpense: expense),
                  ),
                );
                if (updated != null && context.mounted) {
                  TripBudgetController.instance.updateExpense(updated);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Updated ${updated.title}'),
                      backgroundColor: AppColors.darkCharcoal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.alertRed),
              title: Text(
                'Delete Expense',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.alertRed,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDeleteExpense(context, expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context, Expense expense) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Expense?',
          style: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.darkCharcoal,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${expense.title} (${formatPkr(expense.amount)})?',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(true);
              final removedIndex = expenses.indexOf(expense);
              TripBudgetController.instance.deleteExpense(expense.id);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${expense.title}'),
                  backgroundColor: AppColors.darkCharcoal,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.tacticalOrange,
                    onPressed: () {
                      TripBudgetController.instance.insertExpense(
                        removedIndex,
                        expense,
                      );
                    },
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                    expenseCount: expenses.length,
                    onConfirmDelete: onDeleteTrip,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Section Title & Date Range ───────────────────────────────────
          Text(
            'Trip Budget & Fuel Economics',
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tripBudget.dateRangeDisplay.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    tripBudget.dateRangeDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: AppColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

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
              value: isUnder ? tripBudget.spentRatio : 1.0,
              minHeight: 8,
              backgroundColor: AppColors.clayDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnder ? AppColors.tacticalOrange : AppColors.alertRed,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Cost per km & Category Breakdown ─────────────────────────────
          Builder(
            builder: (context) {
              final reports = PostRideReportController.instance.reports;
              final double? costPerKm = calculateCostPerKm(
                totalCost: tripBudget.allocatedSoFar,
                tripStartDate: tripBudget.parsedStartDate,
                tripEndDate: tripBudget.parsedEndDate,
                expenses: expenses,
                reports: reports,
              );
              final String costPerKmDisplay =
                  costPerKm != null ? '${formatPkr(costPerKm)}/km' : '-';

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
                child: Dismissible(
                  key: ValueKey(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed,
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusTile),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onDismissed: (_) {
                    final removedIndex = expenses.indexOf(expense);
                    TripBudgetController.instance.deleteExpense(expense.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted ${expense.title}'),
                        backgroundColor: AppColors.darkCharcoal,
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: AppColors.tacticalOrange,
                          onPressed: () {
                            TripBudgetController.instance.insertExpense(
                              removedIndex,
                              expense,
                            );
                          },
                        ),
                      ),
                    );
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (onExpenseTapped != null) {
                        onExpenseTapped!(expense);
                      } else {
                        _showExpenseActionSheet(context, expense);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.clay,
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusTile),
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
          DownloadReportCardWidget(
            label: 'Download Budget Report (PDF)',
            subtitle: 'Expense breakdown & trip summary',
            onTap: () {
              final activeBike = ActiveBikeController.instance.activeBike;
              final bikeName = activeBike != null
                  ? '${activeBike.make} ${activeBike.modelName}'
                  : null;
              final reports = PostRideReportController.instance.reports;
              final double? costPerKm = calculateCostPerKm(
                totalCost: tripBudget.allocatedSoFar,
                tripStartDate: tripBudget.parsedStartDate,
                tripEndDate: tripBudget.parsedEndDate,
                expenses: expenses,
                reports: reports,
              );
              final String? costDisplay =
                  costPerKm != null ? '${formatPkr(costPerKm)}/km' : null;

              PdfReportService.shareBudgetReport(
                context,
                BudgetReportData(
                  tripName: tripBudget.tripName,
                  capAmount: tripBudget.capAmount,
                  allocatedSoFar: tripBudget.allocatedSoFar,
                  dateRange: tripBudget.dateRangeDisplay.isNotEmpty
                      ? tripBudget.dateRangeDisplay
                      : null,
                  expenses: expenses,
                  bikeName: bikeName,
                  costPerKmDisplay: costDisplay,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
