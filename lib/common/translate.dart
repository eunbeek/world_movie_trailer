import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/model/movie.dart';
import 'package:world_movie_trailer/common/iso3166.dart';

// Setting
String getLanguageName(String languageCode) {
  return countryNameByLan['ko']?[languageCode] ?? 'UnKnown';
}

// setting label
String getSettingsLabel(String languageCode, String field){
  return settingLabel[languageCode.toLowerCase()]?[field] ?? '';
}

// Country list - app bar
String getAppBarTitle(String languageCode) {
  return countryAppBars[languageCode.toUpperCase()] ?? countryAppBars['EN']!;
}

String getAppBarCountry(String languageCode, String country){
  final appbarTitle = countryAppBarNameByCountry[languageCode.toLowerCase()] ?? 'Trailer in ';
  return appbarTitle + country;
}
// Country list - special section
String getSpecialLable(Movie specialSection, String languageCode){
   // Fetch the 'Special' label in the desired language, if it exists
  final specialPrefix = specialLabelTranslations['Special']?[languageCode] ?? 'Special';
  
  // Fetch the specific label for the current special, if it exists
  final specialTranslation = specialLabelTranslations[specialSection.special]?[languageCode] ?? specialSection.special;

  return '$specialPrefix - $specialTranslation';
}

String getMenuItemTitle(String languageCode, String menuItem) {
  return menuTranslations[languageCode]?[menuItem] ?? menuTranslations['en']![menuItem]!;
}

// Country list - special section
String getSpecialQuoteLable(String languageCode){
  final specialPrefix = specialLabelTranslations['Special']?[languageCode] ?? 'Special';

  return specialPrefix;
}

// Country list - special section
String getSpecialQuoteSource(String languageCode){
  final specialSource = movieQuoteTranslations[languageCode] ?? 'Movie Quotes';

  return specialSource;
}

String getNameBySpecialSource(Movie specialSection, String languageCode) {
  switch (languageCode) {
    case 'ko':
      return (specialSection.nameKR != null && specialSection.nameKR!.isNotEmpty) 
          ? specialSection.nameKR!
          : specialSection.source;
    case 'ja':
      return (specialSection.nameJP != null && specialSection.nameJP!.isNotEmpty) 
          ? specialSection.nameJP!
          : specialSection.source;
    case 'zh':
      return (specialSection.nameCH != null && specialSection.nameCH!.isNotEmpty) 
          ? specialSection.nameCH!
          : specialSection.source;
    case 'tw':
      return (specialSection.nameTW != null && specialSection.nameTW!.isNotEmpty) 
          ? specialSection.nameTW!
          : specialSection.source;
    case 'fr':
      return (specialSection.nameFR != null && specialSection.nameFR!.isNotEmpty) 
          ? specialSection.nameFR!
          : specialSection.source;
    case 'de':
      return (specialSection.nameDE != null && specialSection.nameDE!.isNotEmpty) 
          ? specialSection.nameDE!
          : specialSection.source;
    case 'es':
      return (specialSection.nameES != null && specialSection.nameES!.isNotEmpty) 
          ? specialSection.nameES!
          : specialSection.source;
    case 'hi':
      return (specialSection.nameHI != null && specialSection.nameHI!.isNotEmpty) 
          ? specialSection.nameHI!
          : specialSection.source;
    case 'th':
      return (specialSection.nameTH != null && specialSection.nameTH!.isNotEmpty) 
          ? specialSection.nameTH!
          : specialSection.source;
    default:
      return specialSection.source;
  }
}

// Movie list - filter
String getFilterLabel(int index, String languageCode) {
    switch (languageCode) {
      case 'ko':
        return index == 0 ? labelFilterAllKR : index == 1 ? labelFilterRunningKR : labelFilterUpcomingKR;
      case 'ja':
        return index == 0 ? labelFilterAllJP : index == 1 ? labelFilterRunningJP : labelFilterUpcomingJP;
      case 'zh':
        return index == 0 ? labelFilterAllZH : index == 1 ? labelFilterRunningZH : labelFilterUpcomingZH;
      case 'tw':
        return index == 0 ? labelFilterAllTW : index == 1 ? labelFilterRunningTW : labelFilterUpcomingTW;
      case 'fr':
        return index == 0 ? labelFilterAllFR : index == 1 ? labelFilterRunning : labelFilterUpcoming;
      case 'de':
        return index == 0 ? labelFilterAllDE : index == 1 ? labelFilterRunning : labelFilterUpcoming;
      case 'es':
        return index == 0 ? labelFilterAllES : index == 1 ? labelFilterRunning : labelFilterUpcoming;
      case 'hi':
        return index == 0 ? labelFilterAllHI : index == 1 ? labelFilterRunning : labelFilterUpcoming;
      case 'th':
        return index == 0 ? labelFilterAllTH : index == 1 ? labelFilterRunningTH : labelFilterUpcomingTH;
      default:
        return index == 0 ? labelFilterAll : index == 1 ? labelFilterRunning : labelFilterUpcoming;
  }
}

// Movie list - poster release
String getReleaseLabel(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return labelReleaseKR;
      case 'ja':
        return labelReleaseJP;
      case 'zh':
        return labelReleaseZH;
      case 'tw':
        return labelReleaseTW;
      case 'fr':
        return labelReleaseFR;
      case 'de':
        return labelRelease;
      case 'es':
        return labelReleaseES;
      case 'hi':
        return labelReleaseHI;
      case 'th':
        return labelReleaseTH;
      default:
        return labelRelease;
  }
}

// Movie List - Error Message
String getErrorMessage(String languageCode){
    switch (languageCode) {
    case 'ko':
      return labelNetworkErrorKR;
    case 'ja':
      return labelNetworkErrorJP;
    case 'zh':
      return labelNetworkErrorZH;
    case 'tw':
      return labelNetworkErrorTW;
    case 'fr':
      return labelNetworkErrorFR;
    case 'de':
      return labelNetworkErrorDE;
    case 'es':
      return labelNetworkErrorES;
    case 'hi':
      return labelNetworkErrorHI;
    case 'th':
      return labelNetworkErrorTH;
    default:
      return labelNetworkErrorEN;
    }
}

String getErrorByUserMessage(String languageCode) {
  switch (languageCode) {
    case 'ko':
      return labelEmptyErrorKR;
    case 'ja':
      return labelEmptyErrorJP;
    case 'zh':
      return labelEmptyErrorZH;
    case 'tw':
      return labelEmptyErrorTW;
    case 'fr':
      return labelEmptyErrorFR;
    case 'de':
      return labelEmptyErrorDE;
    case 'es':
      return labelEmptyErrorES;
    case 'hi':
      return labelEmptyErrorHI;
    case 'th':
      return labelEmptyErrorTH;
    default:
      return labelEmptyErrorEN;
  }
}

// Movie detail - info 
String? getTranslatedDetail(String detailKey, String languageCode) {
  return movieDetailTranslations[detailKey]?[languageCode] ?? movieDetailTranslations[detailKey]?['en'];
}

String convertCountryCodeToName(String code) {
  return countryCodeToName[code.toUpperCase()] ?? 'Unknown Country';
}