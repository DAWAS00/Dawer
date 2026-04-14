import 'package:flutter/material.dart';
import '../../data/models/order.dart';

class WasteTypeIcons {
  WasteTypeIcons._();

  /// Full list of all 15 waste type / icon pairs.
  /// Single source of truth — used by MarketplaceTab, PostToMarketSheet,
  /// PostJobForm, and any other filter/selector that needs waste-type chips.
  static const List<(WasteType, IconData)> all = [
    (WasteType.paper, Icons.newspaper_rounded),
    (WasteType.plastic, Icons.local_drink_rounded),
    (WasteType.metal, Icons.hardware_rounded),
    (WasteType.glass, Icons.wine_bar_rounded),
    (WasteType.electronics, Icons.devices_rounded),
    (WasteType.organic, Icons.eco_rounded),
    (WasteType.textile, Icons.checkroom_rounded),
    (WasteType.wood, Icons.forest_rounded),
    (WasteType.rubber, Icons.circle_rounded),
    (WasteType.oil, Icons.water_drop_rounded),
    (WasteType.chemicals, Icons.science_rounded),
    (WasteType.batteries, Icons.battery_full_rounded),
    (WasteType.furniture, Icons.chair_rounded),
    (WasteType.tires, Icons.tire_repair_rounded),
    (WasteType.construction, Icons.construction_rounded),
  ];

  /// Returns the icon for a given [WasteType], falling back to
  /// [Icons.recycling_rounded] if no match is found.
  static IconData iconFor(WasteType type) =>
      all.firstWhere((e) => e.$1 == type, orElse: () => (type, Icons.recycling_rounded)).$2;
}
