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
const cgvUrlRunning = "http://www.cgv.co.kr/movies/?lt=1&ft=1";
const cgvUrlUpcoming = "http://www.cgv.co.kr/movies/pre-movies.aspx";
const cgvMoreMoviesUrl = 'https://www.cgv.co.kr/common/ajax/movies.aspx/GetMovieMoreList?listType=1&orderType=1&filterType=1';
const cgvMoreMovieHeader = {
  'Accept': 'application/json, text/javascript, */*; q=0.01',
  'Accept-Encoding': 'gzip, deflate',
  'Accept-Language': 'en-US,en;q=0.9,ko-KR;q=0.8,ko;q=0.7',
  'Connection': 'keep-alive',
  'Content-Type': 'application/json; charset=utf-8',
  'Cookie': 'WMONID=m2dYIwp3Hq4; ASP.NET_SessionId=d41zufvgs1zsahhg5mgezzkk; _gid=GA1.3.879393538.1722906072; _gat_UA-47951671-5=1; _gat_UA-47951671-7=1; _gat_UA-47126437-1=1; _ga=GA1.1.751750923.1721764985; _ga_559DE9WSKZ=GS1.1.1722923467.20.1.1722924740.59.0.0; _ga_SSGE1ZCJKG=GS1.3.1722923467.19.1.1722924740.60.0.0; CgvCM=/hfGwkGBckJLA6p9h4O6bwil8ivmHcSVIM8qwv53RUUnQP0IbPiumdGqqKWKyP2bJLztcIaFVyl/NwNv/9RQksgfP8Avamf/qk0lwToSzaOTc4UBlE9l4CyV8z8xwcVbBrK/VD/tw+Xcqxz6FwruP6CXxpXTMnpFPfYGkWjP1M8PcZdR3BS26T9lTInH7N4s+ZG/bQhSgXF2e/EV6Ui30moEoF9Pq1skZKm14BIx0ahrW9SlqHP5lsFbJHkxITDf',
  'Host': 'www.cgv.co.kr',
  'Referer': 'http://www.cgv.co.kr/movies/',
  'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36',
  'X-Requested-With': 'XMLHttpRequest',
};
const cgvDetailUrl= "http://www.cgv.co.kr/movies/detail-view/trailer.aspx?midx=";

// 2. Lotte
const lotte = 'Lotte';
const lotteUrlAll = "https://www.lottecinema.co.kr/NLCHS/Movie/List?flag=1";
const lotteDetail = "https://www.lottecinema.co.kr/LCWS/Movie/MovieData.aspx";