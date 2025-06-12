import 'package:lastbooking/models/hotel.dart';
import 'package:lastbooking/models/user.dart';
import 'package:lastbooking/models/booking.dart';

class AdminStats {
  final int totalUsers;
  final int totalBookings;
  final int totalHotels;
  final double totalRevenue;
  final List<HotelStats> topHotels;
  final List<SearchStats> recentSearches;

  AdminStats({
    required this.totalUsers,
    required this.totalBookings,
    required this.totalHotels,
    required this.totalRevenue,
    required this.topHotels,
    required this.recentSearches,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalHotels: json['total_hotels'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      topHotels: (json['top_hotels'] as List<dynamic>? ?? [])
          .map((hotel) => HotelStats.fromJson(hotel))
          .toList(),
      recentSearches: (json['recent_searches'] as List<dynamic>? ?? [])
          .map((search) => SearchStats.fromJson(search))
          .toList(),
    );
  }

  // Создаем тестовые данные для демонстрации
  factory AdminStats.mock() {
    return AdminStats(
      totalUsers: 42,
      totalBookings: 156,
      totalHotels: 78,
      totalRevenue: 28750.0,
      topHotels: [
        HotelStats(
          hotelId: '1',
          hotelName: 'Grand Plaza Hotel',
          bookingsCount: 24,
          averageRating: 4.8,
          totalRevenue: 8450.0,
        ),
        HotelStats(
          hotelId: '2',
          hotelName: 'Seaside Resort',
          bookingsCount: 18,
          averageRating: 4.5,
          totalRevenue: 6200.0,
        ),
        HotelStats(
          hotelId: '3',
          hotelName: 'Mountain View Lodge',
          bookingsCount: 15,
          averageRating: 4.7,
          totalRevenue: 5100.0,
        ),
      ],
      recentSearches: [
        SearchStats(
          query: 'Москва',
          count: 32,
          lastSearched: DateTime.now().subtract(Duration(hours: 2)),
        ),
        SearchStats(
          query: 'Санкт-Петербург',
          count: 28,
          lastSearched: DateTime.now().subtract(Duration(hours: 5)),
        ),
        SearchStats(
          query: 'Сочи',
          count: 24,
          lastSearched: DateTime.now().subtract(Duration(hours: 8)),
        ),
        SearchStats(
          query: 'Казань',
          count: 18,
          lastSearched: DateTime.now().subtract(Duration(days: 1)),
        ),
        SearchStats(
          query: 'Екатеринбург',
          count: 15,
          lastSearched: DateTime.now().subtract(Duration(days: 2)),
        ),
      ],
    );
  }
}

class HotelStats {
  final String hotelId;
  final String hotelName;
  final int bookingsCount;
  final double averageRating;
  final double totalRevenue;

  HotelStats({
    required this.hotelId,
    required this.hotelName,
    required this.bookingsCount,
    required this.averageRating,
    required this.totalRevenue,
  });

  factory HotelStats.fromJson(Map<String, dynamic> json) {
    return HotelStats(
      hotelId: json['hotel_id'] ?? '',
      hotelName: json['hotel_name'] ?? '',
      bookingsCount: json['bookings_count'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}

class SearchStats {
  final String query;
  final int count;
  final DateTime lastSearched;

  SearchStats({
    required this.query,
    required this.count,
    required this.lastSearched,
  });

  factory SearchStats.fromJson(Map<String, dynamic> json) {
    return SearchStats(
      query: json['query'] ?? '',
      count: json['count'] ?? 0,
      lastSearched: json['last_searched'] != null
          ? DateTime.parse(json['last_searched'])
          : DateTime.now(),
    );
  }
} 