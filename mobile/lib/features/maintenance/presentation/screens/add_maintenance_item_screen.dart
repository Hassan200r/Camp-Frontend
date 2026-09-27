import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/maintenance_item_model.dart';

/// Screen to log or register a new motorcycle maintenance inspection item
class AddMaintenanceItemScreen extends StatefulWidget {
  const AddMaintenanceItemScreen({super.key});

  @override
  State<AddMaintenanceItemScreen> createState() =>
      _AddMaintenanceItemScreenState();
}

class _AddMaintenanceItemScreenState extends State<AddMaintenanceItemScreen> {
  final _nameCtrl = TextEditingController(text: 'Fork Seals & Dust Boots');
  final _dueValueCtrl = TextEditingController(text: '12,500 mi');
  final _notesCtrl = TextEditingController(
    text: 'WP XPLOR 48mm, inspect for seal weeping',
  );

  String _selectedCategory = 'Suspension';
  static const List<String> _categoryOptions = [
    'Suspension',
    'Engine',
    'Brakes',
    'Drivetrain',
    'Tires',
    'Electrical',
    'Other',
  ];

  MaintenanceStatus _selectedStatus = MaintenanceStatus.dueSoon;
  int _dueTypeIndex = 0; // 0=By Mileage, 1=By Date
  int _trackingModeIndex = 1; // 0=Auto Telemetry, 1=Manual Entry (default: Manual)

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dueValueCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveItem() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item name'),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    final newItem = MaintenanceItem(
      id: 'maint-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _selectedCategory,
      status: _selectedStatus,
      trackingMode: _trackingModeIndex == 0
          ? MaintenanceTrackingMode.auto
          : MaintenanceTrackingMode.manual,
      dueMileage: _dueTypeIndex == 0 ? _dueValueCtrl.text.trim() : null,
      dueDate: _dueTypeIndex == 1 ? _dueValueCtrl.text.trim() : null,
      notes: _notesCtrl.text.trim(),
      actionLabel: _selectedStatus == MaintenanceStatus.ok ? null : 'View Guide',
      statusValueDisplay: _selectedStatus == MaintenanceStatus.ok ? 'OK' : '\$65',
      subtitle: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      conditionNote: _selectedStatus == MaintenanceStatus.ok
          ? 'Good • Ready for trail'
          : 'Due soon • ${_dueValueCtrl.text.trim()}',
      icon: _getCategoryIcon(_selectedCategory),
    );

    Navigator.of(context).pop(newItem);
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'brakes':
        return Icons.disc_full_rounded;
      case 'engine':
        return Icons.opacity_rounded;
      case 'drivetrain':
        return Icons.link_rounded;
      case 'tires':
        return Icons.album_rounded;
      case 'suspension':
        return Icons.swap_vert_circle_rounded;
      case 'electrical':
        return Icons.bolt_rounded;
      default:
        return Icons.build_circle_rounded;
    }
  }

  Widget _buildStatusTile({
    required MaintenanceStatus status,
    required String label,
    Color? dotColor,
    IconData? icon,
  }) {
    final bool isSelected = _selectedStatus == status;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.tacticalOrange.withValues(alpha: 0.12)
              : AppColors.clayDark,
          borderRadius: BorderRadius.circular(AppColors.radiusTile),
          border: Border.all(
            color: isSelected
                ? AppColors.tacticalOrange
                : Colors.white.withValues(alpha: 0.45),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? null : AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.tacticalOrangeDark),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.tacticalOrangeDark
                      : AppColors.darkCharcoal,
                ),
              ),
            ),
          ],
        ),
      ),
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
          onActionPressed: _saveItem,
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
                  // ── Item Name ─────────────────────────────────────────────
                  LabeledTextField(
                    label: 'ITEM NAME',
                    controller: _nameCtrl,
                  ),

                  const SizedBox(height: 18),

                  // ── Category Dropdown ─────────────────────────────────────
                  LabeledDropdown<String>(
                    label: 'CATEGORY',
                    value: _selectedCategory,
                    items: _categoryOptions,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  // ── Status 2x2 Fixed Grid ─────────────────────────────────
                  Text('STATUS', style: AppTextStyles.overline),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusTile(
                          status: MaintenanceStatus.ok,
                          label: 'OK',
                          dotColor: AppColors.statusGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatusTile(
                          status: MaintenanceStatus.dueSoon,
                          label: 'Due Soon',
                          dotColor: AppColors.tacticalOrangeDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusTile(
                          status: MaintenanceStatus.overdue,
                          label: 'Overdue',
                          dotColor: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatusTile(
                          status: MaintenanceStatus.diyRec,
                          label: 'DIY-rec',
                          icon: Icons.build_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Due At (Optional) ─────────────────────────────────────
                  Text('DUE AT (OPTIONAL)', style: AppTextStyles.overline),
                  const SizedBox(height: 6),
                  SegmentedControl(
                    options: const ['By Mileage', 'By Date'],
                    selectedIndex: _dueTypeIndex,
                    onChanged: (idx) {
                      setState(() {
                        _dueTypeIndex = idx;
                        if (idx == 0 && _dueValueCtrl.text.isEmpty) {
                          _dueValueCtrl.text = '12,500 mi';
                        } else if (idx == 1 && _dueValueCtrl.text.contains('mi')) {
                          _dueValueCtrl.text = 'Nov 15, 2026';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  LabeledTextField(
                    label: _dueTypeIndex == 0 ? 'ODOMETER DUE' : 'DATE DUE',
                    controller: _dueValueCtrl,
                    trailingIcon: _dueTypeIndex == 0
                        ? Icons.speed_rounded
                        : Icons.calendar_today_rounded,
                  ),

                  const SizedBox(height: 18),

                  // ── Notes (Multiline) ─────────────────────────────────────
                  LabeledTextField(
                    label: 'NOTES (OPTIONAL)',
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 18),

                  // ── Tracking Mode ─────────────────────────────────────────
                  Text('TRACKING MODE', style: AppTextStyles.overline),
                  const SizedBox(height: 6),
                  SegmentedControl(
                    options: const ['Auto Telemetry', 'Manual Entry'],
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
                          'Manual entries won\'t be affected by telemetry sync.',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Primary Button ────────────────────────────────────────
                  PrimaryButton(
                    label: 'Add Item',
                    icon: Icons.arrow_forward_rounded,
                    isFullWidth: true,
                    onTap: _saveItem,
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
