// main
const appTitle = "World Movie Trailer";

// settings_provider
const supportedLanguages = ['en', 'ko', 'ja', 'zh', 'tw', 'fr', 'de', 'es', 'hi', 'th'];

const adLimitNum = 30;

Map<String, Map<String, String>> otherAppName = {
  'Find Four': {
    'en': 'Find Four',
    'ko': '파인드 포',
    'ja': 'ファインドフォー',
    'zh': 'Find Four', // 중국어 간체
    'tw': 'Find Four', // 중국어 번체
    'fr': 'Find Four',
    'de': 'Find Four',
    'es': 'Find Four',
    'hi': 'Find Four',
    'th': 'Find Four',
  },
  'English Wangza': {
    'en': 'English Wangza',
    'ko': '영어 왕자',
    'ja': '英語の王子様',
    'zh': '英语王子',
    'tw': '英語王子',
    'fr': 'English Wangza',
    'de': 'English Wangza',
    'es': 'English Wangza',
    'hi': 'English Wangza',
    'th': 'English Wangza',
  },
  'Dual Flashlight': {
    'en': 'Dual Flashlight',
    'ko': '듀얼 플래시라이트',
    'ja': 'デュアルフラッシュライト',
    'zh': 'Dual Flashlight',
    'tw': 'Dual Flashlight',
    'fr': 'Dual Flashlight',
    'de': 'Dual Flashlight',
    'es': 'Dual Flashlight',
    'hi': 'Dual Flashlight',
    'th': 'Dual Flashlight',
  },
  'Sky Peacemaker': {
    'en': 'Sky Peacemaker',
    'ko': '스카이 피스메이커',
    'ja': 'スカイピースメーカー',
    'zh': 'Sky Peacemaker',
    'tw': 'Sky Peacemaker',
    'fr': 'Sky Peacemaker',
    'de': 'Sky Peacemaker',
    'es': 'Sky Peacemaker',
    'hi': 'Sky Peacemaker',
    'th': 'Sky Peacemaker',
  }
};

Map<String, Map<String, String>> alarmLabel = {
  'ko': {
    'alarmAll': '알림 허용',
    'title': '월드 무비 트레일러 업데이트:',
    'country': 'AAA의 새로운 영화를 확인하세요!',
    'bookmark': '북마크한 영화',
    'memo': '메모한 영화',
    'release': '가 내일 개봉합니다!',
  },
  'en': {
    'alarmAll': 'Allow Notification',
    'title': 'World Movie Trailer Update:',
    'country': 'Check out the new movies in AAA!',
    'bookmark': 'The bookmarked movie',
    'memo': 'The noted movie',
    'release': 'is releasing tomorrow!',
  },
  'ja': {
    'alarmAll': '通知を許可',
    'title': 'ワールドムービートレーラー更新:',
    'country': 'AAAの新しい映画をチェックしよう！',
    'bookmark': 'お気に入りにした映画',
    'memo': 'メモした映画',
    'release': 'が明日公開します！',
  },
  'zh': {
    'alarmAll': '允许通知',
    'title': '世界电影预告片更新:',
    'country': '快来看看AAA的新电影！',
    'bookmark': '收藏的电影',
    'memo': '记录的电影',
    'release': '明天上映！',
  },
  'tw': {
    'alarmAll': '允許通知',
    'title': '世界電影預告片更新:',
    'country': '快來看看AAA的新電影！',
    'bookmark': '收藏的電影',
    'memo': '記錄的電影',
    'release': '明天上映！',
  },
  'fr': {
    'alarmAll': 'Autoriser les notifications',
    'title': 'Mise à jour de World Movie Trailer:',
    'country': 'Découvrez les nouveaux films - AAA',
    'bookmark': 'Le film que vous avez mis en favori',
    'memo': 'Le film que vous avez noté',
    'release': 'sort demain !',
  },
  'de': {
    'alarmAll': 'Benachrichtigungen erlauben',
    'title': 'World Movie Trailer Update:',
    'country': 'Schauen Sie sich die neuen Filme in AAA an!',
    'bookmark': 'Der markierte Film',
    'memo': 'Der notierte Film',
    'release': 'wird morgen veröffentlicht!',
  },
  'es': {
    'alarmAll': 'Permitir notificaciones',
    'title': 'Actualización de World Movie Trailer:',
    'country': '¡Descubre las nuevas películas en AAA!',
    'bookmark': 'La película que marcaste',
    'memo': 'La película que anotaste',
    'release': 'se estrena mañana!',
  },
  'hi': {
    'alarmAll': 'नोटिफिकेशन की अनुमति दें',
    'title': 'वर्ल्ड मूवी ट्रेलर अपडेट:',
    'country': 'AAA की नई फिल्मों को देखें!',
    'bookmark': 'बुकमार्क की गई फिल्म',
    'memo': 'नोट की गई फिल्म',
    'release': 'कल रिलीज हो रही है!',
  },
  'th': {
    'alarmAll': 'อนุญาตการแจ้งเตือน',
    'title': 'อัปเดต ตัวอย่างหนังทั่วโลก:',
    'country': 'เช็กรายชื่อภาพยนตร์ใหม่ในAAA!',
    'bookmark': 'ภาพยนตร์ที่คุณทำเครื่องหมายไว้',
    'memo': 'ภาพยนตร์ที่คุณบันทึกไว้',
    'release': 'จะเข้าฉายพรุ่งนี้!',
  },
};

