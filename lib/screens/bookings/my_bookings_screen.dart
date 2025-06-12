import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _isInitialized = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Проверяем авторизацию перед загрузкой бронирований
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!_isInitialized && authProvider.isAuthenticated) {
      _isInitialized = true;
      // Используем Future.microtask чтобы отложить загрузку данных до завершения сборки виджета
      Future.microtask(() => _loadBookings());
    }
  }

  Future<void> _loadBookings() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    try {
      await bookingProvider.getMyBookings();
      if (mounted && bookingProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${bookingProvider.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить бронирования: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Проверяем, авторизован ли пользователь
    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Мои бронирования',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppConstants.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Требуется авторизация',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Войдите или зарегистрируйтесь,\nчтобы видеть свои бронирования',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Войти',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Мои бронирования',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          // Кнопка обновления списка
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
            tooltip: 'Обновить список',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: bookingProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookingProvider.bookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.hotel_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookingProvider.error != null
                              ? 'Ошибка загрузки бронирований'
                              : 'У вас пока нет бронирований',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (bookingProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                            child: Text(
                              bookingProvider.error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadBookings,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Обновить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookingProvider.bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookingProvider.bookings[index];
                      
                      // Проверяем наличие данных отеля
                      if (booking.hotel == null) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Данные отеля недоступны',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Даты: ${booking.checkInDate.toString().substring(0, 10)} - ${booking.checkOutDate.toString().substring(0, 10)}',
                                  style: GoogleFonts.montserrat(fontSize: 14),
                                ),
                                Text(
                                  'Статус: ${booking.status}',
                                  style: GoogleFonts.montserrat(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        await bookingProvider.cancelBooking(booking.id);
                                      },
                                      child: Text(
                                        'Отменить',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BookingCard(
                          booking: booking,
                          onTap: () {
                            _showBookingDetails(context, booking);
                          },
                          onCancel: booking.status == 'pending' ? () async {
                            final confirmed = await _showCancelConfirmation(context);
                            if (confirmed) {
                              await _cancelBooking(context, booking.id);
                            }
                          } : null,
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<void> _showBookingDetails(BuildContext context, Booking booking) async {
    // Пока экран деталей бронирования не доступен, показываем информацию в снэкбаре
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Просмотр бронирования: ${booking.hotel?.name ?? "Неизвестный отель"}',
          style: GoogleFonts.montserrat(),
        ),
      ),
    );
    
    // FIXME: Раскомментировать после исправления экрана деталей бронирования
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BookingDetailsScreen(booking: booking),
    //   ),
    // );
  }

  Future<bool> _showCancelConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Отменить бронирование',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите отменить это бронирование?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Нет',
              style: GoogleFonts.montserrat(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: Text(
              'Да, отменить',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _cancelBooking(BuildContext context, int bookingId) async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      await bookingProvider.cancelBooking(bookingId);
      
      // Закрываем индикатор загрузки
      Navigator.of(context).pop();
      
      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Бронирование успешно отменено',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Обновляем список бронирований
      await bookingProvider.getMyBookings();
    } catch (e) {
      // Закрываем индикатор загрузки
      Navigator.of(context).pop();
      
      // Показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ошибка при отмене бронирования: $e',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 