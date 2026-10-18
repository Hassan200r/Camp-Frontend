import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../maintenance/controllers/trip_budget_controller.dart';
import '../../../maintenance/domain/expense_model.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../../controllers/active_bike_controller.dart';
import '../../domain/bike_model.dart';
import '../../domain/fuel_estimator.dart';
import '../../services/fuel_tracker_service.dart';

/// Modal bottom sheet allowing riders to set their current fuel in liters
/// or log a refill with full-to-full fuel average learning.
class UpdateFuelSheet extends StatefulWidget {
  const UpdateFuelSheet({required this.bike, super.key});

  final Bike bike;

  static Future<void> show(BuildContext context, Bike bike) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => UpdateFuelSheet(bike: bike),
    );
  }

  @override
  State<UpdateFuelSheet> createState() => _UpdateFuelSheetState();
}

class _UpdateFuelSheetState extends State<UpdateFuelSheet> {
  late double _tankCapacity;
  late double _liters;
  double _addedLiters = 5.0;
  bool _showRefillSection = false;

  @override
  void initState() {
    super.initState();
    _tankCapacity = widget.bike.fuelTankCapacityLiters ?? 20.0;
    if (_tankCapacity <= 0) _tankCapacity = 20.0;

    final initial = widget.bike.fuelRemainingLiters ??
        (widget.bike.fuelLevelPercent != null
            ? (widget.bike.fuelLevelPercent! * _tankCapacity / 100.0)
            : _tankCapacity * 0.5);

    _liters = initial.clamp(0.0, _tankCapacity);
    _addedLiters = (_tankCapacity * 0.5).clamp(1.0, _tankCapacity);
  }

  void _saveCurrentFuel() {
    final updated = widget.bike.copyWith(
      fuelRemainingLiters: double.parse(_liters.toStringAsFixed(1)),
      lastFuelUpdate: DateTime.now(),
    );
    ActiveBikeController.instance.updateBike(updated);

    final pct = FuelEstimator.percent(_liters, _tankCapacity);
    if (pct != null && pct >= 15.0) {
      FuelTrackerService.instance.resetLowFuelFlag();
    }

    Navigator.of(context).pop();
  }

