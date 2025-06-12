import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/booking.dart';
import '../home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бронирование подтверждено'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Иконка успеха
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppConstants.successColor,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Заголовок
            const Text(
              'Бронирование успешно создано!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Подзаголовок
            Text(
              'Номер бронирования: ${booking.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppConstants.secondaryTextColor,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Информация о бронировании
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Информация об отеле
                    Text(
                      'Отель',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.hotel?.name ?? 'Неизвестный отель',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppConstants.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(booking.hotel?.address ?? 'Адрес не указан'),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 32),
                    
                    // Даты
                    _buildInfoRow(
                      'Дата заезда',
                      dateFormat.format(booking.checkInDate),
                      Icons.calendar_today,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(
                      'Дата выезда',
                      dateFormat.format(booking.checkOutDate),
                      Icons.calendar_today,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(
                      'Количество гостей',
                      '${booking.guests}',
                      Icons.person,
                    ),
                    
                    if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      
                      _buildInfoRow(
                        'Примечания',
                        booking.notes!,
                        Icons.note,
                      ),
                    ],
                    
                    const Divider(height: 32),
                    
                    // Статус
                    Row(
                      children: [
                        const Text(
                          'Статус:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(booking.status),
                            style: TextStyle(
                              color: _getStatusColor(booking.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Кнопка возврата на главный экран
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Вернуться на главный экран'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Кнопка просмотра всех бронирований
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                      settings: const RouteSettings(name: '/bookings'),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('Мои бронирования'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 6,
          child: Text(
            value,
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает подтверждения';
      case 'confirmed':
        return 'Подтверждено';
      case 'cancelled':
        return 'Отменено';
      default:
        return 'Неизвестно';
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return AppConstants.successColor;
      case 'cancelled':
        return AppConstants.errorColor;
      default:
        return Colors.grey;
    }
  }
} 