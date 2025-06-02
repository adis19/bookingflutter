import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  final String hotelId;
  final String roomId;

  const BookingPage({super.key, required this.hotelId, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Страница бронирования - в разработке'),
      ),
    );
  }
}
