import 'package:flutter/material.dart';

/// Status of an offline route pack.
enum RoutePackStatus {
  saved,
  downloading,
  available,
}

/// Action button type on a pack card.
enum RoutePackActionType {
  syncUpdate,
  pause,
  download,
}

/// Data model representing an offline topographic route pack.
class RoutePack {
  const RoutePack({
    required this.id,
    required this.title,
    required this.sizeMb,
    required this.category,
    required this.description,
    required this.status,
    this.statusLabel,
    this.downloadProgress,
    this.downloadedMb,
    this.downloadSpeed,
    this.note,
    this.noteIcon,
    this.actionType = RoutePackActionType.download,
    this.actionLabel,
  });

  final String id;
  final String title;
  final int sizeMb;
  final String category;
  final String description;
  final RoutePackStatus status;
  final String? statusLabel;
  final double? downloadProgress;
  final int? downloadedMb;
  final String? downloadSpeed;
  final String? note;
  final IconData? noteIcon;
  final RoutePackActionType actionType;
  final String? actionLabel;

  /// Default 5 offline telemetry & topo packs per official design specification
  static const List<RoutePack> defaultPacks = [
    // a. Karakoram Highway (KKH)
    RoutePack(
      id: 'kkh',
      title: 'Karakoram Highway (KKH)',
      sizeMb: 840,
      category: 'Full Topo & Satellite',
      description:
          'Complete high-altitude corridor with 3D terrain mesh, satellite imagery, and pass waypoints.',
      status: RoutePackStatus.saved,
      statusLabel: 'Saved',
      note: 'Pack update available (42 MB)',
      noteIcon: Icons.sync_problem_rounded,
      actionType: RoutePackActionType.syncUpdate,
      actionLabel: 'Sync Update',
    ),

    // b. Babusar Pass & Kaghan
    RoutePack(
      id: 'babusar',
      title: 'Babusar Pass & Kaghan',
      sizeMb: 460,
      category: 'Alpine Passes',
      description:
          'Glacial valley ascent, alpine ridge contour lines, and weather sensor calibration nodes.',
      status: RoutePackStatus.downloading,
      statusLabel: '68% DOWNLOADING',
      downloadProgress: 0.68,
      downloadedMb: 312,
      downloadSpeed: '4.2 MB/s',
      actionType: RoutePackActionType.pause,
      actionLabel: 'Pause',
    ),

    // c. Makran Coastal Highway
    RoutePack(
      id: 'makran',
      title: 'Makran Coastal Highway',
      sizeMb: 380,
      category: 'Desert & Coastal Trail',
      description:
          'Coastal highway, mud volcano ridges, and isolated fuel waypoint networks.',
      status: RoutePackStatus.available,
      note: 'Zero-cell desert sector',
      noteIcon: Icons.signal_cellular_off_rounded,
      actionType: RoutePackActionType.download,
      actionLabel: 'Download Pack (380 MB)',
    ),

    // d. Cholistan Desert Rally Route
    RoutePack(
      id: 'cholistan',
      title: 'Cholistan Desert Rally Route',
      sizeMb: 520,
      category: 'Deep Sand & Navigational Grid',
      description:
          'Unmarked dune navigational coordinates, ancient fort beacons, and rally checkpoint grid.',
      status: RoutePackStatus.available,
      note: 'GPS Mesh verified',
      noteIcon: Icons.verified_rounded,
      actionType: RoutePackActionType.download,
      actionLabel: 'Download Pack (520 MB)',
    ),

    // e. Deosai Plains Plateau
    RoutePack(
      id: 'deosai',
      title: 'Deosai Plains Plateau',
      sizeMb: 290,
      category: 'High Altitude Wilderness',
      description:
          'Second-highest plateau in the world, river crossing alerts, and wildlife zone boundaries.',
      status: RoutePackStatus.available,
      note: 'Contour 10m res',
      noteIcon: Icons.layers_outlined,
      actionType: RoutePackActionType.download,
      actionLabel: 'Download Pack (290 MB)',
    ),
  ];
}
