import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/booking.dart';
import '../models/favorite.dart';
import '../models/hotel.dart';
// import '../screens/bookings/booking_details_screen.dart'; // Закомментировано до создания файла

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  
  const BookingCard({
    Key? key,
    required this.booking,
    this.onTap,
    this.onCancel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final checkInDate = dateFormat.format(booking.checkInDate);
    final checkOutDate = dateFormat.format(booking.checkOutDate);
    
    // Определение цвета статуса
    Color statusColor;
    switch (booking.status) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.hotel?.name ?? 'Неизвестный отель',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(booking.status),
                      style: GoogleFonts.montserrat(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                booking.hotel?.address ?? 'Адрес не указан',
                style: GoogleFonts.montserrat(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заезд',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkInDate,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Выезд',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          checkOutDate,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Гости',
                          style: GoogleFonts.montserrat(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.guests} чел.',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (booking.totalPrice > 0) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Итого: ',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${booking.totalPrice} сом',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
              // Кнопка отмены для ожидающих бронирований
              if (onCancel != null && booking.status == 'pending') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.cancel),
                    label: Text(
                      'Отменить бронирование',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Подтверждено';
      case 'pending':
        return 'Ожидает';
      case 'cancelled':
        return 'Отменено';
      default:
        return 'Неизвестно';
    }
  }
} 