// main
const appTitle = "World Movie Trailer";

// country list
const countryAppBar = "World Movie Trailers";
List<String> countries = ['South Korea', 'Japan', 'North America', 'France'];
const kr = 'South Korea';
const jp = 'Japan';
const na = 'North America';
const fr = 'France';

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
const lotteUrlRunning = "https://www.lottecinema.co.kr/NLCHS/Movie/List?flag=5";
const lotteUrlUpcoming = "http://www.cgv.co.kr/movies/pre-movies.aspx";