// ignore_for_file: library_private_types_in_public_api
part of '../post_to_market_sheet.dart';

extension LocationLogicExt on _PostToMarketSheetState {
  Future<void> initLocation() async {
    final loc = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (loc != null) {
      final address =
          await _locationService.reverseGeocode(loc.lat, loc.lng);
      if (!mounted) return;
      _updateState(() {
        _pickedLat = loc.lat;
        _pickedLng = loc.lng;
        _pickedAddress = address;
        _isDirty = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.postMarketLocationPermissionDenied)));
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
        _isDirty = true;
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
