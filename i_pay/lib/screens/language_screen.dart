import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/languages/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();

    /// ✅ 22 Scheduled Indian Languages
    final Map<String, String> languages = {
      'en': 'English',
      'hi': 'हिंदी',
      'bn': 'বাংলা',
      'te': 'తెలుగు',
      'mr': 'मराठी',
      'ta': 'தமிழ்',
      'ur': 'اردو',
      'gu': 'ગુજરાતી',
      'kn': 'ಕನ್ನಡ',
      'ml': 'മലയാളം',
      'or': 'ଓଡ଼ିଆ',
      'pa': 'ਪੰਜਾਬੀ',
      'as': 'অসমীয়া',
      'ma': 'मैथिली',
      'sa': 'संस्कृतम्',
      'ks': 'کٲشُر',
      'ne': 'नेपाली',
      'sd': 'سنڌي',
      'kok': 'कोंकणी',
      'doi': 'डोगरी',
      'mni': 'মৈতৈলোন্',
      'sat': 'ᱥᱟᱱᱛᱟᱲᱤ',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final code = languages.keys.elementAt(index);
          final name = languages.values.elementAt(index);

          final isSelected =
              provider.locale.languageCode == code;

          return ListTile(
            title: Text(name),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              provider.changeLanguage(code);
              Navigator.pop(context); // optional
            },
          );
        },
      ),
    );
  }
}
