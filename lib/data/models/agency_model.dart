class AgencyModel {
  final String id;
  final String name;
  final String commune;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;

  AgencyModel({
    required this.id,
    required this.name,
    required this.commune,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['id'],
      name: json['name'],
      commune: json['commune'],
      address: json['address'],
      phone: json['phone'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
