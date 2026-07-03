import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../data/models/hub.dart';
import '../../../../../domain/repositories/i_hub_repository.dart';

/// Shared ViewModel managing active hubs subscription, loading state,
/// and map selection focus across all user home roles.
class HubsViewModel extends ChangeNotifier {
  HubsViewModel(this._repository) {
    subscribeToHubs();
  }

  final IHubRepository _repository;
  StreamSubscription<List<Hub>>? _subscription;

  List<Hub> _hubs = [];
  List<Hub> get hubs => _hubs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Hub? _selectedHub;
  Hub? get selectedHub => _selectedHub;

  void selectHub(Hub? hub) {
    _selectedHub = hub;
    notifyListeners();
  }

  void subscribeToHubs() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchActiveHubs().listen(
      (data) {
        _hubs = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
