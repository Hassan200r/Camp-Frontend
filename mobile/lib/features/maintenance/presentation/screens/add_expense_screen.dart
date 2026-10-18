import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../domain/expense_model.dart';

/// Screen for recording or editing an expedition trip expense
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.initialExpense});

  final Expense? initialExpense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _noteLocationCtrl = TextEditingController();

  String _selectedCategory = '🛢 Fuel';
  int _trackingModeIndex = 1; // 0=Auto-track, 1=Manual entry (manual default)
  DateTime _expenseDate = DateTime.now();
  late String _dateRecorded;
  String? _selectedBikeId;

  static const List<String> _categoryOptions = [
    '🛢 Fuel',
    '🎫 Permits',
    '⛺ Lodging',
    '🔧 Parts',
    '🛠 Service',
    '🍴 Food',
    '⋯ Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      final exp = widget.initialExpense!;
      _amountCtrl.text = exp.amount.toStringAsFixed(0);
      _noteLocationCtrl.text = exp.subtitle ?? exp.note ?? '';
      _selectedCategory = exp.category.chipLabel;
      _trackingModeIndex =
          exp.trackingMode == ExpenseTrackingMode.autoTrack ? 0 : 1;
      _expenseDate = exp.dateRecorded ?? exp.createdAt ?? DateTime.now();
      _dateRecorded =
          exp.formattedDate ?? _formatDate(_expenseDate);
    } else {
      _dateRecorded = _formatDate(_expenseDate);
    }
    _selectedBikeId = ActiveBikeController.instance.activeBikeId;
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Today, ${months[dt.month - 1]} ${dt.day}';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteLocationCtrl.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final amountText = _amountCtrl.text.trim();
    final amount = parsePkr(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount in PKR'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    ExpenseCategory category = ExpenseCategory.fuel;
    if (_selectedCategory.contains('Permits')) {
      category = ExpenseCategory.permits;
    } else if (_selectedCategory.contains('Lodging')) {
      category = ExpenseCategory.lodging;
    } else if (_selectedCategory.contains('Parts')) {
      category = ExpenseCategory.parts;
    } else if (_selectedCategory.contains('Service')) {
      category = ExpenseCategory.service;
    } else if (_selectedCategory.contains('Food')) {
      category = ExpenseCategory.food;
    } else if (_selectedCategory.contains('Other')) {
      category = ExpenseCategory.other;
    }

    final expense = widget.initialExpense != null
        ? widget.initialExpense!.copyWith(
            category: category,
            title: '${category.displayName} Expense',
            subtitle: _noteLocationCtrl.text.trim().isNotEmpty
                ? _noteLocationCtrl.text.trim()
                : null,
            amount: amount,
            trackingMode: _trackingModeIndex == 0
                ? ExpenseTrackingMode.autoTrack
                : ExpenseTrackingMode.manualEntry,
            formattedDate: _dateRecorded,
            dateRecorded: _expenseDate,
            updatedAt: DateTime.now().toUtc(),
          )
        : Expense(
            id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
            category: category,
            title: '${category.displayName} Expense',
            subtitle: _noteLocationCtrl.text.trim().isNotEmpty
                ? _noteLocationCtrl.text.trim()
                : null,
            amount: amount,
            trackingMode: _trackingModeIndex == 0
                ? ExpenseTrackingMode.autoTrack
                : ExpenseTrackingMode.manualEntry,
            formattedDate: _dateRecorded,
            dateRecorded: _expenseDate,
          );

    Navigator.of(context).pop(expense);
  }

  Widget _buildOversizedAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('AMOUNT', style: AppTextStyles.overline),
            Text('PKR', style: AppTextStyles.overline),
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
                'Rs',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.manrope(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                  cursorColor: AppColors.tacticalOrange,
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.clay,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: AppColors.skeuRaisedSmall,
                ),
                child: Text(
                  'PKR',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        backgroundColor: AppColors.clay,
        appBar: CampAppBar(
          leading: CampAppBarLeading.back,
          actionText: 'Save',
          onActionPressed: _saveExpense,
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
            child: CampCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category Chip Selector ────────────────────────────────
                  Row(
                    children: [
                      Text('CATEGORY', style: AppTextStyles.overline),
                      const SizedBox(width: 4),
                      const Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.tacticalOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MultiSelectChipRow(
                    options: _categoryOptions,
                    selected: {_selectedCategory},
                    onToggle: (opt) {
                      setState(() => _selectedCategory = opt);
                    },
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // ── Amount Input (Oversized) ──────────────────────────────
                  _buildOversizedAmountField(),

                  const SizedBox(height: 18),

                  // ── Note / Location ───────────────────────────────────────
                  LabeledTextField(
                    label: 'NOTE / LOCATION',
                    controller: _noteLocationCtrl,
                    placeholder: 'Optional - e.g. Fuel stop, camp site, pass fee',
                    trailingIcon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 18),

                  // ── Linked Bike (Optional) ─────────────────────────────────
                  if (ActiveBikeController.instance.bikes.isNotEmpty) ...[
                    LabeledDropdown<String?>(
                      label: 'LINKED BIKE (OPTIONAL)',
                      value: _selectedBikeId,
                      items: [
                        null,
                        ...ActiveBikeController.instance.bikes.map((b) => b.id),
                      ],
                      itemLabelBuilder: (id) {
                        if (id == null) return 'General / Trip Expense';
                        final bike =
                            ActiveBikeController.instance.getBikeById(id);
                        return bike != null
                            ? '${bike.make} ${bike.modelName}'
                            : id;
                      },
                      onChanged: (val) => setState(() => _selectedBikeId = val),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── Tracking Mode ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'TRACKING MODE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.overline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'SYNC OPTIONS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.overline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SegmentedControl(
                    options: const ['Auto-track', 'Manual entry'],
                    selectedIndex: _trackingModeIndex,
                    onChanged: (idx) {
                      setState(() => _trackingModeIndex = idx);
                    },
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Manual entries won\'t be affected by auto sync.',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Date Recorded Inset Tile ──────────────────────────────
                  InsetTile(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const IconTile(
                          icon: Icons.calendar_today_rounded,
                          size: 36,
                          iconSize: 18,
                          isInset: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATE RECORDED',
                                style: AppTextStyles.overline.copyWith(
                                  fontSize: 9.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _dateRecorded,
                                style: AppTextStyles.itemTitle.copyWith(
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GhostButton(
                          label: 'Change',
                          color: AppColors.tacticalOrangeDark,
                          onTap: () async {
                            final now = DateTime.now();
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now.subtract(const Duration(days: 365)),
                              lastDate: now.add(const Duration(days: 365)),
                            );
                            if (pickedDate != null && mounted) {
                              setState(() {
                                _dateRecorded =
                                    '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}, 2:45 PM';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Primary Button ────────────────────────────────────────
                  PrimaryButton(
                    label: 'Add Expense',
                    icon: Icons.arrow_forward_rounded,
                    isFullWidth: true,
                    onTap: _saveExpense,
                  ),

                  const SizedBox(height: 10),

                  // ── Cancel Button ─────────────────────────────────────────
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
      ),
    );
  }
}
