import 'package:flutter/material.dart';

class HotelDetailPage extends StatelessWidget {
  final String hotelId;

  const HotelDetailPage({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Детали отеля - в разработке'),
      ),
    );
  }
}
