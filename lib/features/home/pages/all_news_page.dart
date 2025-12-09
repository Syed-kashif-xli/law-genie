import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/features/home/providers/news_provider.dart';
import 'package:myapp/features/home/widgets/news_card.dart';
import 'package:provider/provider.dart';
import '../widgets/inline_banner_ad_widget.dart';

class AllNewsPage extends StatelessWidget {
  const AllNewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Legal News',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.news.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final itemCount = provider.news.length * 2;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index.isEven) {
                  // News Item
                  final newsIndex = index ~/ 2;
                  if (newsIndex < provider.news.length) {
                    final item = provider.news[newsIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NewsCard(news: item),
                    );
                  }
                  return const SizedBox.shrink(); // Safety fallback
                } else {
                  // Ad Item
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: InlineBannerAdWidget(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
