import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/services/in_app_purchase_service.dart';
import 'package:world_movie_trailer/common/translate.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  bool _isLoading = false;
  bool _isRestoreLoading = false;

  void _handlePurchase(BuildContext context) async {
    if (kIsWeb) return;
    LogHelper().logEvent('pay_clicked');
    setState(() {
      _isLoading = true;
    });

    await IapHelper.buyProduct(context);

    setState(() {
      _isLoading = false;
    });
  }

  void _handleRestore(BuildContext context) async {
    if (kIsWeb) return;
    LogHelper().logEvent('restore_clicked');
    setState(() {
      _isRestoreLoading = true;
    });

    await IapHelper.restorePurchase(context);

    setState(() {
      _isRestoreLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _fetchPrice();
  }

  Future<void> _fetchPrice() async {
    setState(() {
      _isLoading = true;
    });

    await IapHelper.fetchProductPrice();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final lang = settingsProvider.language;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: MediaQuery.of(context).size.height * 0.15,
            pinned: true,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(
                  Icons.arrow_back,
                  size: MediaQuery.of(context).size.height * 0.03,
                ),
              ),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 13),
                  centerTitle: true,
                  title: AnimatedOpacity(
                    opacity: top < MediaQuery.of(context).size.height * 0.1
                        ? 1.0
                        : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      getDonationLabel(lang, "donate"),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.bold,
                        color: settingsProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  background: Container(
                    margin: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 15),
                        Image.asset(
                          settingsProvider.isDarkTheme
                              ? 'assets/images/dark/icon_donation_DT_xxhdpi.png'
                              : 'assets/images/light/icon_donation_LT_xxhdpi.png',
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.height * 0.03,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          getDonationLabel(lang, "donate"),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: settingsProvider.isDarkTheme
                        ? const Color(0xff222222)
                        : const Color(0xffffffff),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/deco_donation_xxhdpi.png',
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                width: MediaQuery.of(context).size.height * 0.1,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getDonationLabel(lang, 'donateRemoveAds'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: settingsProvider.isDarkTheme
                                            ? const Color(0xffececec)
                                            : const Color(0xff1a1713),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      getDonationLabel(lang, 'donateDesc'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: settingsProvider.isDarkTheme
                                            ? const Color(0xffececec)
                                            : const Color(0xff1a1713),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6750a4),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                            ),
                            onPressed: settingsProvider.isAdsFree
                                ? null
                                : () => _handlePurchase(context),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    settingsProvider.isAdsFree
                                        ? getDonationLabel(
                                            lang, 'donateComplete')
                                        : '${IapHelper.price} ${IapHelper.currency}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: settingsProvider.isDarkTheme
                            ? Colors.white54
                            : Colors.black54,
                      ),
                      children: [
                        const TextSpan(
                          text: '* ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: getDonationLabel(lang, 'trailerAdNotice')
                              .replaceFirst('* ', ''),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
                    ? (_isRestoreLoading
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : TextButton(
                            onPressed: () => _handleRestore(context),
                            child: Text(
                              getDonationLabel(lang, 'restorePurchase'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: settingsProvider.isDarkTheme
                                    ? const Color(0xffeaddff)
                                    : const Color(0xff6750a4),
                              ),
                            ),
                          ))
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        color: settingsProvider.isDarkTheme
            ? const Color(0xff3c3c3c)
            : const Color(0xff435555),
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.12 * 0.1,
            bottom: MediaQuery.of(context).size.height * 0.12 * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                const url =
                    'https://marmalade-neptune-dbe.notion.site/Home-Page-7589a833b4f6482e90844b9fe49c8ae0';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
              child: Image.asset(
                'assets/images/SIL_logo_h_xxhdpi.png',
                height: MediaQuery.of(context).size.height *
                    0.045, // Adjust size as needed
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.12 * 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    const url =
                        'https://sunnyinnolab.notion.site/Terms-and-Conditions-0601612ffa404317a4ddaf5a094e5471';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    getSettingsLabel(settingsProvider.language, "terms"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.0), // Space around the separator
                  child: Text(
                    '|',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    const url =
                        'https://sunnyinnolab.notion.site/Privacy-Policy-2919720d6e7848669b9d5e1170c6cabc';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    getSettingsLabel(settingsProvider.language, "privacy"),
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.015,
                      color: Colors.white,
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
