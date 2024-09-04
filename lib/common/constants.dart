// main
const appTitle = "World Movie Trailer";

// settings_provider
const supportedLanguages = ['en', 'ko', 'ja', 'tw', 'fr', 'de', 'zh', 'es', 'hi', 'th'];

// Constants for app bar titles
const Map<String, String> countryAppBars = {
  'EN': "World\nMovie\nTrailers",  // English
  'KO': '월드\n무비\n트레일러',  // Korean
  'JA': 'ワールド\nムービー\nトレーラー',  // Japanese
  'FR': 'World\nMovie\nTrailers',  // French
  'ZH': '世界\n电影\n预告片',  // Simplified Chinese
  'TW': '世界\n電影\n預告片',  // Traditional Chinese
  'DE': 'Welt\nfilm\ntrailer',  // German
  'ES': 'Tráilers\n de\n películas',  // Spanish
  'HI': 'विश्व\nफिल्म\nट्रेलर',  // Hindi
  'TH': 'โลก\nภาพยนตร์\nตัวอย่าง',  // Thai
};

Map<String, Map<String, String>> localizedCountries = {
  'en': {
    'usa': 'U.S.A',
    'korea': 'South Korea',
    'japan': 'Japan',
    'taiwan': 'Taiwan',
    'china': 'China',
    'france': 'France',
    'germany': 'Germany',
    'spain': 'Spain',
    'india': 'India',
    'canada': 'Canada',
    'australia': 'Australia',
    'thailand': 'Thailand',
  },
  'ko': {
    'korea': '한국',
    'usa': '미국',
    'japan': '일본',
    'taiwan': '대만',
    'china': '중국',
    'france': '프랑스',
    'germany': '독일',
    'spain': '스페인',
    'india': '인도',
    'canada': '캐나다',
    'australia': '호주',
    'thailand': '태국',
  },
  'ja': {
    'japan': '日本',
    'korea': '韓国',
    'usa': 'アメリカ合衆国',
    'taiwan': '台湾',
    'china': '中国',
    'france': 'フランス',
    'germany': 'ドイツ',
    'spain': 'スペイン',
    'india': 'インド',
    'canada': 'カナダ',
    'australia': 'オーストラリア',
    'thailand': 'タイ',
  },
  'tw': {
    'taiwan': '臺灣',
    'china': '中國',
    'korea': '韓國',
    'japan': '日本',
    'usa': '美國',
    'france': '法國',
    'germany': '德國',
    'spain': '西班牙',
    'india': '印度',
    'canada': '加拿大',
    'australia': '澳洲',
    'thailand': '泰國',
  },
  'zh': {
    'china': '中国',
    'taiwan': '台湾',
    'korea': '韩国',
    'japan': '日本',
    'usa': '美国',
    'france': '法国',
    'germany': '德国',
    'spain': '西班牙',
    'india': '印度',
    'canada': '加拿大',
    'australia': '澳大利亚',
    'thailand': '泰国',
  },
  'fr': {
    'france': 'France',
    'usa': 'États-Unis',
    'china': 'Chine',
    'korea': 'Corée du Sud',
    'japan': 'Japon',
    'germany': 'Allemagne',
    'spain': 'Espagne',
    'india': 'Inde',
    'canada': 'Canada',
    'australia': 'Australie',
    'thailand': 'Thaïlande',
  },
  'de': {
    'germany': 'Deutschland',
    'france': 'Frankreich',
    'usa': 'Vereinigte Staaten',
    'china': 'China',
    'korea': 'Südkorea',
    'japan': 'Japan',
    'spain': 'Spanien',
    'india': 'Indien',
    'canada': 'Kanada',
    'australia': 'Australien',
    'thailand': 'Thailand',
  },
  'es': {
    'spain': 'España',
    'germany': 'Alemania',
    'france': 'Francia',
    'usa': 'Estados Unidos',
    'china': 'China',
    'korea': 'Corea del Sur',
    'japan': 'Japón',
    'india': 'India',
    'canada': 'Canadá',
    'australia': 'Australia',
    'thailand': 'Tailandia',
  },
 'hi': {
    'india': 'भारत',
    'korea': 'कोरिया',
    'japan': 'जापान',
    'taiwan': 'ताइवान',
    'usa': 'संयुक्त राज्य अमेरिका',
    'canada': 'कनाडा',
    'france': 'फ्रांस',
    'germany': 'जर्मनी',
    'spain': 'स्पेन',
    'australia': 'ऑस्ट्रेलिया',
    'thailand': 'थाईलैंड',
  },
  'th': {
    'thailand': 'ประเทศไทย',
    'usa': 'สหรัฐอเมริกา',
    'korea': 'เกาหลีใต้',
    'japan': 'ญี่ปุ่น',
    'taiwan': 'ไต้หวัน',
    'canada': 'แคนาดา',
    'france': 'ฝรั่งเศส',
    'germany': 'เยอรมนี',
    'spain': 'สเปน',
    'india': 'อินเดีย',
    'australia': 'ออสเตรเลีย',
  },
};

// Country constants for fetch data from api
const kr = 'korea';
const jp = 'japan';
const ca = 'canada';
const tw = 'taiwan';
const us = 'usa';
const fr = 'france';
const de = 'germany';
const th = 'thailand';
const au = 'australia';
const special = 'special';

