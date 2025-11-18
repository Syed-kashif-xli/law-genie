import 'package:flutter/material.dart';
import 'package:myapp/providers/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:myapp/generated/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  void _onLanguageSelected(String languageCode) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.language, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildLanguageOption(context, 'en', l10n.english),
          _buildLanguageOption(context, 'hi', l10n.hindi),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String languageCode, String languageName) {
    final provider = Provider.of<LocaleProvider>(context);
    final isSelected = provider.locale?.languageCode == languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _onLanguageSelected(languageCode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  languageName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
