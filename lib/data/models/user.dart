class User {
  final String id;
  final String name;
  final String role; // Recycling Co., Supplier, Driver
  final String phone;
  final double rating;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? licensePlate;
  final String? vehiclePhotoPath;

  const User({
    required this.id,
    required this.name,
    required this.role,
    this.phone = '+962 79 XXX XXXX',
    this.rating = 4.8,
    this.vehicleModel,
    this.vehicleColor,
    this.licensePlate,
    this.vehiclePhotoPath,
  });

  User copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    double? rating,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    String? vehiclePhotoPath,
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
    );
  }
}