  Future<void> _handleFilledToFull() async {
    final prevFullOdo = widget.bike.lastFullRefillOdometer;
    final currentOdo = widget.bike.preciseOdometerKm ??
        widget.bike.odometerKm.toDouble();
    final litersAdded = (_tankCapacity - (widget.bike.fuelRemainingLiters ?? 0.0))
        .clamp(0.0, _tankCapacity);

    // Full-to-full learning check
    if (prevFullOdo != null && litersAdded > 0.5) {
      final distanceTraveled = currentOdo - prevFullOdo;
      if (distanceTraveled > 10.0) {
        final computedAvg = FuelEstimator.computeFullToFullEfficiency(
          distanceTraveled,
          litersAdded,
        );

        if (computedAvg != null && computedAvg > 0) {
          final roundedAvg = double.parse(computedAvg.toStringAsFixed(1));
          final shouldUpdate = await _showLearningDialog(
            distanceTraveled: distanceTraveled,
            litersAdded: litersAdded,
            computedAvg: roundedAvg,
          );

          if (shouldUpdate == true) {
            final updated = widget.bike.copyWith(
              fuelRemainingLiters: _tankCapacity,
              fuelAverageKmPerLiter: roundedAvg,
              lastFullRefillOdometer: currentOdo,
              lastFuelUpdate: DateTime.now(),
            );
            ActiveBikeController.instance.updateBike(updated);
            FuelTrackerService.instance.resetLowFuelFlag();
            if (mounted) Navigator.of(context).pop();
            return;
          }
        }
      }
    }

    // Default full refill without average update
    final updated = widget.bike.copyWith(
      fuelRemainingLiters: _tankCapacity,
      lastFullRefillOdometer: currentOdo,
      lastFuelUpdate: DateTime.now(),
    );
    ActiveBikeController.instance.updateBike(updated);
    FuelTrackerService.instance.resetLowFuelFlag();

    final fuelPrice = SettingsController.instance.fuelPricePerLiter;
    if (fuelPrice != null && litersAdded > 0) {
      TripBudgetController.instance.addExpense(
        Expense(
          id: 'exp-fuel-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Fuel Refill (${litersAdded.toStringAsFixed(1)} L)',
          amount: double.parse((litersAdded * fuelPrice).toStringAsFixed(2)),
          category: ExpenseCategory.fuel,
          dateRecorded: DateTime.now(),
          trackingMode: ExpenseTrackingMode.manualEntry,
          subtitle: '${widget.bike.make} ${widget.bike.modelName}',
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<bool?> _showLearningDialog({
    required double distanceTraveled,
    required double litersAdded,
    required double computedAvg,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Full-to-Full Refill Learning',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: AppColors.darkCharcoal,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracked ${distanceTraveled.toStringAsFixed(1)} km between full refills with ${litersAdded.toStringAsFixed(1)} L added.',
              style: GoogleFonts.manrope(
                fontSize: 13.5,
                color: AppColors.darkCharcoal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    color: AppColors.tacticalOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Calculated: $computedAvg km/L',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.tacticalOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Update fuel average to $computedAvg km/L?',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep mine',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Yes, update',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePartialRefill() {
    final current = widget.bike.fuelRemainingLiters ?? 0.0;
    final newLevel = (current + _addedLiters).clamp(0.0, _tankCapacity);
    final updated = widget.bike.copyWith(
      fuelRemainingLiters: double.parse(newLevel.toStringAsFixed(1)),
      lastFuelUpdate: DateTime.now(),
    );
    ActiveBikeController.instance.updateBike(updated);

    final pct = FuelEstimator.percent(newLevel, _tankCapacity);
    if (pct != null && pct >= 15.0) {
      FuelTrackerService.instance.resetLowFuelFlag();
    }

    final fuelPrice = SettingsController.instance.fuelPricePerLiter;
    if (fuelPrice != null && _addedLiters > 0) {
      TripBudgetController.instance.addExpense(
        Expense(
          id: 'exp-fuel-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Fuel Refill (${_addedLiters.toStringAsFixed(1)} L)',
          amount: double.parse((_addedLiters * fuelPrice).toStringAsFixed(2)),
          category: ExpenseCategory.fuel,
          dateRecorded: DateTime.now(),
          trackingMode: ExpenseTrackingMode.manualEntry,
          subtitle: '${widget.bike.make} ${widget.bike.modelName}',
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fuelAvg = widget.bike.fuelAverageKmPerLiter;
    final range = FuelEstimator.rangeKm(_liters, fuelAvg);
    final pct = FuelEstimator.percent(_liters, _tankCapacity) ?? 0.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.clay,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.skeuRaisedSmall,
                ),
                child: const Icon(
                  Icons.local_gas_station_rounded,
                  color: AppColors.tacticalOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fuel Level & Refill',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.bike.make} ${widget.bike.modelName} • ${_tankCapacity.toStringAsFixed(0)} L Tank',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Mode toggle: Set current fuel vs I refilled
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showRefillSection = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_showRefillSection
                          ? AppColors.tacticalOrange
                          : AppColors.clay,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: !_showRefillSection
                          ? AppColors.orangeGlow
                          : AppColors.skeuRaisedSmall,
                    ),
                    child: Center(
                      child: Text(
                        'Set Current Fuel',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: !_showRefillSection
                              ? Colors.white
                              : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showRefillSection = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _showRefillSection
                          ? AppColors.tacticalOrange
                          : AppColors.clay,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: _showRefillSection
                          ? AppColors.orangeGlow
                          : AppColors.skeuRaisedSmall,
                    ),
                    child: Center(
                      child: Text(
                        'I Refilled',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _showRefillSection
                              ? Colors.white
                              : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (!_showRefillSection) ...[
            // ── Set Current Fuel Mode ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                boxShadow: AppColors.skeuInset,
              ),
              child: Column(
                children: [
                  Text(
                    '${_liters.toStringAsFixed(1)} / ${_tankCapacity.toStringAsFixed(0)} L (est.)',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    range != null
                        ? 'about ${range.round()} km range • ${pct.toStringAsFixed(0)}%'
                        : '${pct.toStringAsFixed(0)}% • Add fuel average to see range',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tacticalOrange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slider in liters
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.tacticalOrange,
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: AppColors.tacticalOrange,
                overlayColor: AppColors.tacticalOrange.withValues(alpha: 0.15),
                trackHeight: 6,
              ),
              child: Slider(
                value: _liters,
                min: 0.0,
                max: _tankCapacity,
                divisions: (_tankCapacity * 10).round().clamp(10, 500),
                onChanged: (val) => setState(() => _liters = val),
              ),
            ),

            // Presets in liters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _presetLitersChip('Empty', 0.0),
                _presetLitersChip(
                  '${(_tankCapacity * 0.25).toStringAsFixed(1)} L',
                  _tankCapacity * 0.25,
                ),
                _presetLitersChip(
                  '${(_tankCapacity * 0.50).toStringAsFixed(1)} L',
                  _tankCapacity * 0.50,
                ),
                _presetLitersChip(
                  '${(_tankCapacity * 0.75).toStringAsFixed(1)} L',
                  _tankCapacity * 0.75,
                ),
                _presetLitersChip(
                  'Full (${_tankCapacity.toStringAsFixed(0)} L)',
                  _tankCapacity,
                ),
              ],
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Save Fuel Level',
              icon: Icons.check_rounded,
              onTap: _saveCurrentFuel,
              isFullWidth: true,
            ),
          ] else ...[
            // ── I Refilled Mode ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Option 1: Complete Fill-Up',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tacticalOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(
                      Icons.local_gas_station_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Filled to full (${_tankCapacity.toStringAsFixed(0)} L)',
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _handleFilledToFull,
                  ),
                  Builder(
                    builder: (context) {
                      final fuelPrice =
                          SettingsController.instance.fuelPricePerLiter;
                      final litersNeeded = (_tankCapacity -
                              (widget.bike.fuelRemainingLiters ?? 0.0))
                          .clamp(0.0, _tankCapacity);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Center(
                          child: Text(
                            fuelPrice != null
                                ? '${litersNeeded.toStringAsFixed(1)} L • ${formatPkr(litersNeeded * fuelPrice)}'
                                : '${litersNeeded.toStringAsFixed(1)} L • Add fuel price to see cost',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Option 2: Added Partial Liters',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _addedLiters > 1.0
                            ? () => setState(() => _addedLiters -= 1.0)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: AppColors.tacticalOrange,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: AppColors.skeuInset,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+${_addedLiters.toStringAsFixed(1)} L',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final fuelPrice =
                                    SettingsController.instance.fuelPricePerLiter;
                                return Text(
                                  fuelPrice != null
                                      ? formatPkr(_addedLiters * fuelPrice)
                                      : 'Add fuel price to see cost',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mutedText,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _addedLiters < _tankCapacity
                            ? () => setState(() => _addedLiters += 1.0)
                            : null,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: AppColors.tacticalOrange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label:
                        'Add ${_addedLiters.toStringAsFixed(1)} Liters to Tank',
                    icon: Icons.add_rounded,
                    onTap: _handlePartialRefill,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _presetLitersChip(String label, double value) {
    final isSelected = (_liters - value).abs() < 0.1;
    return GestureDetector(
      onTap: () => setState(() => _liters = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tacticalOrange : AppColors.clay,
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          boxShadow:
              isSelected ? AppColors.orangeGlow : AppColors.skeuRaisedSmall,
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}
