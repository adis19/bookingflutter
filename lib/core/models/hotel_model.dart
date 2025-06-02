class HotelModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String address;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final List<String> images;
  final List<String> amenities;
  final String checkInTime;
  final String checkOutTime;
  final bool isAvailable;
  final String roomType;
  final int maxOccupancy;

  HotelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.amenities,
    required this.checkInTime,
    required this.checkOutTime,
    required this.isAvailable,
    required this.roomType,
    required this.maxOccupancy,
  });

  String get formattedPrice => '$price $currency';
  String get fullAddress => '$address, $city, $country';
  String get ratingText => rating > 0 ? '${rating.toStringAsFixed(1)} ★' : 'Нет рейтинга';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'amenities': amenities,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'isAvailable': isAvailable,
      'roomType': roomType,
      'maxOccupancy': maxOccupancy,
    };
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      checkInTime: json['checkInTime'] ?? '14:00',
      checkOutTime: json['checkOutTime'] ?? '12:00',
      isAvailable: json['isAvailable'] ?? true,
      roomType: json['roomType'] ?? '',
      maxOccupancy: json['maxOccupancy'] ?? 2,
    );
  }

  factory HotelModel.fromAmadeusJson(Map<String, dynamic> json) {
    final hotel = json['hotel'] ?? {};
    final offers = json['offers'] as List? ?? [];
    final firstOffer = offers.isNotEmpty ? offers[0] : {};
    final price = firstOffer['price'] ?? {};
    final room = firstOffer['room'] ?? {};
    final guests = firstOffer['guests'] ?? {};

    final address = hotel['address'] ?? {};
    final geoCode = hotel['geoCode'] ?? {};

    final amenitiesList = hotel['amenities'] as List? ?? [];
    final amenities = amenitiesList.map((a) => a.toString()).toList();

    final images = <String>[
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
    ];

    return HotelModel(
      id: hotel['hotelId'] ?? '',
      name: hotel['name'] ?? 'Неизвестный отель',
      description: hotel['description'] ?? '',
      price: double.tryParse(price['total']?.toString() ?? '0') ?? 0,
      currency: price['currency'] ?? 'USD',
      rating: double.tryParse(hotel['rating']?.toString() ?? '0') ?? 0,
      reviewCount: 0,
      address: '${address['lines']?.join(', ') ?? ''}, ${address['postalCode'] ?? ''}',
      city: address['cityName'] ?? '',
      country: address['countryCode'] ?? '',
      latitude: double.tryParse(geoCode['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(geoCode['longitude']?.toString() ?? '0') ?? 0,
      images: images,
      amenities: amenities,
      checkInTime: '14:00',
      checkOutTime: '12:00',
      isAvailable: true,
      roomType: room['typeEstimated']?['category'] ?? 'Standard',
      maxOccupancy: int.tryParse(guests['adults']?.toString() ?? '2') ?? 2,
    );
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? currency,
    double? rating,
    int? reviewCount,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    List<String>? images,
    List<String>? amenities,
    String? checkInTime,
    String? checkOutTime,
    bool? isAvailable,
    String? roomType,
    int? maxOccupancy,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      isAvailable: isAvailable ?? this.isAvailable,
      roomType: roomType ?? this.roomType,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HotelModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HotelModel(id: $id, name: $name, price: $formattedPrice)';
  }
}
