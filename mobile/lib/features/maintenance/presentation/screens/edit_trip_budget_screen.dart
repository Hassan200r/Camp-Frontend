import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/trip_budget_model.dart';

/// Screen for adjusting trip budget parameters and viewing live allocation impact
class EditTripBudgetScreen extends StatefulWidget {
  const EditTripBudgetScreen({
    super.key,
    this.initialBudget = TripBudget.defaultSampleBudget,
  });

  final TripBudget initialBudget;

  @override
  State<EditTripBudgetScreen> createState() => _EditTripBudgetScreenState();
}

class _EditTripBudgetScreenState extends State<EditTripBudgetScreen> {
  late final TextEditingController _tripNameCtrl;
  late final TextEditingController _budgetCapCtrl;

  late String _startDate;
  late String _endDate;
  late double _allocatedSoFar;

  @override
  void initState() {
    super.initState();
    _tripNameCtrl = TextEditingController(text: widget.initialBudget.tripName);
    _budgetCapCtrl = TextEditingController(
      text: widget.initialBudget.capAmount.toStringAsFixed(2),
    );
    _startDate = widget.initialBudget.startDate ?? 'Oct 12, 2026';
    _endDate = widget.initialBudget.endDate ?? 'Oct 18, 2026';
    _allocatedSoFar = widget.initialBudget.allocatedSoFar;

    _budgetCapCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tripNameCtrl.dispose();
    _budgetCapCtrl.dispose();
    super.dispose();
  }

  double get _currentCap {
    final parsed = double.tryParse(_budgetCapCtrl.text.trim());
    return (parsed != null && parsed > 0) ? parsed : widget.initialBudget.capAmount;
  }

  void _stepBudget(double delta) {
    final current = _currentCap;
    final next = (current + delta).clamp(10.0, 50000.0);
    _budgetCapCtrl.text = next.toStringAsFixed(2);
  }

  void _saveBudget() {
    final updated = widget.initialBudget.copyWith(
      tripName: _tripNameCtrl.text.trim().isNotEmpty
          ? _tripNameCtrl.text.trim()
          : widget.initialBudget.tripName,
      capAmount: _currentCap,
      startDate: _startDate,
      endDate: _endDate,
      allocatedSoFar: _allocatedSoFar,
    );
    Navigator.of(context).pop(updated);
  }

  Widget _buildBudgetCapField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'TOTAL BUDGET CAP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.overline,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Target Ceiling',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.overline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.clayDark,
            borderRadius: BorderRadius.circular(AppColors.radiusTile),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: AppColors.skeuRecessed,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$',
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _budgetCapCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                  cursorColor: AppColors.tacticalOrange,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Up / Down Stepper Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _stepBudget(25.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.clay,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 16,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _stepBudget(-25.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.clay,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cap = _currentCap;
    final double underBudget = (cap - _allocatedSoFar);
    final double ratio = cap > 0 ? (_allocatedSoFar / cap).clamp(0.0, 1.0) : 0.0;
    final double remainingPct =
        cap > 0 ? ((cap - _allocatedSoFar) / cap * 100).clamp(0.0, 100.0) : 0.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.clay,
        appBar: CampAppBar(
          leading: CampAppBarLeading.back,
          actionText: 'Save',
          onActionPressed: _saveBudget,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppColors.screenPadding,
              12,
              AppColors.screenPadding,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Trip Name ─────────────────────────────────────────
                      LabeledTextField(
                        label: 'TRIP NAME',
                        controller: _tripNameCtrl,
                      ),

                      const SizedBox(height: 18),

                      // ── Total Budget Cap (Oversized) ───────────────────────
                      _buildBudgetCapField(),

                      const SizedBox(height: 18),

                      // ── Trip Dates (Optional) ─────────────────────────────
                      Text('TRIP DATES (OPTIONAL)', style: AppTextStyles.overline),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Start Date
                          Expanded(
                            child: InsetTile(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  const IconTile(
                                    icon: Icons.calendar_today_rounded,
                                    size: 28,
                                    iconSize: 14,
                                    isInset: false,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'START',
                                          style: AppTextStyles.overline.copyWith(
                                            fontSize: 8.5,
                                          ),
                                        ),
                                        Text(
                                          _startDate,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.manrope(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkCharcoal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // End Date
                          Expanded(
                            child: InsetTile(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  const IconTile(
                                    icon: Icons.event_available_rounded,
                                    size: 28,
                                    iconSize: 14,
                                    isInset: false,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'END',
                                          style: AppTextStyles.overline.copyWith(
                                            fontSize: 8.5,
                                          ),
                                        ),
                                        Text(
                                          _endDate,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.manrope(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkCharcoal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppColors.cardGap),

                // ── Live Allocation Impact Card ─────────────────────────────
                CampCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'LIVE ALLOCATION IMPACT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.overline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const StatusChip(
                            label: 'Healthy Margin',
                            variant: StatusChipVariant.success,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Allocated so far: ',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '\$${_allocatedSoFar.toStringAsFixed(2)}',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          Text(
                            ' of \$${cap.toStringAsFixed(2)}',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusPill),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: AppColors.clayDark,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.tacticalOrange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Under budget by \$${underBudget > 0 ? underBudget.toStringAsFixed(2) : '0.00'}',
                            style: GoogleFonts.manrope(
                              color: AppColors.statusGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${remainingPct.toStringAsFixed(1)}% remaining',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Save Button ─────────────────────────────────────────────
                PrimaryButton(
                  label: 'Save Budget',
                  icon: Icons.arrow_forward_rounded,
                  isFullWidth: true,
                  onTap: _saveBudget,
                ),

                const SizedBox(height: 10),

                // ── Cancel Button ───────────────────────────────────────────
                Center(
                  child: GhostButton(
                    label: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
