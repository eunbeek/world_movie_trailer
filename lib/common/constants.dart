// main
const appTitle = "World Movie Trailer";

// Constants for app bar titles
const countryAppBarEn = "World\r\nMovie\r\nTrailers";
const countryAppBarKr = '월드\r\n무비\r\n트레일러';
const countryAppBarJp = 'ワールドムービートレーラー';
const countryAppBarFr = 'Bande-annonces de films du monde'; 
const countryAppBarCn = '世界电影预告片';
const countryAppBarTw = '世界電影預告片';
const countryAppBarDe = 'Weltfilmtrailer';

List<String> countryKeys = ['korea', 'japan', 'canada', 'taiwan', 'france'];

Map<String, Map<String, String>> localizedCountries = {
  'en': {
    'canada': 'Canada',
    'korea': 'South Korea',
    'japan': 'Japan',
    'taiwan': 'Taiwan',
    'france': 'France',
  },
  'ko': {
    'korea': '한국',
    'japan': '일본',
    'canada': '캐나다',
    'taiwan': '대만',
    'france': '프랑스',
  },
  'ja': {
    'japan': '日本',
    'korea': '韓国',
    'canada': 'カナダ',
    'taiwan': '台湾',
    'france': 'フランス',
  },
  'tw': {
    'canada': '加拿大',
    'korea': '韓國',
    'japan': '日本',
    'taiwan': '臺灣',
    'france': '法國',
  },
  'fr': {
    'canada': 'Canada',
    'korea': 'Corée du Sud',
    'japan': 'Japon',
    'taiwan': 'Taïwan',
    'france': 'France',
  },
  'de': {
    'canada': 'Kanada',
    'korea': 'Südkorea',
    'japan': 'Japan',
    'taiwan': 'Taiwan',
    'france': 'Frankreich',
    'germany': 'Deutschland',
  },
};

const kr = 'South Korea';
const jp = 'Japan';
const ca = 'Canada';
const tw = 'Taiwan';
const na = 'North America';
const fr = 'France';
const de = 'Germany';


const special = 'Special';

// ad


// movie list
const listAppBar = "Movies in ";
const listFilterAll = "All";
const listFilterRunning = "Running";
const listFilterUpcoming = "Upcoming";

// country code for read file
