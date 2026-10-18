import 'package:camp/features/garage/controllers/active_bike_controller.dart';
import 'package:camp/features/maintenance/domain/expense_model.dart';
import 'package:camp/features/maintenance/domain/maintenance_item_model.dart';
import 'package:camp/features/maintenance/domain/trip_budget_model.dart';
import 'package:camp/features/maintenance/presentation/screens/add_expense_screen.dart';
import 'package:camp/features/maintenance/presentation/screens/add_maintenance_item_screen.dart';
import 'package:camp/features/maintenance/presentation/screens/edit_trip_budget_screen.dart';
import 'package:camp/features/maintenance/presentation/screens/finance_rig_health_screen.dart';
import 'package:camp/features/maintenance/presentation/screens/maintenance_screen.dart';
import 'package:camp/features/maintenance/presentation/widgets/delete_trip_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TripBudget calculations and models', () {
    const budget = TripBudget.defaultSampleBudget;
    expect(budget.tripName, 'Alpine Ridge Tour');
    expect(budget.capAmount, 75000.0);
    expect(budget.allocatedSoFar, 46125.0);
    expect(budget.spentPercentInt, 62);
    expect(budget.isUnderBudget, true);
    expect(budget.underBudgetAmount, 28875.0);
  });

  test('Expense and MaintenanceItem default sample models', () {
    final expenses = Expense.defaultSampleExpenses;
    expect(expenses.length, 3);
    expect(expenses[0].title, 'Fuel Cost');
    expect(expenses[0].amount, 9800.0);

    final items = MaintenanceItem.defaultSampleItems;
    expect(items.length, 5);
    expect(items[0].name, 'Rear Brake Pad Replacement');
    expect(items[1].name, 'Engine Oil & Filter');
    expect(items[2].name, 'Chain / Final Drive Shaft');
    expect(items[3].name, 'Tire Tread Depth');
    expect(items[4].name, 'Fork Seals & Dust Boots');
  });

  testWidgets('FinanceRigHealthScreen renders completely without overflow at 360px',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FinanceRigHealthScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and section titles
    expect(find.text('FINANCES & RIG HEALTH'), findsOneWidget);
    expect(find.text('EXPEDITION STATS'), findsOneWidget);
    expect(find.text('Finances & Rig Health'), findsOneWidget);
    expect(find.text('LOCAL'), findsOneWidget);

    // Verify hero photo overlay
    final activeBike = ActiveBikeController.instance.activeBike;
    if (activeBike != null) {
      expect(
        find.text('🏍 ${activeBike.make} ${activeBike.modelName}'),
        findsOneWidget,
      );
      if (activeBike.vin != null && activeBike.vin!.isNotEmpty) {
        final vinSub = activeBike.vin!.substring(
          activeBike.vin!.length >= 4 ? activeBike.vin!.length - 4 : 0,
        );
        expect(find.text('VIN ••$vinSub'), findsOneWidget);
      }
    } else {
      expect(find.text('🏍 No Active Motorcycle'), findsOneWidget);
    }

    // Verify trip budget card elements
    expect(find.text('🏔 Alpine Ridge Tour'), findsOneWidget);
    expect(find.text('Trip Budget & Fuel Economics'), findsOneWidget);
    expect(find.text('Rs 46,125'), findsOneWidget);
    expect(find.textContaining('under target budget'), findsOneWidget);
    expect(find.text('Fuel Cost'), findsOneWidget);
    expect(find.text('Park Permits & Passes'), findsOneWidget);
    expect(find.text('Camp Lodging & Fees'), findsOneWidget);
    expect(find.text('Add Expense'), findsWidgets);

    // Verify maintenance list items
    expect(find.text('RIG CONDITION'), findsOneWidget);
    expect(find.textContaining('Upcoming & Required'), findsOneWidget);
    expect(find.text('Rear Brake Pad Replacement'), findsOneWidget);
    expect(find.text('Engine Oil & Filter'), findsOneWidget);
    expect(find.text('Chain / Final Drive Shaft'), findsOneWidget);
    expect(find.text('Tire Tread Depth'), findsOneWidget);
    expect(find.text('Fork Seals & Dust Boots'), findsOneWidget);
    expect(find.text('+ Add Maintenance Item'), findsOneWidget);

    // Verify reports & service visit
    expect(find.text('Download Budget Report (PDF)'), findsOneWidget);
    expect(find.text('Download Maintenance Report (PDF)'), findsOneWidget);
    expect(find.text('NEXT SERVICE VISIT'), findsOneWidget);
    expect(find.text('No service visit planned'), findsOneWidget);
  });

  testWidgets('AddExpenseScreen renders clean form at 360px',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AddExpenseScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('🛢 Fuel'), findsOneWidget);
    expect(find.text('AMOUNT'), findsOneWidget);
    expect(find.text('NOTE / LOCATION'), findsOneWidget);
    expect(find.text('TRACKING MODE'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });

  testWidgets('EditTripBudgetScreen renders with live impact at 360px',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: EditTripBudgetScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TRIP NAME'), findsOneWidget);
    expect(find.text('TOTAL BUDGET CAP'), findsOneWidget);
    expect(find.text('LIVE ALLOCATION IMPACT'), findsOneWidget);
    expect(find.text('Save Budget'), findsOneWidget);
  });

  testWidgets('AddMaintenanceItemScreen renders with 2x2 grid at 360px',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AddMaintenanceItemScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ITEM NAME'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.text('Due Soon'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('DIY-rec'), findsOneWidget);
    expect(find.text('Add Item'), findsOneWidget);
  });

  testWidgets('DeleteTripDialogWidget renders confirmation UI',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DeleteTripDialogWidget(
            tripName: 'Alpine Ridge Tour',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete Alpine Ridge Tour?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('MaintenanceScreen initialTab respects EFI fallback and carburetor selection',
      (WidgetTester tester) async {
    // BMW is default active bike (EFI)
    ActiveBikeController.instance.reset();
    expect(ActiveBikeController.instance.activeBike?.fuelSystem.name, 'efi');

    await tester.pumpWidget(
      const MaterialApp(
        home: MaintenanceScreen(initialTab: MaintenanceTab.carburetor),
      ),
    );
    await tester.pumpAndSettle();

    // EFI bike should fallback to Diagnostics tab, Carburetor tab should not even exist
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('Carburetor'), findsNothing);

    // Switch to Rebel 500 (Carburetor)
    ActiveBikeController.instance.setActiveBike('bike-rebel-500');

    await tester.pumpWidget(
      const MaterialApp(
        home: MaintenanceScreen(initialTab: MaintenanceTab.carburetor),
      ),
    );
    await tester.pumpAndSettle();

    // Carburetor bike should show Carburetor tab and select it
    expect(find.text('Carburetor'), findsOneWidget);
  });
}
