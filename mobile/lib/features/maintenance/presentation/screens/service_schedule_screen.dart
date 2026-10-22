import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_card.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../garage/domain/bike_model.dart';
import '../../controllers/maintenance_controller.dart';
import '../../domain/service_schedule_item.dart';

/// Screen allowing the rider to configure their own service schedule per bike.
class ServiceScheduleScreen extends StatefulWidget {
  const ServiceScheduleScreen({super.key, this.bikeId, this.focusItemType});

  final String? bikeId;
  final ServiceItemType? focusItemType;

  @override
  State<ServiceScheduleScreen> createState() => _ServiceScheduleScreenState();
}

class _ServiceScheduleScreenState extends State<ServiceScheduleScreen> {
  late Bike? _bike;
  bool _isHarsh = false;
  bool _hasCarburetorOverride = false;

  final Map<ServiceItemType, GlobalKey> _itemKeys = {};
  final Map<ServiceItemType, bool> _enabled = {};
  final Map<ServiceItemType, TextEditingController> _kmControllers = {};
  final Map<ServiceItemType, TextEditingController> _monthControllers = {};
  final Map<ServiceItemType, TextEditingController> _lastDoneKmControllers = {};
  final Map<ServiceItemType, DateTime?> _lastDoneDates = {};

  @override
  void initState() {
    super.initState();
    _resolveBike();
    _loadState();
    if (widget.focusItemType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = _itemKeys[widget.focusItemType];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _resolveBike() {
    if (widget.bikeId != null && widget.bikeId!.isNotEmpty) {
      _bike = ActiveBikeController.instance.getBikeById(widget.bikeId!);
    } else {
      _bike = ActiveBikeController.instance.activeBike;
    }
  }

  void _loadState() {
    if (_bike == null) return;
    final bikeId = _bike!.id;

    _isHarsh = MaintenanceController.instance.isHarshConditions(bikeId);
    _hasCarburetorOverride = MaintenanceController.instance.isCarbureted(_bike);

    final items = MaintenanceController.instance.getScheduleItems(bikeId);
    for (final item in items) {
      _enabled[item.type] = item.enabled;
      _kmControllers[item.type] = TextEditingController(
        text: item.intervalKm != null ? item.intervalKm.toString() : '',
      );
      _monthControllers[item.type] = TextEditingController(
        text: item.intervalMonths != null ? item.intervalMonths.toString() : '',
      );
      _lastDoneKmControllers[item.type] = TextEditingController(
        text: item.lastDoneKm != null
            ? (item.lastDoneKm! % 1 == 0
                ? item.lastDoneKm!.toInt().toString()
                : item.lastDoneKm!.toString())
            : '',
      );
      _lastDoneDates[item.type] = item.lastDoneDate;
    }

    // Initialize any types not yet in map
    for (final type in ServiceItemType.values) {
      _enabled.putIfAbsent(type, () => true);
      _kmControllers.putIfAbsent(type, () => TextEditingController());
      _monthControllers.putIfAbsent(type, () => TextEditingController());
      _lastDoneKmControllers.putIfAbsent(type, () => TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _kmControllers.values) {
      c.dispose();
    }
    for (final c in _monthControllers.values) {
      c.dispose();
    }
    for (final c in _lastDoneKmControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_bike == null) return;
    final bikeId = _bike!.id;

    await MaintenanceController.instance.setHarshConditions(bikeId, _isHarsh);
    MaintenanceController.instance.setCarburetorOverride(bikeId, _hasCarburetorOverride);

    final isCarb = _bike!.fuelSystem == FuelSystem.carburetor || _hasCarburetorOverride;

    final updatedItems = <ServiceScheduleItem>[];
    for (final type in ServiceItemType.values) {
      if (type == ServiceItemType.carburetor && !isCarb) {
        continue;
      }

      final kmText = _kmControllers[type]?.text.trim() ?? '';
      final monthText = _monthControllers[type]?.text.trim() ?? '';
      final lastKmText = _lastDoneKmControllers[type]?.text.trim() ?? '';

      final intervalKm = int.tryParse(kmText);
      final intervalMonths = int.tryParse(monthText);
      final lastDoneKm = double.tryParse(lastKmText);
      final lastDoneDate = _lastDoneDates[type];
      final enabled = _enabled[type] ?? true;

      updatedItems.add(ServiceScheduleItem(
        id: 'sched_${bikeId}_${type.name}',
        bikeId: bikeId,
        type: type,
        intervalKm: intervalKm,
        intervalMonths: intervalMonths,
        lastDoneKm: lastDoneKm,
        lastDoneDate: lastDoneDate,
        enabled: enabled,
        updatedAt: DateTime.now().toUtc(),
      ));
    }

    await MaintenanceController.instance.saveSchedule(bikeId, updatedItems);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service schedule saved'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.statusGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bike == null) {
      return Scaffold(
        backgroundColor: AppColors.clay,
        appBar: CampAppBar(
          leading: CampAppBarLeading.back,
          onLeadingPressed: () => Navigator.of(context).pop(),
          actionText: 'SERVICE SCHEDULE',
        ),
        body: const Center(child: Text('No active motorcycle selected')),
      );
    }

    final isCarbBike = _bike!.fuelSystem == FuelSystem.carburetor || _hasCarburetorOverride;

    final typesToDisplay = ServiceItemType.values.where((t) {
      if (t == ServiceItemType.carburetor && !isCarbBike) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.clay,
      body: SafeArea(
        child: Column(
          children: [
            CampAppBar(
              leading: CampAppBarLeading.back,
              onLeadingPressed: () => Navigator.of(context).pop(),
              actionText: 'SERVICE SCHEDULE',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bike Context Banner
                    _buildBikeHeader(_bike!),
                    const SizedBox(height: 14),

                    // Harsh Conditions Switch
                    _buildHarshConditionsCard(),
                    const SizedBox(height: 14),

                    // Carburetor Toggle (only shown when bike is not natively carbureted)
                    if (_bike!.fuelSystem != FuelSystem.carburetor) ...[
                      _buildCarburetorSwitchCard(),
                      const SizedBox(height: 14),
                    ],

                    // Section Header
                    Text(
                      'SCHEDULE INTERVALS',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mutedText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // One row / card per service item type
                    ...typesToDisplay.map((type) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildItemCard(type),
                        )),

                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tacticalOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radiusTile),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _save,
                      child: Text(
                        'Save Schedule',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeHeader(Bike bike) {
    return CampCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.clayDark,
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
              boxShadow: AppColors.skeuRecessed,
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              color: AppColors.tacticalOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bike.make} ${bike.modelName}',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                Text(
                  'Odometer: ${bike.odometerKm} km • ${_isHarsh ? "Harsh Conditions ON (-20%)" : "Standard Conditions"}',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarshConditionsCard() {
    return CampCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.tacticalOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harsh conditions',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                Text(
                  'Dust, heat, off-road, heavy traffic (shortens intervals by 20%)',
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isHarsh,
            activeThumbColor: AppColors.tacticalOrange,
            onChanged: (val) {
              setState(() {
                _isHarsh = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarburetorSwitchCard() {
    return CampCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.speed_rounded,
            color: AppColors.terracotta,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My bike has a carburetor',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                Text(
                  'Enables carburetor service and jetting tracking',
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _hasCarburetorOverride,
            activeThumbColor: AppColors.tacticalOrange,
            onChanged: (val) {
              setState(() {
                _hasCarburetorOverride = val;
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatKm(int km) {
    final str = km.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  String _getKmLabel(ServiceItemType type) {
    switch (type) {
      case ServiceItemType.oilAndSmallService:
        return 'Change oil every (km)';
      case ServiceItemType.oilFilter:
        return 'Change oil filter every (km)';
      case ServiceItemType.airFilter:
        return 'Clean or replace every (km)';
      case ServiceItemType.chain:
        return 'Clean and lube every (km)';
      case ServiceItemType.sparkPlug:
        return 'Check or replace every (km)';
      case ServiceItemType.tuning:
        return 'Full tuning every (km)';
      case ServiceItemType.brakes:
        return 'Check brake pads every (km)';
      case ServiceItemType.tyres:
        return 'Check tyres every (km)';
      case ServiceItemType.carburetor:
        return 'Clean or adjust every (km)';
      case ServiceItemType.battery:
        return 'Check battery every (months)';
    }
  }

  String _getKmHelperText(ServiceItemType type) {
    switch (type) {
      case ServiceItemType.oilAndSmallService:
        return 'Distance between oil changes, e.g. 1,500 km';
      case ServiceItemType.oilFilter:
        return 'Distance between oil filter changes';
      case ServiceItemType.airFilter:
        return 'Distance between air filter services';
      case ServiceItemType.chain:
        return 'Distance between chain cleaning and lubing';
      case ServiceItemType.sparkPlug:
        return 'Distance between spark plug checks';
      case ServiceItemType.tuning:
        return 'Distance between full tune-ups, e.g. 10,000 km';
      case ServiceItemType.brakes:
        return 'Distance between brake checks';
      case ServiceItemType.tyres:
        return 'Distance between tyre checks';
      case ServiceItemType.carburetor:
        return 'Distance between carburetor services';
      case ServiceItemType.battery:
        return 'Time between battery checks';
    }
  }

  String _getMonthsLabel(ServiceItemType type) {
    switch (type) {
      case ServiceItemType.oilAndSmallService:
      case ServiceItemType.oilFilter:
        return 'Or change every (months)';
      case ServiceItemType.airFilter:
        return 'Or clean or replace every (months)';
      case ServiceItemType.chain:
        return 'Or clean and lube every (months)';
      case ServiceItemType.sparkPlug:
        return 'Or check or replace every (months)';
      case ServiceItemType.tuning:
        return 'Or tune every (months)';
      case ServiceItemType.brakes:
      case ServiceItemType.tyres:
        return 'Or check every (months)';
      case ServiceItemType.carburetor:
        return 'Or clean or adjust every (months)';
      case ServiceItemType.battery:
        return 'Check battery every (months)';
    }
  }

  Widget _buildItemCard(ServiceItemType type) {
    final enabled = _enabled[type] ?? true;
    final kmController = _kmControllers[type]!;
    final monthController = _monthControllers[type]!;
    final lastKmController = _lastDoneKmControllers[type]!;
    final lastDate = _lastDoneDates[type];

    // Compute effective interval text transparently for km field
    final rawKm = int.tryParse(kmController.text.trim());
    final bool isHarshActive = _isHarsh && rawKm != null && rawKm > 0;
    final String kmHelperText;
    if (isHarshActive) {
      final effectiveKm = (rawKm * 0.80).round();
      kmHelperText = '${_formatKm(rawKm)} km -> ${_formatKm(effectiveKm)} km (harsh conditions)';
    } else {
      kmHelperText = _getKmHelperText(type);
    }

    final match = _bike != null
        ? MaintenanceController.instance.findLastLoggedService(_bike!.id, type)
        : null;

    final isBattery = type == ServiceItemType.battery;

    return CampCard(
      key: _itemKeys.putIfAbsent(type, () => GlobalKey()),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon, Name, and Enable Switch
          Row(
            children: [
              Icon(type.icon, color: AppColors.tacticalOrange, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type.displayName,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeThumbColor: AppColors.tacticalOrange,
                onChanged: (val) {
                  setState(() {
                    _enabled[type] = val;
                  });
                },
              ),
            ],
          ),

          if (enabled) ...[
            const Divider(height: 20, color: AppColors.clayDark),

            if (isBattery) ...[
              // Battery: single time-based interval
              Text(
                _getMonthsLabel(type),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: monthController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. 6 (optional)',
                  hintStyle: GoogleFonts.manrope(fontSize: 13, color: AppColors.mutedLight),
                  suffixText: 'months',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
                    borderSide: const BorderSide(color: AppColors.clayDark),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text(
                'Time between battery checks',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 8),

              // Quick Pick Month Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: type.quickMonthSuggestions.map((months) {
                  return ActionChip(
                    label: Text('$months mo'),
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                    backgroundColor: AppColors.clayDark,
                    onPressed: () {
                      monthController.text = months.toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ] else ...[
              // Distance Interval Section
              Text(
                _getKmLabel(type),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: kmController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. 1500 (optional)',
                  hintStyle: GoogleFonts.manrope(fontSize: 13, color: AppColors.mutedLight),
                  suffixText: 'km',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
                    borderSide: const BorderSide(color: AppColors.clayDark),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text(
                kmHelperText,
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: isHarshActive ? FontWeight.w700 : FontWeight.w600,
                  color: isHarshActive ? AppColors.tacticalOrangeDark : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 8),

              // Quick Pick KM Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: type.quickKmSuggestions.map((suggestedKm) {
                  return ActionChip(
                    label: Text('$suggestedKm km'),
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                    backgroundColor: AppColors.clayDark,
                    onPressed: () {
                      kmController.text = suggestedKm.toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Time Interval Section
              Text(
                _getMonthsLabel(type),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: monthController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. 6 (optional)',
                  hintStyle: GoogleFonts.manrope(fontSize: 13, color: AppColors.mutedLight),
                  suffixText: 'months',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
                    borderSide: const BorderSide(color: AppColors.clayDark),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 4),
              Text(
                'Optional. Reminds you by time too. Whichever comes first counts. Leave empty to track by km only.',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 8),

              // Quick Pick Month Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: type.quickMonthSuggestions.map((months) {
                  return ActionChip(
                    label: Text('$months mo'),
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                    backgroundColor: AppColors.clayDark,
                    onPressed: () {
                      monthController.text = months.toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Last Done Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.clayDark.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'When did you last do this?',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      if (match != null)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            if (match.km != null) {
                              lastKmController.text = match.km!.round().toString();
                            }
                            if (match.date != null) {
                              _lastDoneDates[type] = match.date;
                            }
                            setState(() {});
                          },
                          child: Text(
                            'Use last logged service',
                            style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.tacticalOrangeDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lastKmController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Odometer (km)',
                            labelStyle: GoogleFonts.manrope(fontSize: 12),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
                              borderSide: const BorderSide(color: AppColors.clayDark),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: lastDate ?? now,
                              firstDate: DateTime(2000),
                              lastDate: now,
                            );
                            if (picked != null) {
                              setState(() {
                                _lastDoneDates[type] = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
                              border: Border.all(color: AppColors.clayDark),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.mutedText),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    lastDate != null
                                        ? '${lastDate.day}/${lastDate.month}/${lastDate.year}'
                                        : 'Date',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: lastDate != null ? AppColors.darkCharcoal : AppColors.mutedLight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
