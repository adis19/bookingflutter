import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'hotel.g.dart';

// Перечисление для типов заведений
enum PlaceType {
  hotel,
  restaurant,
  unknown
}

@JsonSerializable()
class Hotel extends Equatable {
  final int id;
  @JsonKey(name: 'place_id')
  final String placeId;
  final String name;
  final String address;
  final String? vicinity;
  final double latitude;
  final double longitude;
  final double? rating;
  @JsonKey(name: 'user_ratings_total')
  final int? userRatingsTotal;
  final List<String>? photos;
  final int? priceLevel;
  @JsonKey(name: 'types')
  final List<String>? typesList;
  @JsonKey(name: 'phone_number')
  final String? phoneNumberDirect;
  @JsonKey(name: 'website')
  final String? websiteDirect;
  @JsonKey(name: 'place_type')
  final String? placeTypeString;
  final Map<String, dynamic>? details;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Hotel({
    required this.id,
    required this.placeId,
    required this.name,
    required this.address,
    this.vicinity,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.photos,
    this.priceLevel,
    this.typesList,
    this.phoneNumberDirect,
    this.websiteDirect,
    this.placeTypeString,
    this.details,
    required this.createdAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelToJson(this);

  // Возвращает placeholder из ассетов вместо online placeholder
  String get mainPhotoUrl => photos != null && photos!.isNotEmpty && photos!.first != null
    ? photos!.first 
    : 'assets/images/no_image.png';
    
  // Получение типа заведения
  PlaceType get placeType {
    if (placeTypeString == 'restaurant') {
      return PlaceType.restaurant;
    } else if (placeTypeString == 'hotel') {
      return PlaceType.hotel;
    } else {
      // Пытаемся определить тип по types из details или typesList
      final types = typesList ?? [];
      
      for (final type in types) {
        if (type.toLowerCase() == 'restaurant' || 
            type.toLowerCase() == 'food' ||
            type.toLowerCase() == 'cafe') {
          return PlaceType.restaurant;
        } else if (type.toLowerCase() == 'lodging' || 
                   type.toLowerCase() == 'hotel') {
          return PlaceType.hotel;
        }
      }
      
      // Проверяем details если ничего не нашли
      if (details != null && details!.containsKey('types')) {
        final detailTypes = details!['types'];
        if (detailTypes is List) {
          for (final type in detailTypes) {
            if (type.toString().toLowerCase() == 'restaurant' || 
                type.toString().toLowerCase() == 'food' ||
                type.toString().toLowerCase() == 'cafe') {
              return PlaceType.restaurant;
            } else if (type.toString().toLowerCase() == 'lodging' || 
                       type.toString().toLowerCase() == 'hotel') {
              return PlaceType.hotel;
            }
          }
        }
      }
      return PlaceType.unknown;
    }
  }
  
  // Показывает, является ли заведение рестораном
  bool get isRestaurant => placeType == PlaceType.restaurant;
  
  // Показывает, является ли заведение отелем
  bool get isHotel => placeType == PlaceType.hotel;

  // Геттер для номера телефона
  String? get phoneNumber {
    // First use the direct property if available
    if (phoneNumberDirect != null) {
      return phoneNumberDirect;
    }
    
    // Check in details
    try {
      if (details == null) return null;
      if (!details!.containsKey('phone')) return null;
      if (details!['phone'] == null) return null;
      return details!['phone'].toString();
    } catch (e) {
      print('Error getting phone number: $e');
      return null;
    }
  }
  
  // Геттер для международного номера телефона
  String? get internationalPhoneNumber {
    try {
      if (details == null) return null;
      if (!details!.containsKey('international_phone')) return null;
      if (details!['international_phone'] == null) return null;
      return details!['international_phone'].toString();
    } catch (e) {
      print('Error getting international phone number: $e');
      return null;
    }
  }
  
  // Геттер для веб-сайта
  String? get website {
    // First use the direct property if available
    if (websiteDirect != null) {
      return websiteDirect;
    }
    
    // Check in details
    try {
      if (details == null) return null;
      if (!details!.containsKey('website')) return null;
      if (details!['website'] == null) return null;
      return details!['website'].toString();
    } catch (e) {
      print('Error getting website: $e');
      return null;
    }
  }
  
  // Геттер для URL Google Maps
  String? get googleMapsUrl {
    try {
      if (details == null) return null;
      if (!details!.containsKey('google_maps_url')) return null;
      if (details!['google_maps_url'] == null) return null;
      return details!['google_maps_url'].toString();
    } catch (e) {
      print('Error getting Google Maps URL: $e');
      return null;
    }
  }
  
  // Геттер для иконки
  String? get icon {
    try {
      if (details == null) return null;
      if (!details!.containsKey('icon')) return null;
      if (details!['icon'] == null) return null;
      return details!['icon'].toString();
    } catch (e) {
      print('Error getting icon: $e');
      return null;
    }
  }
  
  // Геттер для цвета фона иконки
  String? get iconBackgroundColor {
    try {
      if (details == null) return null;
      if (!details!.containsKey('icon_background_color')) return null;
      if (details!['icon_background_color'] == null) return null;
      return details!['icon_background_color'].toString();
    } catch (e) {
      print('Error getting icon background color: $e');
      return null;
    }
  }
  
  // Геттер для типов
  List<String>? get types {
    // First use the direct property if available
    if (typesList != null) {
      return typesList;
    }
    
    // Check in details
    try {
      if (details == null) return null;
      if (!details!.containsKey('types')) return null;
      if (details!['types'] == null) return null;
      
      if (details!['types'] is List) {
        return (details!['types'] as List).map((type) => type.toString()).toList();
      }
      
      return null;
    } catch (e) {
      print('Error getting types: $e');
      return null;
    }
  }
  
  // Геттер для отзывов
  List<dynamic>? get reviews {
    try {
      if (details == null) return null;
      if (!details!.containsKey('reviews')) return null;
      if (details!['reviews'] == null) return [];
      
      if (details!['reviews'] is List) {
        print('Reviews found: ${(details!['reviews'] as List).length}');
        return details!['reviews'] as List<dynamic>;
      }
      
      print('Reviews is not a List: ${details!['reviews'].runtimeType}');
      return [];
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  // Геттер для статуса бизнеса
  String? get businessStatus {
    try {
      if (details == null) return null;
      if (!details!.containsKey('business_status')) return null;
      if (details!['business_status'] == null) return null;
      return details!['business_status'].toString();
    } catch (e) {
      print('Error getting business status: $e');
      return null;
    }
  }
  
  // Геттер для редакционного резюме
  String? get editorialSummary {
    try {
      if (details == null) return null;
      if (!details!.containsKey('editorial_summary')) return null;
      if (details!['editorial_summary'] == null) return null;
      return details!['editorial_summary'].toString();
    } catch (e) {
      print('Error getting editorial summary: $e');
      return null;
    }
  }
  
  bool? get wheelchairAccessible {
    try {
      if (details == null) return null;
      if (!details!.containsKey('wheelchair_accessible')) return null;
      if (details!['wheelchair_accessible'] == null) return null;
      
      if (details!['wheelchair_accessible'] is bool) {
        return details!['wheelchair_accessible'] as bool;
      }
      
      if (details!['wheelchair_accessible'] is String) {
        return details!['wheelchair_accessible'].toString().toLowerCase() == 'true';
      }
      
      return null;
    } catch (e) {
      print('Error getting wheelchair accessibility: $e');
      return null;
    }
  }
  
  Map<String, dynamic>? get currentOpeningHours {
    try {
      if (details == null) return null;
      if (!details!.containsKey('current_opening_hours')) return null;
      if (details!['current_opening_hours'] == null) return null;
      
      if (details!['current_opening_hours'] is Map) {
        return details!['current_opening_hours'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print('Error getting current opening hours: $e');
      return null;
    }
  }
  
  List<dynamic>? get addressComponents {
    try {
      if (details == null) return null;
      if (!details!.containsKey('address_components')) return null;
      if (details!['address_components'] == null) return null;
      
      if (details!['address_components'] is List) {
        return details!['address_components'] as List<dynamic>;
      }
      
      return null;
    } catch (e) {
      print('Error getting address components: $e');
      return null;
    }
  }
  
  String? get formattedHtmlAddress {
    try {
      if (details == null) return null;
      if (!details!.containsKey('adr_address')) return null;
      if (details!['adr_address'] == null) return null;
      return details!['adr_address'].toString();
    } catch (e) {
      print('Error getting formatted HTML address: $e');
      return null;
    }
  }
  
  Map<String, dynamic>? get plusCode {
    try {
      if (details == null) return null;
      if (!details!.containsKey('plus_code')) return null;
      if (details!['plus_code'] == null) return null;
      
      if (details!['plus_code'] is Map) {
        return details!['plus_code'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print('Error getting plus code: $e');
      return null;
    }
  }
  
  int? get utcOffset {
    try {
      if (details == null) return null;
      if (!details!.containsKey('utc_offset')) return null;
      if (details!['utc_offset'] == null) return null;
      
      if (details!['utc_offset'] is int) {
        return details!['utc_offset'] as int;
      }
      
      if (details!['utc_offset'] is String) {
        return int.tryParse(details!['utc_offset'] as String);
      }
      
      return null;
    } catch (e) {
      print('Error getting UTC offset: $e');
      return null;
    }
  }

  // Add this getter for backward compatibility
  String? get placeTypeStr => placeTypeString;

  @override
  List<Object?> get props => [
    id, 
    placeId, 
    name, 
    address, 
    latitude, 
    longitude, 
    createdAt
  ];
} 