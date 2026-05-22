// ignore_for_file: library_private_types_in_public_api
part of '../new_order_sheet.dart';

extension LocationLogicExt on _NewOrderSheetState {
  Future<void> initLocation() async {
    final loc = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (loc != null) {
      final address = await _locationService.reverseGeocode(loc.lat, loc.lng);
      if (!mounted) return;
      _updateState(() {
        _pickedLat = loc.lat;
        _pickedLng = loc.lng;
        _pickedAddress = address;
      });
    } else {
      _updateState(() {
        _pickedLat = 31.9454;
        _pickedLng = 35.9284;
      });
    }
  }

  Future<void> pickLocation() async {
    final result = await Navigator.push<(double, double)?>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: _pickedLat,
          initialLng: _pickedLng,
        ),
      ),
    );
    if (result != null && mounted) {
      final address =
          await _locationService.reverseGeocode(result.$1, result.$2);
      if (!mounted) return;
      _updateState(() {
        _pickedLat = result.$1;
        _pickedLng = result.$2;
        _pickedAddress = address;
      });
    }
  }

  String get locationLabel {
    if (_pickedAddress != null && _pickedAddress!.isNotEmpty) {
      return _pickedAddress!;
    }
    if (_pickedLat != null && _pickedLng != null) {
      return '${_pickedLat!.toStringAsFixed(4)}, ${_pickedLng!.toStringAsFixed(4)}';
    }
    return context.l10n.newOrderCurrentAddress;
  }
}