// country list
// special section
const specialLabelTranslations = {
  'Directer of the Month': {
    'en': 'Director of the Month',
    'ko': '이달의 감독',
    'ja': '今月の監督',
    'zh': '本月电影导演',
    'tw': '本月電影導演',
    'fr': 'Réalisateur du mois',
    'de': 'Regisseur des Monats',
    'es': 'Director de cine del mes',
    'hi': 'इस महीने का फिल्म निर्देशक',
    'th': 'ผู้กำกับภาพยนตร์ประจำเดือนนี้',
  },
  'Actor of the Month': {
    'en': 'Actor of the Month',
    'ko': '이달의 남자 배우',
    'ja': '今月の男優',
    'zh': '本月男演员',
    'tw': '本月男演員',
    'fr': 'Acteur masculin du mois',
    'de': 'Schauspieler des Monats',
    'es': 'Actor del mes',
    'hi': 'इस महीने का अभिनेता',
    'th': 'นักแสดงชายประจำเดือนนี้',
  },
  'Actress of the Month': {
    'en': 'Actress of the Month',
    'ko': '이달의 여자 배우',
    'ja': '今月の女優',
    'zh': '本月女演员',
    'tw': '本月女演員',
    'fr': 'Actrice du mois',
    'de': 'Schauspielerin des Monats',
    'es': 'Actriz del mes',
    'hi': 'इस महीने की अभिनेत्री',
    'th': 'นักแสดงหญิงประจำเดือนนี้',
  },
  'Movie Quotes': {
    'en': 'Movie Quotes',
    'ko': '영화 속 명대사',
    'ja': '映画の中の名台詞',
    'zh': '电影中的经典台词',
    'tw': '電影中的經典台詞',
    'fr': 'Répliques cultes de films',
    'de': 'Berühmte Filmzitate',
    'es': 'Frases icónicas de películas',
    'hi': 'फ़िल्म के प्रसिद्ध संवाद',
    'th': 'ประโยคเด่นจากภาพยนตร์',
  },
  'Special': {
    'en': 'Special',
    'ko': '특별기획',
    'ja': '特別企画',
    'zh': '特别企划',
    'tw': '特別企劃',
    'fr': 'Projet spécial',
    'de': 'Spezialprojekt',
    'es': 'Proyecto especial',
    'hi': 'विशेष परियोजना',
    'th': 'โครงการพิเศษ',
  }
};

// movie list 
// filter
const listFilterAll = "All";
const listFilterRunning = "Running";
const listFilterUpcoming = "Upcoming";

const labelFilterAll = "All";
const labelFilterRunning = "Now Showing";
const labelFilterUpcoming = "Coming Soon";

const labelFilterAllKR = "모든 예고편";
const labelFilterRunningKR = "상영 중";
const labelFilterUpcomingKR = "개봉 예정";

const labelFilterAllJP = "すべての予告編";
const labelFilterRunningJP = "上映中";
const labelFilterUpcomingJP = "開封予定";

const labelFilterAllZH = "全部预告片";
const labelFilterRunningZH = "上映中";
const labelFilterUpcomingZH = "即将上映";

const labelFilterAllTW = "全部預告片";
const labelFilterRunningTW = "上映中";
const labelFilterUpcomingTW = "即將上映";

const labelFilterAllFR = "Tout";
const labelFilterAllDE = "Alles";
const labelFilterAllES = "Todo";
const labelFilterAllHI = "सब";

const labelFilterAllTH = "全部預告片";
const labelFilterRunningTH = "上映中";
const labelFilterUpcomingTH = "即將上映";

// poster
const labelRelease = "Release";
const labelReleaseKR = "개봉";
const labelReleaseJP = "公開";
const labelReleaseZH = "上映";
const labelReleaseTW = "上映";
const labelReleaseFR = "Sortie";
const labelReleaseES = "Estreno";
const labelReleaseHI = "रिलीज़";
const labelReleaseTH = "เข้าฉาย"; 

// movie detail
// movie info label
const Map<String, Map<String, String>> movieDetailTranslations = {
  'Director': {
    'ko': '감독',
    'ja': '監督',
    'zh': '导演',
    'tw': '導演',
    'fr': 'Réalisateur',
    'de': 'Regisseur',
    'es': 'Director de cine',
    'hi': 'फिल्म निर्देशक',
    'th': 'ผู้กำกับ',
    'en': 'Director',
  },
  'Stars': {
    'ko': '주연',
    'ja': '主演',
    'zh': '主演',
    'tw': '主演',
    'fr': 'Acteur principal',
    'de': 'Hauptdarsteller',
    'es': 'Actor principal',
    'hi': 'मुख्य अभिनेता',
    'th': 'นักแสดงนำ',
    'en': 'Stars',
  },
  'Country': {
    'ko': '국가',
    'ja': '国家',
    'zh': '国家',
    'tw': '國家',
    'fr': 'Pays',
    'de': 'Land',
    'es': 'País',
    'hi': 'देश',
    'th': 'ประเทศ',
    'en': 'Country'
  },
  'Running Time': {
    'ko': '상영시간',
    'ja': '上映時間',
    'zh': '片长',
    'tw': '片長',
    'fr': 'Durée du film',
    'de': 'Filmlänge',
    'es': 'Duración de la película',
    'hi': 'फिल्म की अवधि',
    'th': 'ความยาวของภาพยนตร์',
    'en': 'Running Time',
  },
  'Year': {
    'ko': '공개년도',
    'ja': '公開年',
    'zh': '上映年份',
    'tw': '上映年份',
    'fr': 'Année de sortie',
    'de': 'Erscheinungsjahr',
    'es': 'Año de estreno',
    'hi': 'रिलीज़ का वर्ष',
    'th': 'ปีที่ภาพยนตร์ออกฉาย',
    'en': 'Year',
  },
};
