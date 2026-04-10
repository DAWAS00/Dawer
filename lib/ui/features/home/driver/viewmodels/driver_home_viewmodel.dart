import 'package:flutter/material.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';

class DriverHomeViewModel extends ChangeNotifier {
  int _currentTab = 0;
  bool _isAvailable = true;
  
  User _user = const User(
    id: 'DRV-19842',
    name: 'سائق دوّر',
    role: 'سائق',
    phone: '+962 79 XXX XXXX',
    rating: 4.8,
  );

  final List<Order> _available = Order.mockAvailableForDriver();
  Order? _active = Order.mockActiveDriverOrder();
  final List<Order> _history = Order.mockDriverHistory();

  int get currentTab => _currentTab;
  bool get isAvailable => _isAvailable;
  User get user => _user;
  List<Order> get available => _available;
  Order? get active => _active;
  List<Order> get history => _history;

  double get totalEarnings {
    double total = 0.0;
    for (final order in _history) {
      if (order.status == OrderStatus.completed) {
        total += order.reward;
      }
    }
    return total;
  }

  int get totalCompletedRides {
    return _history.where((o) => o.status == OrderStatus.completed).length;
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void updateVehicleInfo({
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    String? vehiclePhotoPath,
  }) {
    _user = _user.copyWith(
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      licensePlate: licensePlate,
      vehiclePhotoPath: vehiclePhotoPath,
    );
    notifyListeners();
  }

  String? toggleAvailability(bool value) {
    final hasUnfinished = _active != null || 
        _history.any((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.inTransit);
        
    if (!value && hasUnfinished) {
      return 'لا يمكنك تغيير حالتك إلى غير متاح أثناء وجود طلبات نشطة.';
    }

    _isAvailable = value;
    notifyListeners();
    return null;
  }

  String? acceptOrder(Order order) {
    if (!_isAvailable) {
      return 'أنت غير متاح حالياً. لا يمكنك قبول الطلب.';
    }

    final hasUnfinished = _active != null || 
        _history.any((o) => o.status == OrderStatus.accepted || o.status == OrderStatus.inTransit);

    if (hasUnfinished) {
      return 'لا يمكنك قبول طلب جديد. يرجى توصيل الطلب الحالي أولاً.';
    }

    _available.removeWhere((o) => o.id == order.id);
    
    final acceptedOrder = order.copyWith(
      status: OrderStatus.accepted,
      acceptedAt: DateTime.now(),
      eta: 'جاري الحساب...',
      driverName: _user.name,
      driverPhone: _user.phone,
      driverRating: _user.rating,
      driverVehicleModel: _user.vehicleModel,
      driverVehicleColor: _user.vehicleColor,
      driverLicensePlate: _user.licensePlate,
      driverVehiclePhotoPath: _user.vehiclePhotoPath,
    );

    _history.insert(0, acceptedOrder);
    _currentTab = 1; // Auto-switch to "My Orders" tab
    notifyListeners();
    return null;
  }

  void completeOrder(Order order) {
    final index = _history.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _history[index] = order;
    } else {
      if (_active?.id == order.id) {
        _history.insert(0, order);
        _active = null;
      }
    }
    notifyListeners();
  }
}
