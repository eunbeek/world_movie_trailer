// main
const appTitle = "World Movie Trailer";

// settings_provider
const supportedLanguages = ['en', 'ko', 'ja', 'zh', 'tw', 'fr', 'de', 'es', 'hi', 'th'];

Map<String, Map<String, String>> settingLabel = {
  'ko': {
    'userdata': '사용자 데이터',
    'initdate': '시작일',
    'totalhour': '총 사용 시간',
    'lastusage': '마지막 사용 시간',
    'setting': '설정하기',
    'vibrate': '진동',
    'caption': '자막',
    'language': '언어',
    'theme': '테마',
    'light': '밝게',
    'dark': '어둡게',
    'sns': '트위터',
    'twitter': '트위터',
    'share': '앱 공유하기',
    'other': '다른 앱 보기',
    'review': '리뷰 남기기',
    'version': '앱 버전',
    'privacy': '개인정보처리방침',
    'terms': '서비스 이용약관',
  },
  'en': {
    'userdata': 'User Data',
    'initdate': 'Start Date',
    'totalhour': 'Total Usage Time',
    'lastusage': 'Last Usage Time',
    'setting': 'Settings',
    'vibrate': 'Haptics',
    'caption': 'Caption',
    'language': 'Language',
    'theme': 'Theme',
    'light': 'Light',
    'dark': 'Dark',
    'sns': 'Twitter',
    'twitter': 'Twitter',
    'share': 'Share App',
    'other': 'View Other Apps',
    'review': 'Write a Review',
    'version': 'App Version',
    'privacy': 'Privacy Policy',
    'terms': 'Terms of Service',
  },
  'ja': {
    'userdata': 'ユーザーデータ',
    'initdate': '開始日',
    'totalhour': '総使用時間',
    'lastusage': '最後の使用時間',
    'setting': '設定',
    'vibrate': '振動',
    'caption': 'キャプション',
    'language': '言語',
    'theme': 'テーマ',
    'light': 'ライト',
    'dark': 'ダーク',
    'sns': 'ツイッターリンク',
    'twitter': 'ツイッター',
    'share': 'アプリを共有する',
    'other': '他のアプリを見る',
    'review': 'レビューを残す',
    'version': 'アプリバージョン',
    'privacy': 'プライバシーポリシー',
    'terms': '利用規約',
  },
  'tw': {
    'userdata': '使用者資料',
    'initdate': '開始日期',
    'totalhour': '總使用時間',
    'lastusage': '最後使用時間',
    'setting': '設定',
    'vibrate': '震動',
    'caption': '字幕',
    'language': '語言',
    'theme': '主題',
    'light': '亮色',
    'dark': '深色',
    'sns': 'Twitter連結',
    'twitter': 'Twitter',
    'share': '分享應用',
    'other': '查看其他應用',
    'review': '留下評論',
    'version': '應用版本',
    'privacy': '隱私政策',
    'terms': '服務條款',
  },
  'fr': {
    'userdata': 'Données utilisateur',
    'initdate': 'Date de début',
    'totalhour': 'Temps total d\'utilisation',
    'lastusage': 'Dernière utilisation',
    'setting': 'Paramètres',
    'vibrate': 'Vibration',
    'caption': 'Sous-titres',
    'language': 'Langue',
    'theme': 'Thème',
    'light': 'clair',
    'dark': 'sombre',
    'sns': 'Lien Twitter',
    'twitter': 'Twitter',
    'share': 'Partager l\'application',
    'other': 'Voir d\'autres applis',
    'review': 'Laisser un avis',
    'version': 'Version de l\'application',
    'privacy': 'Politique de confidentialité',
    'terms': 'Conditions d\'utilisation',
  },
  'de': {
    'userdata': 'Nutzerdaten',
    'initdate': 'Startdatum',
    'totalhour': 'Gesamtnutzungszeit',
    'lastusage': 'Letzte Nutzung',
    'setting': 'Einstellungen',
    'vibrate': 'Vibration',
    'caption': 'Untertitel',
    'language': 'Sprache',
    'theme': 'Thema',
    'light': 'Hell',
    'dark': 'Dunkel',
    'sns': 'Twitter-Link',
    'twitter': 'Twitter',
    'share': 'App teilen',
    'other': 'Andere Apps anzeigen',
    'review': 'Bewertung abgeben',
    'version': 'App-Version',
    'privacy': 'Datenschutzrichtlinie',
    'terms': 'Nutzungsbedingungen',
  },
  'zh': {
    'userdata': '用户数据',
    'initdate': '开始日期',
    'totalhour': '总使用时间',
    'lastusage': '最后使用时间',
    'setting': '设置',
    'vibrate': '震动',
    'caption': '字幕',
    'language': '语言',
    'theme': '主题',
    'light': '亮色',
    'dark': '暗黑',
    'sns': 'Twitter链接',
    'twitter': 'Twitter',
    'share': '分享应用',
    'other': '查看其他应用',
    'review': '留下评论',
    'version': '应用版本',
    'privacy': '隐私政策',
    'terms': '服务条款',
  },
  'es': {
    'userdata': 'Datos de usuario',
    'initdate': 'Fecha de inicio',
    'totalhour': 'Tiempo total de uso',
    'lastusage': 'Último uso',
    'setting': 'Configuración',
    'vibrate': 'Vibración',
    'caption': 'Subtítulos',
    'language': 'Idioma',
    'theme': 'Tema',
    'light': 'claro',
    'dark': 'oscuro',
    'sns': 'Enlaces de Twitter',
    'twitter': 'Twitter',
    'share': 'Compartir la app',
    'other': 'Ver otras aplicaciones',
    'review': 'Dejar una reseña',
    'version': 'Versión de la app',
    'privacy': 'Política de privacidad',
    'terms': 'Términos de servicio',
  },
  'hi': {
    'userdata': 'उपयोगकर्ता डेटा',
    'initdate': 'आरंभ तिथि',
    'totalhour': 'कुल उपयोग समय',
    'lastusage': 'अंतिम उपयोग समय',
    'setting': 'सेटिंग्स',
    'vibrate': 'कंपन',
    'caption': 'कैप्शन',
    'language': 'भाषा',
    'theme': 'थीम',
    'light': 'लाइट',
    'dark': 'डार्क',
    'sns': 'ट्विटर लिंक',
    'twitter': 'ट्विटर',
    'share': 'ऐप साझा करें',
    'other': 'अन्य ऐप्स देखें',
    'review': 'समीक्षा छोड़ें',
    'version': 'ऐप संस्करण',
    'privacy': 'गोपनीयता नीति',
    'terms': 'सेवा की शर्तें',
  },
  'th': {
    'userdata': 'ข้อมูลผู้ใช้',
    'initdate': 'วันเริ่มต้น',
    'totalhour': 'เวลาการใช้งานทั้งหมด',
    'lastusage': 'เวลาการใช้งานล่าสุด',
    'setting': 'การตั้งค่า',
    'vibrate': 'การสั่นสะเทือน',
    'caption': 'คำบรรยาย',
    'language': 'ภาษา',
    'theme': 'ธีม',
    'light': 'สว่าง',
    'dark': 'มืด',
    'sns': 'ลิงก์ Twitter',
    'twitter': 'Twitter',
    'share': 'แชร์แอป',
    'other': 'ดูแอปอื่น ๆ',
    'review': 'ฝากรีวิว',
    'version': 'เวอร์ชันแอป',
    'privacy': 'นโยบายความเป็นส่วนตัว',
    'terms': 'เงื่อนไขการให้บริการ',
  },
};


