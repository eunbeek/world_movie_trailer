// main
const appTitle = "World Movie Trailer";

// Constants for app bar titles
const countryAppBarEn = "World Movie Trailers";
const countryAppBarKr = '월드 무비 트레일러';
const countryAppBarJp = 'ワールドムービートレーラー';
const countryAppBarFr = 'Bande-annonces de films du monde'; 
const countryAppBarCn = '世界电影预告片';

List<String> countryKeys = ['usa', 'uk', 'france', 'korea', 'japan', 'taiwan', 'canada'];
Map<String, Map<String, String>> localizedCountries = {
  'en': {
    'usa': 'U.S.A.',
    'uk': 'U.K.',
    'france': 'France',
    'korea': 'Korea',
    'japan': 'Japan',
    'taiwan': 'Taiwan',
    'canada': 'Canada',
  },
  'ko': {
    'usa': '미국',
    'uk': '영국',
    'france': '프랑스',
    'korea': '한국',
    'japan': '일본',
    'taiwan': '대만',
    'canada': '캐나다',
  },
  'ja': {
    'usa': 'アメリカ',
    'uk': 'イギリス',
    'france': 'フランス',
    'korea': '韓国',
    'japan': '日本',
    'taiwan': '台湾',
    'canada': 'カナダ',
  },
  'fr': {
    'usa': 'États-Unis',
    'uk': 'Royaume-Uni',
    'france': 'France',
    'korea': 'Corée',
    'japan': 'Japon',
    'taiwan': 'Taïwan',
    'canada': 'Canada',
  },
  'cn': {
    'usa': '美国',
    'uk': '英国',
    'france': '法国',
    'korea': '韩国',
    'japan': '日本',
    'taiwan': '台湾',
    'canada': '加拿大',
  },
};

const kr = 'South Korea';
const jp = 'Japan';
const na = 'North America';
const fr = 'France';

// ad


// movie list
const listAppBar = "Movies in ";
const listFilterAll = "All";
const listFilterRunning = "Running";
const listFilterUpcoming = "Upcoming";

// movie detail
const trailerPause = "Pause Trailer";
const trailerContinue = "Watch Trailer";

// movie service
// 1. CGV
const cgv = 'CGV';
const cgvUrlAll = "http://www.cgv.co.kr/movies/?lt=1&ft=0";
const cgvUrlRunning = "http://www.cgv.co.kr/movies/?lt=1&ft=1";
const cgvUrlUpcoming = "http://www.cgv.co.kr/movies/pre-movies.aspx";
const cgvDetailUrl= "http://www.cgv.co.kr/movies/detail-view/trailer.aspx?midx=";

// 2. Lotte
const lotte = 'Lotte';
const lotteUrlAll = "https://www.lottecinema.co.kr/NLCHS/Movie/List?flag=1";
const lotteDetail = "https://www.lottecinema.co.kr/LCWS/Movie/MovieData.aspx";