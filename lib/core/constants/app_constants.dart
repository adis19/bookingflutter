class AppConstants {
  // App Info
  static const String appName = 'BookingPro';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String amadeusBaseUrl = 'https://test.api.amadeus.com';
  static const String amadeusApiKey = 'YOUR_AMADEUS_API_KEY';
  static const String amadeusApiSecret = 'YOUR_AMADEUS_API_SECRET';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String bookingsCollection = 'bookings';
  static const String favoritesCollection = 'favorites';
  
  // SharedPreferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userDataKey = 'user_data';
  static const String searchHistoryKey = 'search_history';
  static const String amadeusTokenKey = 'amadeus_token';
  static const String tokenExpiryKey = 'token_expiry';
  
  // Onboarding
  static const int onboardingPagesCount = 3;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxSearchHistoryItems = 10;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 100;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Images
  static const String logoPath = 'assets/images/logo.png';
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
  
  // Error Messages
  static const String networkError = 'Проверьте подключение к интернету';
  static const String serverError = 'Ошибка сервера. Попробуйте позже';
  static const String authError = 'Ошибка авторизации';
  static const String validationError = 'Проверьте введенные данные';
}