Map<String, Map<String, String>> countryNameByLan = {
  'ko': {
    'ko': '한국어',
    'en': '영어',
    'ja': '일본어',
    'zh': '중국어 간체',
    'tw': '중국어 번체',
    'fr': '프랑스어',
    'de': '독일어',
    'es': '스페인어',
    'hi': '힌디어',
    'th': '태국어',
  },
  'en': {
    'ko': 'Korean',
    'en': 'English',
    'ja': 'Japanese',
    'zh': 'Simplified Chinese',
    'tw': 'Traditional Chinese',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
    'hi': 'Hindi',
    'th': 'Thai',
  },
  'ja': {
    'ko': '韓国語',
    'en': '英語',
    'ja': '日本語',
    'zh': '簡体字中国語',
    'tw': '繁体字中国語',
    'fr': 'フランス語',
    'de': 'ドイツ語',
    'es': 'スペイン語',
    'hi': 'ヒンディー語',
    'th': 'タイ語',
  },
  'zh': {
    'ko': '韩语',
    'en': '英语',
    'ja': '日语',
    'zh': '简体中文',
    'tw': '繁体中文',
    'fr': '法语',
    'de': '德语',
    'es': '西班牙语',
    'hi': '印地语',
    'th': '泰语',
  },
  'tw': {
    'ko': '韓語',
    'en': '英語',
    'ja': '日語',
    'zh': '簡體中文',
    'tw': '繁體中文',
    'fr': '法語',
    'de': '德語',
    'es': '西班牙語',
    'hi': '印地語',
    'th': '泰語',
  },
  'fr': {
    'ko': 'Coréen',
    'en': 'Anglais',
    'ja': 'Japonais',
    'zh': 'Chinois simplifié',
    'tw': 'Chinois traditionnel',
    'fr': 'Français',
    'de': 'Allemand',
    'es': 'Espagnol',
    'hi': 'Hindi',
    'th': 'Thaïlandais',
  },
  'de': {
    'ko': 'Koreanisch',
    'en': 'Englisch',
    'ja': 'Japanisch',
    'zh': 'Vereinfachtes Chinesisch',
    'tw': 'Traditionelles Chinesisch',
    'fr': 'Französisch',
    'de': 'Deutsch',
    'es': 'Spanisch',
    'hi': 'Hindi',
    'th': 'Thailändisch',
  },
  'es': {
    'ko': 'Coreano',
    'en': 'Inglés',
    'ja': 'Japonés',
    'zh': 'Chino simplificado',
    'tw': 'Chino tradicional',
    'fr': 'Francés',
    'de': 'Alemán',
    'es': 'Español',
    'hi': 'Hindi',
    'th': 'Tailandés',
  },
  'hi': {
    'ko': 'कोरियाई',
    'en': 'अंग्रेज़ी',
    'ja': 'जापानी',
    'zh': 'सरलीकृत चीनी',
    'tw': 'परंपरागत चीनी',
    'fr': 'फ़्रेंच',
    'de': 'जर्मन',
    'es': 'स्पैनिश',
    'hi': 'हिन्दी',
    'th': 'थाई',
  },
  'th': {
    'ko': 'เกาหลี',
    'en': 'ภาษาอังกฤษ',
    'ja': 'ญี่ปุ่น',
    'zh': 'จีนตัวย่อ',
    'tw': 'จีนดั้งเดิม',
    'fr': 'ภาษาฝรั่งเศส',
    'de': 'เยอรมัน',
    'es': 'สเปน',
    'hi': 'ภาษาฮินดี',
    'th': 'ภาษาไทย',
  },
};
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
    'usa': 'United States',
    'korea': 'Korea',
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
    'korea': 'Corée',
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
    'korea': 'Korea',
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
    'korea': 'Corea',
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
    'china': 'चीन',
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
    'china': 'จีน',
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
const es = 'spain';
const ind = 'india';
const cn = 'china';
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

