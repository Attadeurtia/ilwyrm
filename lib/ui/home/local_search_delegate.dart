import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/database.dart';
import '../books/bookshelf_detail_page.dart';

class LocalSearchDelegate extends SearchDelegate<Book?> {
  final WidgetRef ref;

  LocalSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Rechercher un livre...'));
    }

    final database = ref.read(databaseProvider);

    return FutureBuilder<List<Book>>(
      future: database.searchBooks(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final books = snapshot.data ?? [];

        if (books.isEmpty) {
          return const Center(child: Text('Aucun livre trouvé.'));
        }

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: book.coverId != null
                        ? CachedNetworkImageProvider(
                            'https://covers.openlibrary.org/b/id/${book.coverId}-S.jpg',
                          )
                        : book.openlibraryKey != null
                        ? CachedNetworkImageProvider(
                            'https://covers.openlibrary.org/b/olid/${book.openlibraryKey!.split('/').last}-S.jpg',
                          )
                        : const AssetImage('assets/placeholder_book.png')
                              as ImageProvider,
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
              ),
              title: Text(book.title),
              subtitle: Text(book.authorText ?? 'Auteur inconnu'),
              onTap: () {
                close(context, book);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(bookId: book.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
