import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/data/app_repositories.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../controllers/trip_budget_controller.dart';
import '../../domain/expense_model.dart';
import '../../domain/maintenance_item_model.dart';
import '../../domain/trip_budget_model.dart';
import '../widgets/download_report_card_widget.dart';
import '../widgets/hero_photo_widget.dart';
import '../widgets/maintenance_list_widget.dart';
import '../widgets/pitstop_card_widget.dart';
import '../widgets/trip_budget_card_widget.dart';
import 'add_expense_screen.dart';
import 'add_maintenance_item_screen.dart';
import 'edit_trip_budget_screen.dart';

/// CAMP Finances & Rig Health Screen (Main Expedition Cockpit Feature Slice)
/// Displays expedition telemetry, trip budget & fuel economics, maintenance schedule,
/// pitstop bookings, and PDF report downloads.
class FinanceRigHealthScreen extends StatefulWidget {
  const FinanceRigHealthScreen({super.key});

  @override
  State<FinanceRigHealthScreen> createState() => _FinanceRigHealthScreenState();
}

class _FinanceRigHealthScreenState extends State<FinanceRigHealthScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<MaintenanceItem> _maintenanceItems;

  @override
  void initState() {
    super.initState();
    _maintenanceItems = kDebugMode
        ? List.from(MaintenanceItem.defaultSampleItems)
        : <MaintenanceItem>[];
    _loadPersistedItems();
  }

  Future<void> _loadPersistedItems() async {
    try {
      final loaded = await AppRepositories.instance.maintenanceRepository.loadMaintenanceItems();
      if (loaded.isNotEmpty && mounted) {
        setState(() {
          _maintenanceItems = loaded;
        });
      }
    } catch (_) {}
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  Future<void> _pushEditTripBudget() async {
    final result = await Navigator.of(context).push<TripBudget>(
      MaterialPageRoute(
        builder: (context) => EditTripBudgetScreen(
          initialBudget: TripBudgetController.instance.budget,
        ),
      ),
    );
    if (result != null && mounted) {
      TripBudgetController.instance.setBudget(result);
      _showNotification('Budget updated for ${result.tripName}');
    }
  }

  Future<void> _pushAddExpense() async {
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    if (result != null && mounted) {
      TripBudgetController.instance.addExpense(result);
      _showNotification(
        'Added ${result.title} (${formatPkr(result.amount)})',
      );
    }
  }

  Future<void> _pushAddMaintenanceItem() async {
    final result = await Navigator.of(context).push<MaintenanceItem>(
      MaterialPageRoute(builder: (context) => const AddMaintenanceItemScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _maintenanceItems.add(result);
      });
      AppRepositories.instance.maintenanceRepository.saveMaintenanceItems(_maintenanceItems);
      _showNotification('Added ${result.name} to maintenance list');
    }
  }

  void _handleDeleteTrip() {
    TripBudgetController.instance.deleteTrip();
    _showNotification('Trip deleted. Maintenance records preserved.');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawerWidget(),
        backgroundColor: AppColors.clay,
        body: Stack(
          children: [
            // ── Scrollable Body ─────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppColors.screenPadding,
                  8.0,
                  AppColors.screenPadding,
                  110.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. App Bar with Menu and actionText pill
                    CampAppBar(
                      leading: CampAppBarLeading.menu,
                      onLeadingPressed: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      actionText: 'FINANCES & RIG HEALTH',
                      onActionPressed: () => _showNotification(
                        'Finances & Rig Health active',
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 2. Section Header Block: EXPEDITION TELEMETRY + Title + SYNCED pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPEDITION STATS',
                          style: AppTextStyles.overline,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Finances & Rig Health',
                                style: AppTextStyles.title,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Trailing "SYNCD 2m ago" pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.clayDark,
                                borderRadius: BorderRadius.circular(
                                  AppColors.radiusPill,
                                ),
                                boxShadow: AppColors.skeuRaisedSmall,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.sync_rounded,
                                    size: 13,
                                    color: AppColors.statusGreen,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'LOCAL',
                                    style: GoogleFonts.manrope(
                                      color: AppColors.darkCharcoal,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 3. Hero Photo Widget (Active Rig + masked VIN)
                    ListenableBuilder(
                      listenable: ActiveBikeController.instance,
                      builder: (context, _) {
                        final bike = ActiveBikeController.instance.activeBike;
                        return HeroPhotoWidget(
                          bikeName: bike != null
                              ? '🏍 ${bike.make} ${bike.modelName}'
                              : '🏍 No Active Motorcycle',
                          vinSnippet: bike != null &&
                                  bike.vin != null &&
                                  bike.vin!.isNotEmpty
                              ? 'VIN ••${bike.vin!.substring(bike.vin!.length >= 4 ? bike.vin!.length - 4 : 0)}'
                              : 'GARAGE FLEET',
                          imagePath: (bike?.imagePath != null &&
                                  bike!.imagePath!.isNotEmpty)
                              ? bike.imagePath!
                              : 'assets/images/bmw_r1250_scan_placeholder.jpg',
                        );
                      },
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 4. Trip Budget & Fuel Economics Card
                    ListenableBuilder(
                      listenable: TripBudgetController.instance,
                      builder: (context, _) => TripBudgetCardWidget(
                        tripBudget: TripBudgetController.instance.budget,
                        expenses: TripBudgetController.instance.expenses,
                        onEditTrip: _pushEditTripBudget,
                        onDeleteTrip: _handleDeleteTrip,
                        onAddExpense: _pushAddExpense,
                        onExpenseTapped: (exp) {
                          _showNotification(
                            '${exp.title}: ${formatPkr(exp.amount)}',
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppColors.cardGap),
                    // 6. Maintenance List Widget (Condition Telemetry + 5 items + Add button)
                    MaintenanceListWidget(
                      items: _maintenanceItems,
                      onAddMaintenanceItem: _pushAddMaintenanceItem,
                      onItemGuidePressed: (item) {
                        _showNotification(
                          'Opening service guide for ${item.name}...',
                        );
                      },
                      onItemTapped: (item) {
                        _showNotification(
                          '${item.name}: ${item.statusValueDisplay ?? ''}',
                        );
                      },
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 7. Download Maintenance Report Card
                    const DownloadReportCardWidget(
                      label: 'Download Maintenance Report (PDF)',
                      subtitle: 'Receipts, service logs & schedule',
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 8. Upcoming Pitstop Card
                    PitstopCardWidget(
                      dateLabel: 'Oct 18, 10:00 AM',
                      locationLabel: 'Peak Moto Dealership & Prep • Denver, CO',
                      onCallDealer: () =>
                          _showNotification('Calling Peak Moto Dealership...'),
                      onDirections: () =>
                          Navigator.of(context).pushNamed(CampRoutes.navigationMap),
                    ),
                  ],
                ),
              ),
            ),

            // 9. Floating Tactical Bottom Dock (selected index: 4)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: CampBottomNav(
                  selected: CampTab.finances,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