Map<String, Map<String, String>> settingLabel = {
  'ko': {
    'userdata': '사용자 데이터',
    'initdate': '시작일',
    'totalhour': '총 사용 시간',
    'lastusage': '마지막 사용 시간',
    'setting': '설정하기',
    'vibrate': '진동',
    'alarm': '알림',
    'caption': '자막',
    'language': '언어',
    'theme': '테마',
    'light': '밝게',
    'dark': '어둡게',
    'instagram': '인스타그램',
    'sns': '트위터',
    'twitter': '트위터',
    'share': '앱 공유하기',
    'other': '써니의 게임과 앱',
    'review': '리뷰 남기기',
    'version': '앱 버전',
    'privacy': '개인정보처리방침',
    'terms': '서비스 이용약관',
    'totalOpen': '예고편 본 총 횟수',
    'views': '회',
    'credits': '크레딧',
    'opensource': '오픈 소스 정보',
  },
  'en': {
    'userdata': 'User Data',
    'initdate': 'Start Date',
    'totalhour': 'Total Usage Time',
    'lastusage': 'Last Usage Time',
    'setting': 'Settings',
    'vibrate': 'Haptics',
    'alarm': 'Notification', 
    'caption': 'Caption',
    'language': 'Language',
    'theme': 'Theme',
    'light': 'Light',
    'dark': 'Dark',
    'instagram': 'Instagram',
    'sns': 'X (Twitter)',
    'twitter': 'X (Twitter)',
    'share': 'Share the App',
    'other': 'Sunny\'s Games and Apps',
    'review': 'Write a Review',
    'version': 'App Version',
    'privacy': 'Privacy Policy',
    'terms': 'Terms of Service',
    'totalOpen': 'Total Trailer Views',
    'views': 'views',
    'credits': 'Credits',
    'opensource': 'Open Source Info',
  },
  'ja': {
    'userdata': 'ユーザーデータ',
    'initdate': '開始日',
    'totalhour': '総利用時間',
    'lastusage': '最後の使用時間',
    'setting': '設定',
    'vibrate': '振動',
    'alarm': '通知',
    'caption': 'キャプション',
    'language': '言語',
    'theme': 'テーマ',
    'light': 'ライト',
    'dark': 'ダーク',
    'instagram': 'インスタグラム',
    'sns': 'ツイッター',
    'twitter': 'ツイッター',
    'share': 'このアプリを共有する',
    'other': 'Sunnyのゲームとアプリ',
    'review': 'レビューを残す',
    'version': 'バージョン',
    'privacy': 'プライバシーポリシー',
    'terms': '利用規約',
    'totalOpen': '予告編の視聴回数',
    'views': '回',
    'credits': 'エンドロール',
    'opensource': 'オープンソース情報'
  },
  'tw': {
    'userdata': '使用者資料',
    'initdate': '開始日期',
    'totalhour': '總使用時間',
    'lastusage': '最後使用時間',
    'setting': '設定',
    'vibrate': '震動',
    'alarm': '通知',
    'caption': '字幕',
    'language': '語言',
    'theme': '主題',
    'light': '亮色',
    'dark': '深色',
    'instagram': 'Instagram',
    'sns': 'X （推特）',
    'twitter': 'X （推特）',
    'share': '分享應用程式',
    'other': 'Sunny的遊戲和應用',
    'review': '留下評論',
    'version': '應用程式版本',
    'privacy': '隱私政策',
    'terms': '服務條款',
    'totalOpen': '預告片的總觀看次數',
    'views': '次',
    'credits': '製作人員名單',
    'opensource': '開源資訊',
  },
  'zh': {
    'userdata': '应用版本',
    'initdate': '开始日期',
    'totalhour': '总使用时间',
    'lastusage': '最后使用时间',
    'setting': '设置',
    'vibrate': '震动',
    'alarm': '通知',
    'caption': '字幕',
    'language': '语言',
    'theme': '主题',
    'light': '亮色',
    'dark': '暗黑',
    'instagram': 'Instagram',
    'sns': 'X （推特）',
    'twitter': 'X （推特）',
    'share': '分享应用',
    'other': 'Sunny的游戏和应用',
    'review': '留下评论',
    'version': '应用版本',
    'privacy': '隐私政策',
    'terms': '服务条款',
    'totalOpen': '总预告片观看次数',
    'views': '次',
    'credits': '制作人员名单',
    'opensource': '开源信息'
  },
  'fr': {
    'userdata': 'Données utilisateur',
    'initdate': 'Date de début',
    'totalhour': 'Temps total d\'utilisation',
    'lastusage': 'Dernière utilisation',
    'setting': 'Paramètres',
    'vibrate': 'Vibration',
    'alarm': 'Notification',
    'caption': 'Sous-titres',
    'language': 'Langue',
    'theme': 'Thème',
    'light': 'clair',
    'dark': 'sombre',
    'instagram': 'Instagram',
    'sns': 'X (Twitter)',
    'twitter': 'X (Twitter)',
    'share': 'Partager l\'application',
    'other': 'Les jeux et applications de Sunny',
    'review': 'Laisser un avis',
    'version': 'Version de l\'application',
    'privacy': 'Politique de confidentialité',
    'terms': 'Conditions d\'utilisation',
    'totalOpen': 'Nombre total de visionnages de la bande-annonce',
    'views': 'vues',
    'credits': 'Crédits',
    'opensource': 'Info sur le code source ouvert',
  },
  'de': {
    'userdata': 'Nutzerdaten',
    'initdate': 'Startdatum',
    'totalhour': 'Gesamtnutzungszeit',
    'lastusage': 'Letzte Nutzung',
    'setting': 'Einstellungen',
    'vibrate': 'Vibration',
    'alarm': 'Benachrichtigung',
    'caption': 'Untertitel',
    'language': 'Sprache',
    'theme': 'Thema',
    'light': 'Hell',
    'dark': 'Dunkel',
    'instagram': 'Instagram',
    'sns': 'X (Twitter)',
    'twitter': 'X (Twitter)',
    'share': 'App teilen',
    'other': 'Sunnys Spiele und Apps',
    'review': 'Bewertung abgeben',
    'version': 'App-Version',
    'privacy': 'Datenschutzrichtlinie',
    'terms': 'Nutzungsbedingungen',
    'totalOpen': 'Gesamtanzahl der Traileransichten',
    'views': 'Ansichten',
    'credits': 'Abspann',
    'opensource': 'Open-Source-Info',
  },
  'es': {
    'userdata': 'Datos de usuario',
    'initdate': 'Fecha de inicio',
    'totalhour': 'Tiempo total de uso',
    'lastusage': 'Último uso',
    'setting': 'Configuración',
    'vibrate': 'Vibración',
    'alarm': 'Notificación',
    'caption': 'Subtítulos',
    'language': 'Idioma',
    'theme': 'Tema',
    'light': 'claro',
    'dark': 'oscuro',
    'instagram': 'Instagram',
    'sns': 'X (Twitter)',
    'twitter': 'X (Twitter)',
    'share': 'Compartir la app',
    'other': 'Los juegos y aplicaciones de Sunny',
    'review': 'Dejar una reseña',
    'version': 'Versión de la app',
    'privacy': 'Política de privacidad',
    'terms': 'Términos de servicio',
    'totalOpen': 'Total de vistas de trailers',
    'views': 'vistas',
    'credits': 'Créditos',
    'opensource': 'Info de código abierto'
  },
  'hi': {
    'userdata': 'उपयोगकर्ता डेटा',
    'initdate': 'आरंभ तिथि',
    'totalhour': 'कुल उपयोग समय',
    'lastusage': 'अंतिम उपयोग समय',
    'setting': 'सेटिंग्स',
    'vibrate': 'कंपन',
    'alarm': 'सूचना',
    'caption': 'कैप्शन',
    'language': 'भाषा',
    'theme': 'थीम',
    'light': 'लाइट',
    'dark': 'डार्क',
    'instagram': 'इंस्टाग्राम',
    'sns': 'एक्स (ट्विटर)',
    'twitter': 'एक्स (ट्विटर)',
    'share': 'ऐप साझा करें',
    'other': 'Sunny के खेल और एप्स',
    'review': 'समीक्षा छोड़ें',
    'version': 'ऐप संस्करण',
    'privacy': 'गोपनीयता नीति',
    'terms': 'सेवा की शर्तें',
    'totalOpen': 'कुल ट्रेलर देखे जाने की संख्या',
    'views': 'दृश्य',
    'credits': 'खेल कर्मचारी',
    'opensource': 'ओपन सोर्स जानकारी'
  },
  'th': {
    'userdata': 'ข้อมูลผู้ใช้',
    'initdate': 'วันเริ่มต้น',
    'totalhour': 'เวลาการใช้งานทั้งหมด',
    'lastusage': 'เวลาการใช้งานล่าสุด',
    'setting': 'การตั้งค่า',
    'vibrate': 'การสั่นสะเทือน',
    'alarm': 'การแจ้งเตือน',
    'caption': 'คำบรรยาย',
    'language': 'ภาษา',
    'theme': 'ธีม',
    'light': 'สว่าง',
    'dark': 'มืด',
    'instagram': 'อินสตาแกรม',
    'sns': 'X (ทวิตเตอร์)',
    'twitter': 'X (ทวิตเตอร์)',
    'share': 'แชร์แอป',
    'other': 'Sunny - เกมและแอป',
    'review': 'ฝากรีวิว',
    'version': 'เวอร์ชันแอป',
    'privacy': 'นโยบายความเป็นส่วนตัว',
    'terms': 'เงื่อนไขการให้บริการ',
    'totalOpen': 'ยอดการดูตัวอย่างภาพยนตร์',
    'views': 'ครั้ง',
    'credits': 'ทีมงานสร้างแอป',
    'opensource': 'ข้อมูลโอเพ่นซอร์ส'
  },
};

