import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
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

  late TripBudget _tripBudget;
  late List<Expense> _expenses;
  late List<MaintenanceItem> _maintenanceItems;

  @override
  void initState() {
    super.initState();
    _tripBudget = TripBudget.defaultSampleBudget;
    _expenses = List.from(Expense.defaultSampleExpenses);
    _maintenanceItems = List.from(MaintenanceItem.defaultSampleItems);
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
          initialBudget: _tripBudget,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _tripBudget = result;
      });
      _showNotification('Budget updated for ${_tripBudget.tripName}');
    }
  }

  Future<void> _pushAddExpense() async {
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _expenses.insert(0, result);
        _tripBudget = _tripBudget.copyWith(
          allocatedSoFar: _tripBudget.allocatedSoFar + result.amount,
        );
      });
      _showNotification('Added ${result.title} (\$${result.amount.toStringAsFixed(2)})');
    }
  }

  Future<void> _pushAddMaintenanceItem() async {
    final result = await Navigator.of(context).push<MaintenanceItem>(
      MaterialPageRoute(
        builder: (context) => const AddMaintenanceItemScreen(),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _maintenanceItems.add(result);
      });
      _showNotification('Added ${result.name} to maintenance list');
    }
  }

  void _handleDeleteTrip() {
    setState(() {
      _tripBudget = const TripBudget(
        tripName: 'New Expedition',
        capAmount: 0.0,
        allocatedSoFar: 0.0,
      );
      _expenses.clear();
    });
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
                      onActionPressed: () =>
                          _showNotification('Finances & Rig Health telemetry active'),
                    ),

                    const SizedBox(height: 14),

                    // 2. Section Header Block: EXPEDITION TELEMETRY + Title + SYNCED pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPEDITION TELEMETRY', style: AppTextStyles.overline),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Finances & Rig Health',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                borderRadius:
                                    BorderRadius.circular(AppColors.radiusPill),
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
                                    'SYNCD 2m ago',
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

                    // 3. Hero Photo Widget (KTM 890 Adventure R + masked VIN)
                    const HeroPhotoWidget(
                      bikeName: '🏍 KTM 890 Adventure R',
                      vinSnippet: 'VIN ••9482',
                      imagePath: 'assets/images/bmw_r1250_scan_placeholder.jpg',
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 4. Trip Budget & Fuel Economics Card
                    TripBudgetCardWidget(
                      tripBudget: _tripBudget,
                      expenses: _expenses,
                      onEditTrip: _pushEditTripBudget,
                      onDeleteTrip: _handleDeleteTrip,
                      onAddExpense: _pushAddExpense,
                      onExpenseTapped: (exp) {
                        _showNotification('${exp.title}: \$${exp.amount.toStringAsFixed(2)}');
                      },
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 5. Second Card: "⚙ Add or Adjust Trip Budget"
                    CampCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      onTap: _pushEditTripBudget,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.settings_outlined,
                            size: 16,
                            color: AppColors.tacticalOrangeDark,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Add or Adjust Trip Budget',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: AppColors.tacticalOrangeDark,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 6. Maintenance List Widget (Condition Telemetry + 5 items + Add button)
                    MaintenanceListWidget(
                      items: _maintenanceItems,
                      onAddMaintenanceItem: _pushAddMaintenanceItem,
                      onItemGuidePressed: (item) {
                        _showNotification('Opening service guide for ${item.name}...');
                      },
                      onItemTapped: (item) {
                        _showNotification('${item.name}: ${item.statusValueDisplay ?? ''}');
                      },
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 7. Download Maintenance Report Card
                    const DownloadReportCardWidget(
                      label: 'Download Maintenance Report (PDF)',
                      subtitle: 'Receipts, telemetry logs & schedule',
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 8. Upcoming Pitstop Card
                    PitstopCardWidget(
                      dateLabel: 'Oct 18, 10:00 AM',
                      locationLabel: 'Peak Moto Dealership & Prep • Denver, CO',
                      onCallDealer: () =>
                          _showNotification('Calling Peak Moto Dealership...'),
                      onDirections: () =>
                          Navigator.of(context).pushNamed('/mechanics/map'),
                    ),
                  ],
                ),
              ),
            ),

            // 9. Floating Tactical Bottom Dock (selected index: 4)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: CampBottomNav(
                  selectedIndex: 4,
                  onIndexChanged: (index) {
                    CampBottomNav.navigateToTab(
                      context,
                      index,
                      currentIndex: 4,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
