// main
const appTitle = "World Movie Trailer";

// Constants for app bar titles
const countryAppBarEn = "World Movie Trailers";
const countryAppBarKr = '월드 무비 트레일러';
const countryAppBarJp = 'ワールドムービートレーラー';
const countryAppBarFr = 'Bande-annonces de films du monde'; 
const countryAppBarCn = '世界电影预告片';

List<String> countryKeys = ['korea', 'japan', 'canada'];
Map<String, Map<String, String>> localizedCountries = {
  'en': {
    'canada': 'Canada',
    'korea': 'South Korea',
    'japan': 'Japan',
  },
  'ko': {
    'korea': '한국',
    'japan': '일본',
    'canada': '캐나다',
  },
  'ja': {
    'japan': '日本',
    'korea': '韓国',
    'canada': 'カナダ',
  },
};

const kr = 'South Korea';
const jp = 'Japan';
const na = 'North America';
const fr = 'France';
const ca = 'Canada';

// ad


// movie list
const listAppBar = "Movies in ";
const listFilterAll = "All";
const listFilterRunning = "Running";
const listFilterUpcoming = "Upcoming";

// country code for read file