Map<String, Map<String, String>> donateLabels = {
  "ko": {
    "donate": "기부하기",
    "donateRemoveAds": "지원하고 광고 제거",
    "donateDesc": "작은 기부는 개발팀에 큰 힘이 됩니다. 기부 후 광고 제거 + 무제한 메모 및 북마크를 즐겨보세요. 항상 감사합니다.",
    "trailerAdNotice": "예고편 동영상 내의 영화사가 넣은 광고는 저희들에게 책임이 없고 컨트롤 할 수 없음을 미리 말씀 드립니다.",
    "restorePurchase": "이전 구매 복원",
    "donateComplete": "기부에 감사드립니다!"
  },
  "en": {
    "donate": "Donate",
    "donateRemoveAds": "Support Us and Remove Ads",
    "donateDesc": "A small donation gives great support to our development team. Donate to Enjoy No Ads + Unlimited Memos & Bookmarks. Thank you always.",
    "trailerAdNotice": "Please note that we are not responsible for and cannot control the ads inserted by film distributors within trailer videos.",
    "restorePurchase": "Restore the Previous Purchase",
    "donateComplete": "Thank you for your donation!"
  },
  "ja": {
    "donate": "寄付する",
    "donateRemoveAds": "支援して広告を削除",
    "donateDesc": "小さなご支援でも開発チームにとって大きな力になります。寄付後、広告削除+無制限のメモとお気に入りをお楽しみください。いつもありがとうございます。",
    "trailerAdNotice": "予告編動画内の映画会社による広告については、当方では責任を負えず、制御もできないことをあらかじめご了承ください。",
    "restorePurchase": "過去の購入を復元",
    "donateComplete": "ご寄付ありがとうございます！"
  },
  "zh": {
    "donate": "捐赠",
    "donateRemoveAds": "支持我们并移除广告",
    "donateDesc": "您的小额捐赠对我们的开发团队来说是巨大的支持。捐赠后移除广告 + 享受无限制的备忘录和书签。一直以来感谢您的支持！",
    "trailerAdNotice": "请注意，预告片视频中的广告由电影公司插入，我们无法控制，也不对此负责。",
    "restorePurchase": "恢复之前的购买",
    "donateComplete": "感谢您的捐赠！"
  },
  "tw": {
    "donate": "捐贈",
    "donateRemoveAds": "支持我們並移除廣告",
    "donateDesc": "您的小額捐贈對我們的開發團隊來說是莫大的支持。捐贈後移除廣告 + 享受無限制的備忘錄和書籤。一直以來感謝您的支持！",
    "trailerAdNotice": "請注意，預告片影片中的廣告由電影公司加入，我們無法控制，亦不負責。",
    "restorePurchase": "恢復之前的購買",
    "donateComplete": "感謝您的捐贈！"
  },
  "fr": {
    "donate": "Faire un don",
    "donateRemoveAds": "Soutenez-nous et supprimez les pubs",
    "donateDesc": "Un petit don représente un grand soutien pour notre équipe de développement. Faites un don pour profiter sans publicité + mémos et favoris illimités. Merci infiniment pour votre soutien constant.",
    "trailerAdNotice": "Veuillez noter que nous ne sommes pas responsables des publicités insérées par les distributeurs dans les bandes-annonces, et nous ne pouvons pas les contrôler.",
    "restorePurchase": "Restaurer les achats précédents",
    "donateComplete": "Merci pour votre don !"
  },
  "de": {
    "donate": "Spende",
    "donateRemoveAds": "Unterstützen Sie uns und entfernen Sie die Werbung",
    "donateDesc": "Eine kleine Spende ist eine große Unterstützung für unser Entwicklungsteam. Spenden Sie, um werbefrei zu genießen + unbegrenzte Notizen und Lesezeichen. Vielen Dank für Ihre anhaltende Unterstützung.",
    "trailerAdNotice": "Bitte beachten Sie, dass wir keine Verantwortung für Werbung übernehmen können, die von Filmverleihern in Trailer-Videos eingefügt wird, und wir haben darauf keinen Einfluss.",
    "restorePurchase": "Frühere Käufe wiederherstellen",
    "donateComplete": "Vielen Dank für Ihre Spende!"
  },
  "es": {
    "donate": "Donar",
    "donateRemoveAds": "Apóyanos y elimina los anuncios",
    "donateDesc": "Una pequeña donación es un gran apoyo para nuestro equipo de desarrollo. Dona para disfrutar sin anuncios + notas y marcadores ilimitados. Muchas gracias por tu apoyo constante.",
    "trailerAdNotice": "Tenga en cuenta que no somos responsables de los anuncios insertados por las distribuidoras en los videos de tráileres y no tenemos control sobre ellos.",
    "restorePurchase": "Restaurar compras anteriores",
    "donateComplete": "¡Gracias por tu donación!"
  },
  "hi": {
    "donate": "दान करें",
    "donateRemoveAds": "हमें समर्थन करें और विज्ञापन हटाएं",
    "donateDesc": "आपका छोटा सा दान हमारी विकास टीम के लिए बहुत मददगार है। दान करें और विज्ञापन हटाने + असीमित मेमो और बुकमार्क का आनंद लें। हमेशा धन्यवाद।",
    "trailerAdNotice": "कृपया ध्यान दें कि ट्रेलर वीडियो में फ़िल्म कंपनियों द्वारा डाले गए विज्ञापनों के लिए हम ज़िम्मेदार नहीं हैं और न ही हम उन्हें नियंत्रित कर सकते हैं।",
    "restorePurchase": "पिछली खरीदारी पुनर्स्थापित करें",
    "donateComplete": "आपके दान के लिए धन्यवाद!"
  },
  "th": {
    "donate": "บริจาค",
    "donateRemoveAds": "สนับสนุนเราและลบโฆษณา",
    "donateDesc": "การบริจาคเล็กน้อยของคุณช่วยทีมพัฒนาได้มาก บริจาคแล้วเพลิดเพลินกับการลบโฆษณา + บันทึกและที่คั่นหน้าไม่จำกัด ขอบคุณเสมอค่ะ/ครับ",
    "trailerAdNotice": "โปรดทราบว่าเราจะไม่รับผิดชอบและไม่สามารถควบคุมโฆษณาที่แทรกโดยบริษัทภาพยนตร์ในวิดีโอตัวอย่างได้",
    "restorePurchase": "กู้คืนการซื้อก่อนหน้านี้",
    "donateComplete": "ขอบคุณสำหรับการบริจาคของคุณ!"
  }
};

