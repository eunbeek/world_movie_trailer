// main
const appTitle = "World Movie Trailer";

// Constants for app bar titles
const countryAppBarEN = "World\r\nMovie\r\nTrailers";
const countryAppBarKR = '월드\r\n무비\r\n트레일러';
const countryAppBarJP = 'ワールドムービートレーラー';
const countryAppBarFR = 'Bande-annonces de films du monde';
const countryAppBarCN = '世界电影预告片';
const countryAppBarTW = '世界電影預告片';
const countryAppBarDE = 'Welt\r\nfilm\r\ntrailer';

List<String> countryKeys = ['korea', 'japan', 'canada', 'taiwan', 'france', 'germany', 'usa'];

Map<String, Map<String, String>> localizedCountries = {
  'en': {
    'canada': 'Canada',
    'korea': 'South Korea',
    'japan': 'Japan',
    'taiwan': 'Taiwan',
    'france': 'France',
    'germany': 'Germany',
    'usa': 'United States',
  },
  'ko': {
    'korea': '한국',
    'japan': '일본',
    'canada': '캐나다',
    'taiwan': '대만',
    'france': '프랑스',
    'germany': '독일',
    'usa': '미국',
  },
  'ja': {
    'japan': '日本',
    'korea': '韓国',
    'canada': 'カナダ',
    'taiwan': '台湾',
    'france': 'フランス',
    'germany': 'ドイツ',
    'usa': 'アメリカ合衆国',
  },
  'tw': {
    'canada': '加拿大',
    'korea': '韓國',
    'japan': '日本',
    'taiwan': '臺灣',
    'france': '法國',
    'germany': '德國',
    'usa': '美國',
  },
  'zh': {
    'canada': '加拿大',
    'korea': '韓國',
    'japan': '日本',
    'taiwan': '臺灣',
    'france': '法國',
    'germany': '德國',
    'usa': '美國',
  },
  'fr': {
    'canada': 'Canada',
    'korea': 'Corée du Sud',
    'japan': 'Japon',
    'taiwan': 'Taïwan',
    'france': 'France',
    'germany': 'Allemagne',
    'usa': 'États-Unis',
  },
  'de': {
    'canada': 'Kanada',
    'korea': 'Südkorea',
    'japan': 'Japan',
    'taiwan': 'Taiwan',
    'france': 'Frankreich',
    'germany': 'Deutschland',
    'usa': 'Vereinigte Staaten',
  },
};

// Country constants
const kr = 'South Korea';
const jp = 'Japan';
const ca = 'Canada';
const tw = 'Taiwan';
const us = 'United States';
const fr = 'France';
const de = 'Germany';


const special = 'Special';

// ad


// movie list
const listAppBar = "Movies in ";
const specialAppBar = "Movies ";
const listFilterAll = "All";
const listFilterRunning = "Running";
const listFilterUpcoming = "Upcoming";

// country code for read file
