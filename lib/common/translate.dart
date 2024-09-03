import 'package:world_movie_trailer/common/constants.dart';
import 'package:world_movie_trailer/model/movie.dart';

// Setting
String getLanguageName(String languageCode) {
  switch (languageCode) {
    case 'ko':
      return '한국어';
    case 'en':
      return 'English';
    case 'ja':
      return '日本語';
    case 'zh':
      return '简体中文';
    case 'tw':
      return '繁體中文';
    case 'fr':
      return 'Français';
    case 'de':
      return 'Deutsch';
    case 'es':
      return 'Español';
    case 'hi':
      return 'हिन्दी';
    case 'th':
      return 'ไทย';
    default:
      return 'Unknown';
  }
}

// Country list - app bar
String getAppBarTitle(String languageCode) {
  return countryAppBars[languageCode.toUpperCase()] ?? countryAppBars['EN']!;
}

// Country list - special section
String getSpecialLable(Movie specialSection, String languageCode){
   // Fetch the 'Special' label in the desired language, if it exists
  final specialPrefix = specialLabelTranslations['Special']?[languageCode] ?? 'Special';
  
  // Fetch the specific label for the current special, if it exists
  final specialTranslation = specialLabelTranslations[specialSection.special]?[languageCode] ?? specialSection.special;

  return '$specialPrefix - $specialTranslation';
}

String getNameBySpecialSource(Movie specialSection, String languageCode) {
  switch (languageCode) {
    case 'ko':
      return (specialSection.nameKR != null && specialSection.nameKR!.isNotEmpty) 
          ? '${specialSection.source} | ${specialSection.nameKR!}' 
          : specialSection.source;
    case 'ja':
      return (specialSection.nameJP != null && specialSection.nameJP!.isNotEmpty) 
          ? '${specialSection.source} | ${specialSection.nameJP!}' 
          : specialSection.source;
    case 'zh':
      return (specialSection.nameCH != null && specialSection.nameCH!.isNotEmpty) 
          ? '${specialSection.source} | ${specialSection.nameCH!}' 
          : specialSection.source;
    case 'tw':
      return (specialSection.nameTW != null && specialSection.nameTW!.isNotEmpty) 
          ? '${specialSection.source} | ${specialSection.nameTW!}' 
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

// Movie detail - info 
String? getTranslatedDetail(String detailKey, String languageCode) {
  return movieDetailTranslations[detailKey]?[languageCode] ?? movieDetailTranslations[detailKey]?['en'];
}