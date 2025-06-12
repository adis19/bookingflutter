import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/hotel.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_text_field.dart';
import 'booking_confirmation_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  final Hotel hotel;

  const CreateBookingScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 2));
  int _guests = 2;
  int _time = 19; // Время для бронирования ресторана (по умолчанию 19:00)
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        // Если дата выезда раньше даты заезда, обновляем её
        if (_checkOutDate.isBefore(_checkInDate) || _checkOutDate.isAtSameMomentAs(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }
  
  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate.isAfter(_checkInDate) ? _checkOutDate : _checkInDate.add(const Duration(days: 1)),
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }
  
  // Метод для выбора времени (для ресторанов)
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _time = picked.hour;
      });
    }
  }
  
  Future<void> _createBooking() async {
    if (_formKey.currentState!.validate()) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Преобразуем данные отеля в нужный формат
      final hotelData = {
        'id': widget.hotel.id,
        'place_id': widget.hotel.placeId,
        'name': widget.hotel.name,
        'address': widget.hotel.address,
        'latitude': widget.hotel.latitude,
        'longitude': widget.hotel.longitude,
        'rating': widget.hotel.rating,
        'photos': widget.hotel.photos,
        'created_at': widget.hotel.createdAt.toIso8601String(),
        'place_type': widget.hotel.placeTypeStr,
      };
      
      final success = await bookingProvider.createBooking(
        hotelId: widget.hotel.id.toString(), // Преобразуем id в строку
        checkInDate: widget.hotel.isRestaurant 
            ? DateTime(_checkInDate.year, _checkInDate.month, _checkInDate.day, _time) 
            : _checkInDate,
        checkOutDate: widget.hotel.isRestaurant 
            ? DateTime(_checkInDate.year, _checkInDate.month, _checkInDate.day, _time + 2) // +2 часа для ресторана
            : _checkOutDate,
        guests: _guests,
        notes: _notesController.text.trim(),
        hotelData: hotelData, // Передаем данные отеля
      );
      
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              booking: bookingProvider.selectedBooking!,
            ),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final dateFormat = DateFormat('dd.MM.yyyy');
    final durationDays = _checkOutDate.difference(_checkInDate).inDays;
    final isRestaurant = widget.hotel.isRestaurant;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Бронирование ${isRestaurant ? 'ресторана' : 'отеля'}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Информация о заведении
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hotel.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppConstants.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.hotel.address,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      if (widget.hotel.rating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.hotel.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Заголовок для дат
              Text(
                isRestaurant ? 'Дата и время посещения' : 'Даты бронирования',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Дата заезда/посещения
              InkWell(
                onTap: _selectCheckInDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: isRestaurant ? 'Дата посещения' : 'Дата заезда',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(dateFormat.format(_checkInDate)),
                ),
              ),
              
              // Для ресторанов - выбор времени
              if (isRestaurant) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Время',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    child: Text('${_time.toString().padLeft(2, '0')}:00'),
                  ),
                ),
              ] else ...[
                // Дата выезда только для отелей
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectCheckOutDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Дата выезда',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(dateFormat.format(_checkOutDate)),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Продолжительность пребывания
              Text(
                'Продолжительность: $durationDays ${_getDaysText(durationDays)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Количество гостей
              const Text(
                'Количество гостей',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  IconButton(
                    onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Expanded(
                    child: Text(
                      '$_guests ${_getGuestsText(_guests)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: _guests < 10 ? () => setState(() => _guests++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Примечания
              const Text(
                'Примечания (опционально)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _notesController,
                labelText: 'Особые пожелания',
                prefixIcon: const Icon(Icons.note),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Кнопка создания бронирования
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: bookingProvider.isLoading ? null : _createBooking,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: bookingProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Забронировать',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              // Отображение ошибки
              if (bookingProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    bookingProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppConstants.errorColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getDaysText(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ((days % 10 >= 2 && days % 10 <= 4) && (days % 100 < 10 || days % 100 >= 20)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }
  
  String _getGuestsText(int guests) {
    if (guests % 10 == 1 && guests % 100 != 11) {
      return 'гость';
    } else if ((guests % 10 >= 2 && guests % 10 <= 4) && (guests % 100 < 10 || guests % 100 >= 20)) {
      return 'гостя';
    } else {
      return 'гостей';
    }
  }
}