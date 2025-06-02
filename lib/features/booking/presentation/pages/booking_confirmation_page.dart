import 'package:flutter/material.dart';

class BookingConfirmationPage extends StatelessWidget {
  final String bookingId;

  const BookingConfirmationPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Подтверждение бронирования - в разработке'),
      ),
    );
  }
}
