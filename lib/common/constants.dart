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
    'korea': 'Korea',
    'japan': 'Japan',
    'canada': 'Canada',
  },
  'ko': {
    'korea': '한국',
    'japan': '일본',
    'canada': '캐나다',
  },
  'ja': {
    'korea': '韓国',
    'japan': '日本',
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

// 3. Eiga
const eiga = 'Eiga';
const eigaAll = "https://eiga.com/movie/video/";