import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_card.dart';
import '../../../../core/widgets/inset_tile.dart';
import '../../../../core/widgets/multi_select_chip_row.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../garage/domain/bike_model.dart';
import '../../controllers/post_ride_report_controller.dart';
import '../../domain/post_ride_report.dart';

/// Tab 4 — Post-Ride Debrief form and history log.
/// Saved reports feed the Phase 3 pattern intelligence computation in
/// [DiagnosticsTab]. Uses [PostRideReportController] as the single source
/// of truth.
class PostRideTab extends StatefulWidget {
  const PostRideTab({required this.bike, super.key});

  final Bike bike;

  @override
  State<PostRideTab> createState() => _PostRideTabState();
}

class _PostRideTabState extends State<PostRideTab> {
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  final _flaggedIssuesController = TextEditingController();
  final Set<String> _selectedTerrainTags = {'Off-road', 'Mountain'};

  @override
  void dispose() {
    _distanceController.dispose();
    _notesController.dispose();
    _flaggedIssuesController.dispose();
    super.dispose();
  }

  // ── Save Handler ──────────────────────────────────────────────────────────
  void _savePostRideReport() {
    final distance =
        double.tryParse(_distanceController.text.trim()) ?? 0.0;
    if (distance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid ride distance (km).'),
          backgroundColor: AppColors.tacticalOrangeDark,
        ),
      );
      return;
    }

    final newReport = PostRideReport(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      bikeId: widget.bike.id,
      date: DateTime.now(),
      distanceKm: distance,
      terrainTags: _selectedTerrainTags.toList(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      flaggedIssues: _flaggedIssuesController.text.trim().isNotEmpty
          ? _flaggedIssuesController.text.trim()
          : null,
    );

    PostRideReportController.instance.addReport(newReport);

    // Also advance the bike's odometer and last-updated timestamp.
    final updatedBike = widget.bike.copyWith(
      odometerKm: widget.bike.odometerKm + distance.round(),
      lastUpdated: DateTime.now(),
    );
    ActiveBikeController.instance.updateBike(updatedBike);

    _distanceController.clear();
    _notesController.clear();
    _flaggedIssuesController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Post-ride report saved! Wear models updated.',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.statusGreen,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PostRideReportController.instance,
      builder: (context, _) {
        final reports = PostRideReportController.instance
            .getReportsForBike(widget.bike.id);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form to log a new report
            CampCard(
              padding: const EdgeInsets.all(16),
              borderRadius: AppColors.radiusCard,
              color: AppColors.clay,
              shadows: AppColors.skeuRaised,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        size: 22,
                        color: AppColors.tacticalOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LOG POST-RIDE REPORT',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Logs update real component wear models and terrain pattern insights.',
                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Distance Input
                  Text(
                    'DISTANCE COVERED (KM)',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InsetTile(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    borderRadius: AppColors.radiusTile,
                    child: TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g. 185',
                        hintStyle:
                            GoogleFonts.manrope(color: AppColors.mutedLight),
                        border: InputBorder.none,
                        suffixText: 'km',
                        suffixStyle: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Terrain Multi-Select
                  Text(
                    'RIDING TERRAIN',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MultiSelectChipRow(
                    options: const ['City', 'Highway', 'Off-road', 'Mountain'],
                    selected: _selectedTerrainTags,
                    onToggle: (tag) {
                      setState(() {
                        if (_selectedTerrainTags.contains(tag)) {
                          if (_selectedTerrainTags.length > 1) {
                            _selectedTerrainTags.remove(tag);
                          }
                        } else {
                          _selectedTerrainTags.add(tag);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Observations & Flagged Issues
                  Text(
                    'TRAIL OBSERVATIONS / FLAGGED SYMPTOMS',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.mutedText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InsetTile(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: AppColors.radiusTile,
                    child: TextField(
                      controller: _notesController,
                      maxLines: 2,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkCharcoal,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'e.g. Silt buildup on chain; heavy front braking on descent',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.mutedLight,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save Button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _savePostRideReport,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.clayDark,
                        borderRadius: BorderRadius.circular(AppColors.radiusTile),
                        boxShadow: AppColors.skeuRaisedSmall,
                        border: Border.all(
                          color: AppColors.tacticalOrange.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Save Post-Ride Report',
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tacticalOrangeDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EXPEDITION LOG HISTORY (${reports.length})',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mutedText,
                    letterSpacing: 0.7,
                  ),
                ),
                if (reports.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      PostRideReportController.instance
                          .clearReportsForBike(widget.bike.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Cleared expedition history for active bike.'),
                        ),
                      );
                    },
                    child: Text(
                      'Clear Logs',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedLight,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (reports.isEmpty) ...[
              InsetTile(
                padding: const EdgeInsets.all(24),
                borderRadius: AppColors.radiusTile,
                child: Center(
                  child: Text(
                    'No post-ride reports logged yet.\nSubmit your first debrief above to start tracking patterns.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ] else ...[
              ...reports.map((report) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildReportHistoryItem(report),
                  )),
            ],
          ],
        );
      },
    );
  }

  // ── History Item ──────────────────────────────────────────────────────────
  Widget _buildReportHistoryItem(PostRideReport report) {
    return CampCard(
      padding: const EdgeInsets.all(14),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaisedSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${report.distanceKm.toStringAsFixed(0)} km',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Text(
                _formatRelativeTime(report.date),
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: report.terrainTags.map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.clayDark,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedText,
                  ),
                ),
              );
            }).toList(),
          ),
          if (report.combinedNotes != null &&
              report.combinedNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              report.combinedNotes!,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.darkCharcoal,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
