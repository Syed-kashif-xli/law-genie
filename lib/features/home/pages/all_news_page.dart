import 'package:flutter/material.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:myapp/features/home/widgets/news_card.dart';
import 'package:provider/provider.dart';

class AllNewsPage extends StatelessWidget {
  const AllNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal News'),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.news.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.news.length,
            itemBuilder: (context, index) {
              final item = provider.news[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: NewsCard(news: item),
              );
            },
          );
        },
      ),
    );
  }
}
