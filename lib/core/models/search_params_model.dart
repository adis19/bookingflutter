class SearchParamsModel {
  final String destination;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;
  final int rooms;

  SearchParamsModel({
    required this.destination,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    this.children = 0,
    this.rooms = 1,
  });

  int get totalGuests => adults + children;
  int get nights => checkOutDate.difference(checkInDate).inDays;

  String get formattedCheckIn => 
      '${checkInDate.day.toString().padLeft(2, '0')}.${checkInDate.month.toString().padLeft(2, '0')}.${checkInDate.year}';
  
  String get formattedCheckOut => 
      '${checkOutDate.day.toString().padLeft(2, '0')}.${checkOutDate.month.toString().padLeft(2, '0')}.${checkOutDate.year}';

  String get guestsText {
    String result = '$adults взрослых';
    if (children > 0) {
      result += ', $children детей';
    }
    if (rooms > 1) {
      result += ', $rooms номеров';
    } else {
      result += ', $rooms номер';
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'adults': adults,
      'children': children,
      'rooms': rooms,
    };
  }

  factory SearchParamsModel.fromJson(Map<String, dynamic> json) {
    return SearchParamsModel(
      destination: json['destination'] ?? '',
      checkInDate: DateTime.parse(json['checkInDate'] ?? DateTime.now().toIso8601String()),
      checkOutDate: DateTime.parse(json['checkOutDate'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      adults: json['adults'] ?? 1,
      children: json['children'] ?? 0,
      rooms: json['rooms'] ?? 1,
    );
  }

  SearchParamsModel copyWith({
    String? destination,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? adults,
    int? children,
    int? rooms,
  }) {
    return SearchParamsModel(
      destination: destination ?? this.destination,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      rooms: rooms ?? this.rooms,
    );
  }

  bool isValid() {
    return destination.isNotEmpty &&
           checkInDate.isBefore(checkOutDate) &&
           adults > 0 &&
           rooms > 0 &&
           checkInDate.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParamsModel &&
           other.destination == destination &&
           other.checkInDate == checkInDate &&
           other.checkOutDate == checkOutDate &&
           other.adults == adults &&
           other.children == children &&
           other.rooms == rooms;
  }

  @override
  int get hashCode {
    return Object.hash(
      destination,
      checkInDate,
      checkOutDate,
      adults,
      children,
      rooms,
    );
  }

  @override
  String toString() {
    return 'SearchParamsModel(destination: $destination, checkIn: $formattedCheckIn, checkOut: $formattedCheckOut, guests: $guestsText)';
  }
}