// movie error 
const labelNetworkErrorKR = "서버 네트워크가 원활하지 않습니다.\r\n조금있다 다시 시도해 주세요.";
const labelNetworkErrorEN = "The server network is not up.\r\nPlease try again later.";
const labelNetworkErrorJP = "サーバーネットワークが円滑ではありません。\r\n少し後でもう一度お試しください。";
const labelNetworkErrorZH = "服务器网络不畅。\r\n请稍后再试。";
const labelNetworkErrorTW = "伺服器網絡不暢。\r\n請稍後再試。";
const labelNetworkErrorFR = "Le réseau du serveur est instable.\r\nVeuillez réessayer plus tard.";
const labelNetworkErrorDE = "Das Servernetzwerk ist instabil.\r\nBitte versuchen Sie es später noch einmal.";	
const labelNetworkErrorES = "La red del servidor está inestable.\r\nPor favor, inténtelo de nuevo más tarde.";
const labelNetworkErrorHI = "सर्वर नेटवर्क अस्थिर है। कृपया कुछ\r\nसमय बाद पुनः प्रयास करें।";
const labelNetworkErrorTH = "เครือข่ายเซิร์ฟเวอร์ไม่เสถียร\r\nกรุณาลองอีกครั้งในภายหลัง";

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
   'Minute': {
    'ko': '분',
    'ja': '分',
    'zh': '分',
    'tw': '分',
    'fr': 'minutes',
    'de': 'minuten',
    'es': 'minutos',
    'hi': 'मिनट',
    'th': 'นาที',
    'en': 'minutes',
  },
};
