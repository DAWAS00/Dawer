import 'package:flutter/material.dart';
import '../../data/models/order/order.dart';

class WasteTypeIcons {
  WasteTypeIcons._();

  /// Full list of all 15 waste type / icon pairs.
  /// Single source of truth — used by MarketplaceTab, PostToMarketSheet,
  /// PostJobForm, and any other filter/selector that needs waste-type chips.
  static const List<(WasteType, IconData)> all = [
    (WasteType.paper, Icons.description_outlined),
    (WasteType.plastic, Icons.local_drink_outlined),
    (WasteType.metal, Icons.handyman_outlined),
    (WasteType.glass, Icons.wine_bar_outlined),
    (WasteType.electronics, Icons.devices_outlined),
    (WasteType.organic, Icons.eco_outlined),
    (WasteType.textile, Icons.checkroom_outlined),
    (WasteType.wood, Icons.forest_outlined),
    (WasteType.rubber, Icons.circle_outlined),
    (WasteType.oil, Icons.opacity_outlined),
    (WasteType.chemicals, Icons.science_outlined),
    (WasteType.batteries, Icons.battery_full_outlined),
    (WasteType.furniture, Icons.chair_outlined),
    (WasteType.tires, Icons.directions_car_outlined),
    (WasteType.construction, Icons.construction_outlined),
  ];

  /// Returns the icon for a given [WasteType], falling back to
  /// [Icons.recycling_rounded] if no match is found.
  static IconData iconFor(WasteType type) =>
      all.firstWhere((e) => e.$1 == type, orElse: () => (type, Icons.recycling_rounded)).$2;
}
