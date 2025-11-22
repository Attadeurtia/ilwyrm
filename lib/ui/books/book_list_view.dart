import 'package:flutter/material.dart';

class BookListView extends StatelessWidget {
  final String status;

  const BookListView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Placeholder content
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book, size: 64, color: Theme.of(context).colorScheme.primaryContainer),
          const SizedBox(height: 16),
          Text('Livres: $status', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