final Map<int, List<String>> countryByDay = {
  1: ['box', 'korea'],          // Monday
  2: ['japan'],          // Tuesday
  3: ['usa', 'canada'], // Wednesday
  4: ['india', 'spain', 'taiwan'], // Thursday
  5: ['france', 'china'],        // Friday
  6: ['germany'],          // Saturday
  7: ['australia', 'thailand'],   // Sunday
};

final Map<String, List<String>> countryByLanguage = {
  'ko': ['korea', 'usa', 'box'],  
  'ja': ['japan', 'usa', 'box'],
  'zh': ['china', 'taiwan', 'usa', 'box'], 
  'tw': ['taiwan', 'china', 'usa', 'box'], 
  'fr': ['france', 'usa', 'box'],   
  'de': ['germany', 'usa', 'box'],     
  'es': ['spain', 'usa', 'box'], 
  'hi': ['india', 'usa', 'box'],
  'th': ['thailand', 'usa', 'box'],
  'en': ['usa', 'canada', 'autralia', 'box'],  
};

Map<String, Map<String, String>> countryNameByLan = {
  'ko': {
    'ko': '한국어',
    'en': 'English',
    'ja': '日本語',
    'zh': '簡体中文',
    'tw': '繁體中文',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'hi': 'हिन्दी',
    'th': 'แบบไทย',
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

// Constants for app bar titles
const Map<String, String> countryAppBarsForShare = {
  'en': "World Movie Trailers",  // English
  'ko': "월드 무비 트레일러",       // Korean
  'ja': "ワールド ムービー トレーラー",  // Japanese
  'ft': "World Movie Trailers",  // French
  'zh': "世界 电影 预告片",         // Simplified Chinese
  'tw': "世界 電影 預告片",         // Traditional Chinese
  'de': "Welt Film Trailer",     // German
  'es': "Tráilers de películas", // Spanish
  'hi': "विश्व फिल्म ट्रेलर",      // Hindi
  'th': "โลก ภาพยนตร์ ตัวอย่าง",  // Thai
};

Map<String, Map<String, String>> menuTranslations = {
  'ko': {
    'Country Order': '국가 순서 변경',
    'Like': '좋아요',
    'Dislike': '싫어요',
    'Bookmark': '북마크',
    'Memo': '메모',
  },
  'en': {
    'Country Order': 'Reorder Countries',
    'Like': 'Like',
    'Dislike': 'Dislike',
    'Bookmark': 'Bookmark',
    'Memo': 'Memo',
  },
  'ja': {
    'Country Order': '国別の並び順を変更',
    'Like': '高評価',
    'Dislike': '低評価',
    'Bookmark': 'お気に入り',
    'Memo': 'メモ',
  },
  'zh': {
    'Country Order': '国家顺序变更', // Simplified Chinese
    'Like': '喜欢',
    'Dislike': '不喜欢',
    'Bookmark': '书签',
    'Memo': '备忘录',
  },
  'tw': {
    'Country Order': '國家順序變更', // Traditional Chinese
    'Like': '喜歡',
    'Dislike': '不喜歡',
    'Bookmark': '書籤',
    'Memo': '備忘錄',
  },
  'fr': {
    'Country Order': 'Réorganiser les pays',
    'Like': 'J\'aime',
    'Dislike': 'Je n’aime pas',
    'Bookmark': 'Marque-page',
    'Memo': 'Mémo',
  },
  'de': {
    'Country Order': 'Länder neu ordnen',
    'Like': 'Gefällt mir',
    'Dislike': 'Gefällt mir nicht',
    'Bookmark': 'Lesezeichen',
    'Memo': 'Memo',
  },
  'es': {
    'Country Order': 'Reordenar países',
    'Like': 'Me gusta',
    'Dislike': 'No me gusta',
    'Bookmark': 'Marcador',
    'Memo': 'Nota',
  },
  'hi': {
    'Country Order': 'देशों को पुनः क्रमबद्ध करें',
    'Like': 'पसंद',
    'Dislike': 'नापसंद',
    'Bookmark': 'बुकमार्क',
    'Memo': 'ज्ञापन',
  },
  'th': {
    'Country Order': 'จัดเรียงประเทศใหม่',
    'Like': 'ชอบ',
    'Dislike': 'ไม่ชอบ',
    'Bookmark': 'บุ๊กมาร์ก',
    'Memo': 'เมโม่',
  },
};

Map<String, Map<String, String>> messageTranslations = {
  'ko': {
    'duplicateMovie': '같은 영화 이미 있음',
    'addToBookmark': '\'북마크\'에 영화 추가',
    'addToMemo': '\'메모\'에 영화 추가',
    'maxMoviesReached': 'Max 30개까지 저장 가능',
    'maxMemosReached': 'Max 300 단어까지 저장 가능',
    'saveMemo': '저장',
    'closeMemo': '닫기',
    'addMemo': '메모',
    'movieDeleted': '\'북마크\'에서 영화 제거',
    'memoDeleted': '메모를 삭제 했습니다.',
  },
  'en': {
    'duplicateMovie': 'The same movie already exists.',
    'addToBookmark': 'Add this movie to \'Bookmark\'',
    'addToMemo': 'Add this movie to \'Memo\'',
    'maxMoviesReached': 'You\'ve reached the maximum of 30.',
    'maxMemosReached': 'You\'ve reached the maximum of 300 words.',
    'saveMemo': 'Save',
    'closeMemo': 'Close',
    'addMemo': 'Memo',
    'movieDeleted': 'Remove the movie from \'Bookmark\'',
    'memoDeleted': 'Deleted the memo.',
  },
  'ja': {
    'duplicateMovie': '既に登録済みです',
    'addToBookmark': '「ブックマーク」に映画追加',
    'addToMemo': '「メモ」に映画を追加',
    'maxMoviesReached': 'Max 30個まで保存可能',
    'maxMemosReached': '最大300単語まで保存可能',
    'saveMemo': '保存する',
    'closeMemo': '閉じる',
    'addMemo': 'メモ',
    'movieDeleted': 'お気に入りから映画を削除',
    'memoDeleted': 'メモを削除しました。',
  },
  'zh': {
    'duplicateMovie': '同样的电影已经存在。',
    'addToBookmark': '将此视频添加到"Bookmark"',
    'addToMemo': '将这部电影添加到"备忘录"中',
    'maxMoviesReached': '你已经达到了最高30。',
    'maxMemosReached': '你已达字数上限300',
    'saveMemo': '保存',
    'closeMemo': '关闭',
    'addMemo': '备忘录',
    'movieDeleted': '将电影从书签中移除',
    'memoDeleted' : '删除备忘录'
  },
  'tw': {
    'duplicateMovie': '同樣的電影已經存在。',
    'addToBookmark': '將此視頻添加到"Bookmark"',
    'addToMemo': '將這部電影添加到"備忘錄"中',
    'maxMoviesReached': '你已經達到了最高30。',
    'maxMemosReached': '你已達字數上限300',
    'saveMemo': '保存',
    'closeMemo': '關閉',
    'addMemo': '備忘錄',
    'movieDeleted': '將電影從書籤中移除',
    'memoDeleted': '刪除備忘錄'
  },
  'fr': {
    'duplicateMovie': 'Le même film existe déjà',
    'addToBookmark': 'Ajouter ce film à \'Marque-page\'',
    'addToMemo': 'Ajouter ce film à \'Mémo\'',
    'maxMoviesReached': 'Vous avez atteint le maximum de 30.',
    'maxMemosReached': 'Vous avez atteint le maximum de 300 mots.',
    'saveMemo': 'Enregistrer',
    'closeMemo': 'Fermer',
    'addMemo': 'Mémo',
    'movieDeleted': 'Supprimez le film des favoris',
    'memoDeleted': 'Supprimé le mémo.'
  },
  'de': {
    'duplicateMovie': 'Der gleiche Film existiert bereits',
    'addToBookmark': 'Füge diesen Film zu \'Lesezeichen\' hinzu',
    'addToMemo': 'Füge diesen Film zu \'Memo\' hinzu',
    'maxMoviesReached': 'Sie haben das Maximum von 30 erreicht.',
    'maxMemosReached': 'Sie haben das Maximum von 300 Wörtern erreicht',
    'saveMemo': 'Speichern',
    'closeMemo': 'Schließen',
    'addMemo': 'Memo',
    'movieDeleted': 'Entfernen Sie den Film aus den Lesezeichen',
    'memoDeleted': 'Memo gelöscht.',
  },
  'es': {
    'duplicateMovie': 'La misma película ya existe',
    'addToBookmark': 'Agregar esta película a \'Marcador\'',
    'addToMemo': 'Agregar esta película a \'Nota\'',
    'maxMoviesReached': 'Has alcanzado el máximo de 30.',
    'maxMemosReached': 'Has alcanzado el máximo de 300 palabras.',
    'saveMemo': 'Guardar',
    'closeMemo': 'Cerrar',
    'addMemo': 'Nota',
    'movieDeleted': 'EElimina la película de los marcadores',
    'memoDeleted': 'Eliminada la nota.',
  },
  'hi': {
    'duplicateMovie': 'वही फिल्म पहले से मौजूद है',
    'addToBookmark': 'इस फिल्म को \'बुकमार्क\' में जोड़ें',
    'addToMemo': 'इस फिल्म को \'नोट\' में जोड़ें',
    'maxMoviesReached': 'आप 30 की अधिकतम सीमा पर पहुंच गए हैं',
    'maxMemosReached': 'आपने 300 शब्दों की अधिकतम सीमा तक पहुँच गया है।',
    'saveMemo': 'सहेजें',
    'closeMemo': 'बंद करें',
    'addMemo': 'ज्ञापन',
    'movieDeleted': 'बुकमार्क से फिल्म को हटा दें',
    'memoDeleted':'मेमो हटा दिया।',
  },
  'th': {
    'duplicateMovie': 'ภาพยนตร์เรื่องเดียวกันมีอยู่แล้ว',
    'addToBookmark': 'เพิ่มภาพยนตร์เรื่องนี้ไปที่ \'บุ๊กมาร์ก\'',
    'addToMemo': 'เพิ่มภาพยนตร์เรื่องนี้ไปที่ \'บันทึก\'',
    'maxMoviesReached': 'คุณถึงจำนวนสูงสุดที่ 30 แล้ว',
    'maxMemosReached': 'आपने 300 शब्दों की अधिकतम सीमा तक पहुँच गया है।',
    'saveMemo': 'บันทึก',
    'closeMemo': 'ปิด',
    'addMemo': 'เมโม่',
    'movieDeleted': 'ลบภาพยนตร์ออกจากที่คั่นหนังสือ',
    'memoDeleted': 'ลบบันทึกแล้ว',
  },
};

const Map<String, String> countryAppBarNameByCountry = {
  'en': "Trailer in ",  // English
  'ko': '영화의 예고편',  // Korean
  'ja': '予告編 in ',  // Japanese
  'fr': 'Bande-annonce du film in ',  // French
  'zh': '电影预告片 in ',  // Simplified Chinese
  'tw': '電影預告片 in ',  // Traditional Chinese
  'de': 'Filmtrailer in ',  // German
  'es': 'Tráiler de la película in ',  // Spanish
  'hi': 'फिल्म का ट्रेलर in ',  // Hindi
  'th': 'ตัวอย่างหนัง',  // Thai
};

const Map<String, Map<String, String>> boxOfficeKeyword = {
  'box': {
    'en': 'Top Box Office',
    'ko': '박스오피스 - 영화순위',
    'ja': '映画ランキング',
    'zh': '票房 - 电影排名',
    'tw': '票房 - 電影排名',
    'fr': 'Top Box Office',
    'de': 'Top Box Office',
    'es': 'Taquilla',
    'hi': 'बॉक्स ऑफिस - फ़िल्म रैंकिंग',
    'th': 'บ็อกซ์ออฟฟิศ - อันดับภาพยนตร์',
  },
  'box_usa': {
    'en': 'Box Office - USA',
    'ko': '미국 박스오피스',
    'ja': '全米映画ランキング',
    'zh': '美国票房',
    'tw': '美國票房',
    'fr': 'Box Office américain',
    'de': 'US-Kinokasse',
    'es': 'Taquilla de Estados Unidos',
    'hi': 'अमेरिकी बॉक्स ऑफिस',
    'th': 'บ็อกซ์ออฟฟิศสหรัฐฯ',
  },
  'this_week': {
    'en': "This Week's Rankings",
    'ko': '이번 주 순위',
    'ja': '今週の順位',
    'zh': '本周排名',
    'tw': '本週排名',
    'fr':  "This Week's Rankings",
    'de': 'Diese Woche Rangliste',
    'es':  "This Week's Rankings",
    'hi': 'इस सप्ताह की रैंकिंग',
    'th': 'อันดับประจำสัปดาห์นี้',
  },
  'last_week': {
    'en': "Last Week’s Ranking",
    'ko': '지난 주 순위',
    'ja': '先週の順位',
    'zh': '上周排名',
    'tw': '上週排名',
    'fr': 'Classement de la semaine dernière',
    'de': 'Platzierung der letzten Woche',
    'es': 'Clasificación de la semana pasada',
    'hi': 'पिछले सप्ताह की रैंकिंग',
    'th': 'อันดับสัปดาห์ที่แล้ว',
  },
  'total_gross': {
    'en': "Total Gross",
    'ko': '총 수익',
    'ja': '興行収入',
    'zh': '总收益',
    'tw': '總收益',
    'fr': 'Recettes totales',
    'de': 'Gesamteinnahmen',
    'es': 'Ingresos totales',
    'hi': 'कुल आय',
    'th': 'รายได้รวม',
  },
  'screening_weeks': {
    'en': "Screening Weeks",
    'ko': '상영기간 (주)',
    'ja': '上映期間 (週)',
    'zh': '放映时间（周）',
    'tw': '放映時間（周）',
    'fr': 'Durée de projection (semaines)',
    'de': 'Laufzeit (Wochen)',
    'es': 'Duración en cartelera (semanas)',
    'hi': 'प्रदर्शन अवधि (सप्ताह)',
    'th': 'ระยะเวลาฉาย (สัปดาห์)',
  },
  'distributor': {
    'en': "Distributor",
    'ko': '배급사',
    'ja': '配給会社',
    'zh': '发行公司',
    'tw': '發行公司',
    'fr': 'Distributeur',
    'de': 'Verleih',
    'es': 'Distribuidora',
    'hi': 'वितरक',
    'th': 'ผู้จัดจำหน่าย',
  },
};

const Map<String, Map<String, String>> localizedCountries = {
  'en': {
    'box': 'Top Box Office',
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
    'box': '박스오피스 - 영화순위',
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
    'box': '映画ランキング',
    'japan': '日本',
    'korea': '韓国',
    'usa': 'アメリカ',
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
    'box': '票房 - 電影排名',
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
    'box': '票房 - 电影排名',
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
    'box': 'Top Box Office',
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
    'box': 'Top Box Office',
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
    'box': 'Taquilla',
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
    'box': 'बॉक्स ऑफिस - फ़िल्म रैंकिंग',
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
    'box': 'Top Box Office',
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
const boxOffice = 'box';
const special = 'special';

// country list
// special section
const specialLabelTranslations = {
  'Director of the Week': {
    'en': 'Director of the Week',
    'ko': '이번 주의 감독',
    'ja': '今週の監督',
    'zh': '本周推荐导演',
    'tw': '本週推薦導演',
    'fr': 'Réalisateur de la semaine',
    'de': 'Regisseur der Woche',
    'es': 'Director de la semana',
    'hi': 'इस सप्ताह के निर्देशक',
    'th': 'ผู้กำกับประจำสัปดาห์',
  },
  'Actor of the Week': {
    'en': 'Actor of the Week',
    'ko': '이번 주의 남자 배우',
    'ja': '今週の男優',
    'zh': '本周推荐男演员',
    'tw': '本週推薦男演員',
    'fr': 'Acteur de la semaine',
    'de': 'Schauspieler der Woche',
    'es': 'Actor de la semana',
    'hi': 'इस सप्ताह के अभिनेता',
    'th': 'นักแสดงประจำสัปดาห์',
  },
  'Actress of the Week': {
    'en': 'Actress of the Week',
    'ko': '이번 주의 여자 배우',
    'ja': '今週の女優',
    'zh': '本周推荐女演员',
    'tw': '本週推薦女演員',
    'fr': 'Actrice de la semaine',
    'de': 'Schauspielerin der Woche',
    'es': 'Actriz de la semana',
    'hi': 'इस सप्ताह की अभिनेत्री',
    'th': 'นักแสดงหญิงประจำสัปดาห์',
  },
  'Movie Quotes': {
    'en': 'Movie Quotes',
    'ko': '영화 속 명대사',
    'ja': '映画の中の名台詞',
    'zh': '电影经典台词',
    'tw': '電影經典台詞',
    'fr': 'Répliques cultes de films',
    'de': 'Berühmte Filmzitate',
    'es': 'Frases icónicas de películas',
    'hi': 'फ़िल्म के प्रसिद्ध संवाद',
    'th': 'ประโยคเด่นจากภาพยนตร์',
  },
  'Berlin Film Festival': {
    'en': 'Berlin Film Festival',
    'ko': '베를린 영화제',
    'ja': 'ベルリン映画祭',
    'zh': '柏林电影节',
    'tw': '柏林電影節',
    'fr': 'Festival du film de Berlin',
    'de': 'Berlinale Filmfestspiele',
    'es': 'Festival de Cine de Berlín',
    'hi': 'बर्लिन फिल्म महोत्सव',
    'th': 'เทศกาลภาพยนตร์เบอร์ลิน',
  },
  'Venice Film Festival': {
    'en': 'Venice Film Festival',
    'ko': '베니스 영화제',
    'ja': 'ベネチア映画祭',
    'zh': '威尼斯电影节',
    'tw': '威尼斯電影節',
    'fr': 'Festival de Venise',
    'de': 'Internationale Filmfestspiele Venedig',
    'es': 'Festival de Cine de Venecia',
    'hi': 'वेनिस फिल्म महोत्सव',
    'th': 'เทศกาลภาพยนตร์เวนิส',
  },
  'Cannes Film Festival': {
    'en': 'Cannes Film Festival',
    'ko': '칸 영화제',
    'ja': 'カンヌ映画祭',
    'zh': '戛纳电影节',
    'tw': '坎城影展',
    'fr': 'Festival de Cannes',
    'de': 'Internationale Filmfestspiele Cannes',
    'es': 'Festival de Cine de Cannes',
    'hi': 'कान्स फिल्म महोत्सव',
    'th': 'เทศกาลภาพยนตร์เมืองคานส์',
  },
  'Busan Film Festival': {
    'en': 'Busan Film Festival',
    'ko': '부산 영화제',
    'ja': '釜山国際映画祭',
    'zh': '釜山国际电影节',
    'tw': '釜山國際影展',
    'fr': 'Festival du film de Busan',
    'de': 'Busan Internationales Filmfestival',
    'es': 'Festival de Cine de Busan',
    'hi': 'बुसान फिल्म महोत्सव',
    'th': 'เทศกาลภาพยนตร์นานาชาติปูซาน',
  },
  'Toronto Film Festival': {
    'en': 'Toronto Film Festival',
    'ko': '토론토 영화제',
    'ja': 'トロント国際映画祭',
    'zh': '多伦多国际电影节',
    'tw': '多倫多國際影展',
    'fr': 'Festival de Toronto',
    'de': 'Toronto Internationales Filmfestival',
    'es': 'Festival de Cine de Toronto',
    'hi': 'टोरंटो फिल्म महोत्सव',
    'th': 'เทศกาลภาพยนตร์นานาชาติโตรอนโต',
  },
  'Academy Awards': {
    'en': 'Academy Awards',
    'ko': '아카데미 시상식',
    'ja': 'アカデミー賞',
    'zh': '奥斯卡金像奖',
    'tw': '奧斯卡金像獎',
    'fr': 'Cérémonie des Oscars',
    'de': 'Oscar-Verleihung',
    'es': 'Premios de la Academia',
    'hi': 'अकादमी पुरस्कार',
    'th': 'รางวัลออสการ์',
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
  },
};

Map<String, String> movieQuoteTranslations = {
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

const labelFilterAllJP = "全て";
const labelFilterRunningJP = "上映中";
const labelFilterUpcomingJP = "公開予定";

const labelFilterAllZH = "全部预告片";
const labelFilterRunningZH = "上映中";
const labelFilterUpcomingZH = "即将上映";

const labelFilterAllTW = "全部預告片";
const labelFilterRunningTW = "上映中";
const labelFilterUpcomingTW = "即將上映 ";

const labelFilterAllFR = "Tout";
const labelFilterAllDE = "Alles";
const labelFilterAllES = "Todo";
const labelFilterAllHI = "सब";

const labelFilterAllTH = "ทั้งหมด";
const labelFilterRunningTH = "กำลังฉาย";
const labelFilterUpcomingTH = "เร็วๆ นี้";

const Map<String, Map<String, String>> sortFilters = {
  'date_new': {
    'en': 'Date (New)',
    'ko': '최신 순서',
    'ja': '最新の日付順',
    'zh': '按日期（升序）',
    'tw': '按日期（升序）',
    'fr': 'Date (Nouvelle)',
    'de': 'Datum (Neu)',
    'es': 'Fecha (Nueva)',
    'hi': 'तिथि (नया)',
    'th': 'วันที่ (ใหม่)',
  },
  'date_old': {
    'en': 'Date (Old)',
    'ko': '오래된 순서',
    'ja': '古い日付順',
    'zh': '按日期（降序）',
    'tw': '按日期（降序）',
    'fr': 'Date (Ancienne)',
    'de': 'Datum (Alt)',
    'es': 'Fecha (Antigua)',
    'hi': 'तिथि (पुराने)',
    'th': 'วันที่ (เก่า)',
  },
  'alphabet_asc': {
    'en': 'Alphabet (A-Z)',
    'ko': '가나다 순서',
    'ja': 'ひらがな（昇順）',
    'zh': '字母索引 (A-Z)',
    'tw': '字母索引 (A-Z)',
    'fr': 'Alphabet (A-Z)',
    'de': 'Alphabet (A-Z)',
    'es': 'Alphabet (A-Z)',
    'hi': 'ए-जेड',
    'th': 'อักษร (ก - ฮ)',
  },
  'alphabet_desc': {
    'en': 'Alphabet (Z-A)',
    'ko': '가나다 역순',
    'ja': 'ひらがな（降順）',
    'zh': '字母索引 (Z-A)',
    'tw': '字母索引 (Z-A)',
    'fr': 'Alphabet (Z-A)',
    'de': 'Alphabet (Z-A)',
    'es': 'Alphabet (Z-A)',
    'hi': 'जेड-ए',
    'th': 'อักษร (ฮ - ก)',
  },
  'date_new_up': {
    'en': 'Coming Soon',
    'ko': '곧 개봉 순서',
    'ja': '公開予定(昇順)',
    'zh': '按日期 (今天-明天)',
    'tw': '按日期 (今天-明天)',
    'fr': 'Prochainement',
    'de': 'Demnächst',
    'es': 'Próximamente',
    'hi': 'शीघ्र आ रहा है',
    'th': 'เร็วๆ นี้',
  },
  'date_old_up': {
    'en': 'Coming Later',
    'ko': '나중 개봉 순서',
    'ja': '公開予定(降順)',
    'zh': '按日期 (明天-今天)',
    'tw': '按日期 (明天-今天)',
    'fr': 'Plus tard',
    'de': 'Später verfügbar',
    'es': 'Más tarde',
    'hi': 'बाद में आ रहा है',
    'th': 'มาทีหลัง',
  },
};

// poster
const labelRelease = "Release";
const labelReleaseKR = "개봉";
const labelReleaseJP = "公開";
const labelReleaseZH = "已发行";
const labelReleaseTW = "已發行";
const labelReleaseFR = "Sortie";
const labelReleaseES = "Estreno";
const labelReleaseHI = "रिलीज़";
const labelReleaseTH = "เข้าฉาย"; 

// movie error 
const labelNetworkErrorKR = "서버 네트워크가 원활하지 않습니다.\r\n조금있다 다시 시도해 주세요.";
const labelNetworkErrorEN = "The server network is not up.\r\nPlease try again later.";
const labelNetworkErrorJP = "サーバーネットワークが円滑ではありません。\r\n少し後でもう一度お試しください。";
const labelNetworkErrorZH = "服务器网络不畅\r\n请稍后再试";
const labelNetworkErrorTW = "伺服器網路不穩\r\n請稍後再重試";
const labelNetworkErrorFR = "Le réseau du serveur est instable.\r\nVeuillez réessayer plus tard.";
const labelNetworkErrorDE = "Das Servernetzwerk ist instabil.\r\nBitte versuchen Sie es später noch einmal.";	
const labelNetworkErrorES = "La red del servidor está inestable.\r\nPor favor, inténtelo de nuevo más tarde.";
const labelNetworkErrorHI = "सर्वर नेटवर्क अस्थिर है। कृपया कुछ\r\nसमय बाद पुनः प्रयास करें।";
const labelNetworkErrorTH = "เครือข่ายเซิร์ฟเวอร์ไม่เสถียร\r\nกรุณาลองอีกครั้งในภายหลัง";

const labelEmptyErrorKR = "아직 추가한 영화가 없습니다.\r\n추가 후 다시 시도해보세요.";
const labelEmptyErrorEN = "No movies have been added yet.\r\nPlease add movies and try again.";
const labelEmptyErrorJP = "まだ追加した映画がありません。\r\n追加してもう一度お試しください。";
const labelEmptyErrorZH = "尚未添加电影。\r\n请添加电影后重试。";
const labelEmptyErrorTW = "尚未新增電影。\r\n請新增電影後再試一次。";
const labelEmptyErrorFR = "Aucun film n'a encore été ajouté.\r\nAjoutez des films et réessayez.";
const labelEmptyErrorDE = "Es wurden noch keine Filme hinzugefügt.\r\nBitte fügen Sie Filme hinzu und versuchen Sie es erneut.";
const labelEmptyErrorES = "Aún no se han añadido películas.\r\nPor favor, añada películas e inténtelo de nuevo.";
const labelEmptyErrorHI = "अभी तक कोई फिल्म नहीं जोड़ी गई है।\r\nकृपया फिल्में जोड़ें और पुनः प्रयास करें।";
const labelEmptyErrorTH = "ยังไม่มีการเพิ่มภาพยนตร์\r\nกรุณาเพิ่มภาพยนตร์และลองอีกครั้ง";


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
    'ja': '出演',
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
    'ja': '国',
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
