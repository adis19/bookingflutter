import 'package:flutter/material.dart';

class SearchResultsPage extends StatelessWidget {
  final Map<String, dynamic> searchParams;

  const SearchResultsPage({super.key, required this.searchParams});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Результаты поиска - в разработке'),
      ),
    );
  }
}
