import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/layout/country_list_page.dart';
import 'package:world_movie_trailer/common/quote_service.dart';

class QuoteListPage extends StatefulWidget {
  final List<Quote> quotes;

  const QuoteListPage({Key? key, required this.quotes}) : super(key: key);

  @override
  _QuoteListPageState createState() => _QuoteListPageState();
}

class _QuoteListPageState extends State<QuoteListPage> {
  late List<Quote> filterQuotes;

  @override
  void initState() {
    super.initState();
    // Filter quotes that have not been shown
    filterQuotes = widget.quotes.where((quote) => !quote.isShowed).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageCode = settingsProvider.language;

    // Check if the language is English
    bool isEnglish = languageCode == 'en';
    QuoteService.markQuoteAsShown(filterQuotes[0]);
    QuoteService.markQuoteAsShown(filterQuotes[1]);
    
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            const BackgroundWidget(isPausePage: false),

            // Main Content
            Column(
              children: [
                // Back Button and Title
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: MediaQuery.of(context).size.height * 0.03,
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const CountryListPage()), // Your CountryListPage route
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                      Expanded(
                        child: Text(
                          getSpecialQuoteSource(languageCode),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center, // Ensure the title text is centered
                        ),
                      ),
                      // Add a Spacer() to balance out the arrow
                      SizedBox(width: MediaQuery.of(context).size.height * 0.03),
                    ],
                  ),
                ),

                // Quote Cards Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // If the language is English, show two separate quotes
                        if (isEnglish && filterQuotes.length > 1) ...[
                          Flexible(
                            child: QuoteCard(
                              quote: filterQuotes[0],
                              languageCode: languageCode,
                              showEnglishOnly: true, // Show only the English part
                            ),
                          ),
                          const SizedBox(height: 16), // Space between cards
                          Flexible(
                            child: QuoteCard(
                              quote: filterQuotes[1], // Second English Quote
                              languageCode: languageCode,
                              showEnglishOnly: true,
                            ),
                          ),
                        ],

                        // If the language is not English, show one quote in English and one in the translated language
                        if (!isEnglish) ...[
                          Flexible(
                            child: QuoteCard(
                              quote: filterQuotes[0],
                              languageCode: languageCode,
                              showEnglishOnly: true, // Show only the English part
                            ),
                          ),
                          const SizedBox(height: 16), // Space between cards
                          Flexible(
                            child: QuoteCard(
                              quote: filterQuotes[0],
                              languageCode: languageCode,
                              showTranslationOnly: true, // Show only the translation part
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final String languageCode;
  final bool showEnglishOnly;
  final bool showTranslationOnly;

  const QuoteCard({
    Key? key,
    required this.quote,
    required this.languageCode,
    this.showEnglishOnly = false,
    this.showTranslationOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show only English Quote
            if (showEnglishOnly) ...[
              Text(
                quote.quoteEN,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "- ${quote.movieEN} -",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Show only Translated Quote
            if (showTranslationOnly) ...[
              Text(
                languageCode == 'ko' ? quote.quoteKR : quote.quoteJP,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                languageCode == 'ko' ? "- ${quote.movieKR} -" : "- ${quote.movieJP} -",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
