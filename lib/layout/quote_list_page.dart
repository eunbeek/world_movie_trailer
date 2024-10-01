import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';
import 'package:world_movie_trailer/model/quote.dart';
import 'package:world_movie_trailer/common/background.dart';
import 'package:world_movie_trailer/common/quote_service.dart';

class QuoteListPage extends StatefulWidget {
  const QuoteListPage({super.key});

  @override
  _QuoteListPageState createState() => _QuoteListPageState();
}

class _QuoteListPageState extends State<QuoteListPage> {
  List<Quote> filterQuotes = [];
  bool fetchComplete = false;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    try {
      final quotes = await QuoteService.fetchQuote();
      final willShowQuotes = quotes.where((quote) => !quote.isShowed).toList();

      setState(() {
        filterQuotes = willShowQuotes;

        // Marking the first two quotes as shown if they exist
        if (filterQuotes.length > 1) {
          QuoteService.markQuoteAsShown(filterQuotes[0]);
          QuoteService.markQuoteAsShown(filterQuotes[1]);
        }

        fetchComplete = true;
      });

      if (willShowQuotes.length  < 4) {
        // Using Future.forEach to await asynchronous operations
        await Future.forEach(quotes, (quote) async {
          await QuoteService.unmarkQuoteAsShown(quote);
        });
      }
    } catch (e) {
      print('Error fetching quotes: $e');
      setState(() {
        fetchComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageCode = settingsProvider.language;
    // Check if the language is English
    bool isEnglishLike = !['ko', 'ja'].contains(languageCode);
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
                          Navigator.pop(context,);
                        },
                      ),
                      Expanded(
                        child: Text(
                          getSpecialQuoteSource(languageCode),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.height * 0.03),
                    ],
                  ),
                ),

                // Quote Cards Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: fetchComplete
                        ? filterQuotes.isNotEmpty
                            ? Column(
                                children: [
                                  // If the language is English, show two separate quotes
                                  if (isEnglishLike && filterQuotes.length > 1) ...[
                                    Flexible(
                                      child: QuoteCard(
                                        quote: filterQuotes[0],
                                        languageCode: languageCode,
                                        showEnglishOnly: true,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Flexible(
                                      child: QuoteCard(
                                        quote: filterQuotes[1],
                                        languageCode: languageCode,
                                        showEnglishOnly: true,
                                      ),
                                    ),
                                  ],

                                  if (!isEnglishLike && filterQuotes.isNotEmpty) ...[
                                    Flexible(
                                      child: QuoteCard(
                                        quote: filterQuotes[0],
                                        languageCode: languageCode,
                                        showEnglishOnly: true,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                      Flexible(
                                        child: QuoteCard(
                                          quote: filterQuotes[0],
                                          languageCode: languageCode,
                                          showTranslationOnly: true,
                                        ),
                                      ),
                                  ],
                                ],
                              )
                            : const Center(child: Text('No more quotes available.'))
                        : const Center(child: CircularProgressIndicator()),
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
    super.key,
    required this.quote,
    required this.languageCode,
    this.showEnglishOnly = false,
    this.showTranslationOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.grey.shade800,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showEnglishOnly) ...[
              Text(
                quote.quoteEN,
                style: TextStyle(
                  fontSize: quote.quoteEN.length > 30 ? MediaQuery.of(context).size.height * 0.020 :MediaQuery.of(context).size.height * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "- ${quote.movieEN} -",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.017,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (showTranslationOnly) ...[
              Text(
                languageCode == 'ko' ? quote.quoteKR : quote.quoteJP,
                style: TextStyle(
                  fontSize: (languageCode == 'ko' ? quote.quoteKR : quote.quoteJP).length > 30 ? MediaQuery.of(context).size.height * 0.020 :MediaQuery.of(context).size.height * 0.025,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                languageCode == 'ko' ? "- ${quote.movieKR} -" : "- ${quote.movieJP} -",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.017,
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
