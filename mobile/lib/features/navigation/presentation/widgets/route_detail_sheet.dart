import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/roadside_map_models.dart';

class RouteDetailSheet extends StatelessWidget {

  const RouteDetailSheet({
    super.key,
    this.isExpanded = true,
    this.title = 'Cascade Alpine Loop',
    this.userRole = 'driver',
    this.selectedMechanic,
    this.selectedIncident,
    this.selectedSupplyCache,
    this.onStartTurnByTurn,
    this.onBrowseOfflinePacks,
    this.onCompassTap,
    this.onToggleExpand,
    this.onExpand,
    this.onCollapse,
    this.onCall,
    this.onAcceptRescue,
    this.onRequestDispatch,
    this.onClearSelection,
    this.scrollController,
  });
  final bool isExpanded;
  final String title;
  final String userRole; // 'driver' or 'mechanic'
  final RoadsideMechanic? selectedMechanic;
  final StrandedIncident? selectedIncident;
  final RoadsideSupplyCache? selectedSupplyCache;
  final VoidCallback? onStartTurnByTurn;
  final VoidCallback? onBrowseOfflinePacks;
  final VoidCallback? onCompassTap;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final VoidCallback? onCall;
  final VoidCallback? onAcceptRescue;
  final VoidCallback? onRequestDispatch;
  final VoidCallback? onClearSelection;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // 1. Pinned Drag Handle & Header
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleExpand,
            onVerticalDragUpdate: (details) {
              final d = details.primaryDelta;
              if (d != null) {
                if (d < -4) {
                  onExpand?.call();
                } else if (d > 4) {
                  onCollapse?.call();
                }
              }
            },
            onVerticalDragEnd: (details) {
              final v = details.primaryVelocity;
              if (v != null) {
                if (v > 50) {
                  onCollapse?.call();
                } else if (v < -50) {
                  onExpand?.call();
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Notch
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: AppColors.clayDark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildHeaderContent(),
                      ),

                      // Clear selection or Expand/Collapse Toggle Button
                      if (selectedIncident != null ||
                          selectedMechanic != null ||
                          selectedSupplyCache != null)
                        GestureDetector(
                          onTap: onClearSelection,
                          child: Container(
                            width: 38,
                            height: 38,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.clayDark,
                              border: Border.all(
                                color: AppColors.clayDark,
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.mutedText,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                      // Circular Compass / Navigation Button
                      GestureDetector(
                        onTap: () {
                          if (isExpanded) {
                            (onCompassTap ?? onCollapse)?.call();
                          } else {
                            (onCompassTap ?? onExpand)?.call();
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.clay,
                            border: Border.all(
                              color: AppColors.clayDark,
                              width: 1.2,
                            ),
                            boxShadow: AppColors.skeuRaisedSmall,
                          ),
                          child: Center(
                            child: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.navigation_rounded,
                              color: AppColors.tacticalOrangeDark,
                              size: isExpanded ? 24 : 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Peeked hint text when collapsed
                  if (!isExpanded) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: AppColors.tacticalOrange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedIncident != null
                              ? 'Swipe up to review incident & dispatch rescue'
                              : (selectedMechanic != null
                                  ? 'Swipe up for mechanic capabilities & contact'
                                  : 'Swipe up for sector details & rescue dispatch'),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5,
                            color: AppColors.mutedLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ),

          // 2. Expandable Scrollable Content Area
          if (isExpanded)
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: _buildExpandedBody(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    if (selectedIncident != null) {
      final inc = selectedIncident!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inc.severityColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'BREAKDOWN ALERT  •  ${inc.categoryLabel.toUpperCase()}',
                style: AppTextStyles.overline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: inc.severityColor,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${inc.driverName} (${inc.vehicleModel})',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    } else if (selectedMechanic != null) {
      final mech = selectedMechanic!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.statusGreen, size: 14),
              const SizedBox(width: 5),
              Text(
                'CERTIFIED ROADSIDE RESCUER  •  CAMP VERIFIED',
                style: AppTextStyles.overline.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.statusGreen,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            mech.name,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    } else if (selectedSupplyCache != null) {
      final cache = selectedSupplyCache!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROADSIDE DEPOT  •  24/7 EMERGENCY PITSTOP',
            style: AppTextStyles.overline.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.statusYellow,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cache.name,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    } else {
      // Default Sector Route View
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROADSIDE RESCUE CORRIDOR  •  TIER 1 DISPATCH',
            style: AppTextStyles.overline.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.tacticalOrangeDark,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildExpandedBody(BuildContext context) {
    if (selectedIncident != null) {
      return _buildIncidentDetailBody(context, selectedIncident!);
    } else if (selectedMechanic != null) {
      return _buildMechanicDetailBody(context, selectedMechanic!);
    } else if (selectedSupplyCache != null) {
      return _buildSupplyCacheBody(context, selectedSupplyCache!);
    } else {
      return _buildSectorOverviewBody(context);
    }
  }

  /// Stranded Driver Incident View
  Widget _buildIncidentDetailBody(
      BuildContext context, StrandedIncident incident) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metric Row: Distance, ETA, Reported Time
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'DISTANCE',
                value: incident.distance,
                color: AppColors.darkCharcoal,
                icon: Icons.place_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'EST. ARRIVAL',
                value: incident.eta,
                color: incident.severityColor,
                icon: Icons.timer_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'REPORTED',
                value: incident.timeReported,
                color: AppColors.mutedText,
                icon: Icons.access_time_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Incident Description Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.clayDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: incident.severityColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(incident.categoryIcon,
                      color: incident.severityColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'FIELD REPORT & PARTS NEEDED',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                incident.issueDescription,
                style: AppTextStyles.body.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Action Buttons: Call Driver & Accept Rescue Mission
        Row(
          children: [
            // Direct Call Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.clayDark, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: AppColors.clayDark,
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded,
                      color: AppColors.statusGreen, size: 18),
                  label: Text(
                    'Call Driver',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Accept & Dispatch Button
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onAcceptRescue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tacticalOrange,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.navigation_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Dispatch & Route',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Mobile Mechanic / Rescuer Profile View
  Widget _buildMechanicDetailBody(
      BuildContext context, RoadsideMechanic mechanic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metric Row: Distance, ETA, Rating
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'DISTANCE',
                value: mechanic.distance.split(' ').first,
                color: AppColors.darkCharcoal,
                icon: Icons.near_me_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'RESPONSE TIME',
                value: mechanic.eta.split(' ').take(2).join(' '),
                color: AppColors.tacticalOrange,
                icon: Icons.bolt_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'RATING',
                value: '${mechanic.rating} ★',
                color: AppColors.statusYellow,
                icon: Icons.star_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Capabilities Wrap
        Text(
          'ROADSIDE CAPABILITIES & TOOLS ONBOARD',
          style: AppTextStyles.overline.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.mutedText,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mechanic.capabilities.map((cap) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.clayDark, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.statusGreen, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    cap,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoalLight,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        // Action Buttons: Call & Request Rescue
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: AppColors.clayDark, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: AppColors.clayDark,
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded,
                      color: AppColors.statusGreen, size: 18),
                  label: Text(
                    'Direct Call',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRequestDispatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tacticalOrange,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.emergency_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Request Roadside Help',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Supply Cache View
  Widget _buildSupplyCacheBody(
      BuildContext context, RoadsideSupplyCache cache) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FUELS: ${cache.fuelTypes}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'AVAILABLE TOOLS & CACHE:\n• ${cache.availableTools.join('\n• ')}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF78350F),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onStartTurnByTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.navigation_rounded, color: Colors.white),
            label: const Text(
              'Navigate to Depot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Default Sector Overview
  Widget _buildSectorOverviewBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                label: 'RESCUE UNITS',
                value: '3 Online',
                color: AppColors.statusGreen,
                icon: Icons.shield_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'AVG DISPATCH',
                value: '9 mins',
                color: AppColors.tacticalOrange,
                icon: Icons.bolt_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                label: 'EMERGENCY VHF',
                value: 'Ch 4 / 151MHz',
                color: const Color(0xFF2563EB),
                icon: Icons.cell_tower_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Turn-by-Turn GPS Guidance Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onStartTurnByTurn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.navigation_rounded,
                color: Colors.white, size: 20),
            label: const Text(
              'Start Live Roadside GPS Dispatch',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Offline Trail Pack button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onBrowseOfflinePacks,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.clayDark, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: AppColors.clayDark,
            ),
            icon: const Icon(Icons.download_for_offline_rounded,
                color: AppColors.mutedText, size: 18),
            label: Text(
              'Download Sector Offline Distress Cache',
              style: AppTextStyles.body.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clayDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mutedText,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
