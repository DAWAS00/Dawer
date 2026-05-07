import 'user_role.dart';

class User {
  final String id;
  final String name;
  final UserRole role;
  final String phone;
  final double rating;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? licensePlate;
  final String? vehiclePhotoPath;
  final String? address;
  final int points;
  final int totalOrders;
  final bool isVerified;
  final List<String> categories;

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.phone = '',
    this.rating = 4.8,
    this.vehicleModel,
    this.vehicleColor,
    this.licensePlate,
    this.vehiclePhotoPath,
    this.address,
    this.points = 0,
    this.totalOrders = 0,
    this.isVerified = false,
    this.categories = const [],
  });

  User copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? phone,
    double? rating,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    String? vehiclePhotoPath,
    String? address,
    int? points,
    int? totalOrders,
    bool? isVerified,
    List<String>? categories,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      vehiclePhotoPath: vehiclePhotoPath ?? this.vehiclePhotoPath,
      address: address ?? this.address,
      points: points ?? this.points,
      totalOrders: totalOrders ?? this.totalOrders,
      isVerified: isVerified ?? this.isVerified,
      categories: categories ?? this.categories,
    );
  }
}
