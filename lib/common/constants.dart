// main
const appTitle = "World Movie Trailer";

// settings_provider
const supportedLanguages = ['en', 'ko', 'ja', 'zh', 'tw', 'fr', 'de', 'es', 'hi', 'th'];

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
  }
};

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
    'other': '써니의 다른 앱 보기',
    'review': '리뷰 남기기',
    'version': '앱 버전',
    'privacy': '개인정보처리방침',
    'terms': '서비스 이용약관',
    'totalOpen': '예고편 본 총 횟수',
    'views': '회',
    'credits': '크레딧',
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
    'share': 'Share the App',
    'other': 'View Sunny\'s other Apps',
    'review': 'Write a Review',
    'version': 'App Version',
    'privacy': 'Privacy Policy',
    'terms': 'Terms of Service',
    'totalOpen': 'Total Trailer Views',
    'views': 'views',
    'credits': 'Credits',
  },
  'ja': {
    'userdata': 'ユーザーデータ',
    'initdate': '開始日',
    'totalhour': '総利用時間',
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
    'share': 'このアプリを共有する',
    'other': '他のSunnyアプリを見る',
    'review': 'レビューを残す',
    'version': 'バージョン',
    'privacy': 'プライバシーポリシー',
    'terms': '利用規約',
    'totalOpen': '予告編の視聴回数',
    'views': '回',
    'credits': 'クレジット',
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
    'share': '分享應用程式',
    'other': '查看Sunny的其他應用程式',
    'review': '留下評論',
    'version': '應用程式版本',
    'privacy': '隱私政策',
    'terms': '服務條款',
    'totalOpen': '預告片的總觀看次數',
    'views': '次',
    'credits': '製作人員名單',
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
    'other': 'Voir d\'autres applis de Sunny',
    'review': 'Laisser un avis',
    'version': 'Version de l\'application',
    'privacy': 'Politique de confidentialité',
    'terms': 'Conditions d\'utilisation',
    'totalOpen': 'Nombre total de visionnages de la bande-annonce',
    'views': 'vues',
    'credits': 'Crédits',
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
    'other': 'Andere Apps von Sunny anzeigen',
    'review': 'Bewertung abgeben',
    'version': 'App-Version',
    'privacy': 'Datenschutzrichtlinie',
    'terms': 'Nutzungsbedingungen',
    'totalOpen': 'Gesamtanzahl der Traileransichten',
    'views': 'Ansichten',
    'credits': 'Abspann',
  },
  'zh': {
    'userdata': '应用版本',
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
    'other': '查看Sunny的其他应用',
    'review': '留下评论',
    'version': '应用版本',
    'privacy': '隐私政策',
    'terms': '服务条款',
    'totalOpen': '总预告片观看次数',
    'views': '次',
    'credits': '制作人员名单',
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
    'other': 'Ver otras aplicaciones de Sunny',
    'review': 'Dejar una reseña',
    'version': 'Versión de la app',
    'privacy': 'Política de privacidad',
    'terms': 'Términos de servicio',
    'totalOpen': 'Total de vistas de trailers',
    'views': 'vistas',
    'credits': 'Créditos',
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
    'totalOpen': 'कुल ट्रेलर देखे जाने की संख्या',
    'views': 'दृश्य',
    'credits': 'खेल कर्मचारी',
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
    'other': 'ดูแอปอื่นๆ',
    'review': 'ฝากรีวิว',
    'version': 'เวอร์ชันแอป',
    'privacy': 'นโยบายความเป็นส่วนตัว',
    'terms': 'เงื่อนไขการให้บริการ',
    'totalOpen': 'ยอดการดูตัวอย่างภาพยนตร์',
    'views': 'ครั้ง',
    'credits': 'ทีมงานสร้างแอป',
  },
};

final Map<int, List<String>> countryByDay = {
  0: ['korea'],          // Monday
  1: ['japan'],          // Tuesday
  2: ['usa', 'canada'], // Wednesday
  3: ['india', 'spain', 'taiwan', 'china'], // Thursday
  4: ['france'],        // Friday
  5: ['germany'],          // Saturday
  6: ['australia', 'thailand'],   // Sunday
};
  
Map<String, Map<String, String>> countryNameByLan = {
  'ko': {
    'ko': '한국어',
    'en': 'English',
    'ja': '日本語',
    'zh': '簡体中国語',
    'tw': '繁体中国語',
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
    'addToLike': '\'좋아요\'에 영화 추가',
    'addToDislike': '\'싫어요\'에 영화 추가',
    'addToBookmark': '\'북마크\'에 영화 추가',
    'addToMemo': '\'메모\'에 영화 추가',
    'maxMoviesReached': 'Max 30개까지 저장 가능',
    'maxMemosReached': 'Max 300 단어까지 저장 가능',
    'saveMemo': '저장',
    'closeMemo': '닫기',
    'addMemo': '메모',
    'movieDeleted': '영화를 삭제 했습니다.',
    'memoDeleted': '메모를 삭제 했습니다.',
  },
  'en': {
    'duplicateMovie': 'The same movie already exists.',
    'addToLike': 'Add this movie to \'Like\'',
    'addToDislike': 'Add this movie to \'Dislike\'',
    'addToBookmark': 'Add this movie to \'Bookmark\'',
    'addToMemo': 'Add this movie to \'Memo\'',
    'maxMoviesReached': 'You\'ve reached the maximum of 30.',
    'maxMemosReached': 'You\'ve reached the maximum of 300 words.',
    'saveMemo': 'Save',
    'closeMemo': 'Close',
    'addMemo': 'Memo',
    'movieDeleted': 'Deleted the movie.',
    'memoDeleted': 'Deleted the memo.',
  },
  'ja': {
    'duplicateMovie': '同じ映画 既にあり',
    'addToLike': '「いいね」に映画追加',
    'addToDislike': '「よくないね」に映画追加',
    'addToBookmark': '「ブックマーク」に映画追加',
    'addToMemo': '「メモ」に映画を追加',
    'maxMoviesReached': 'Max 30個まで保存可能',
    'maxMemosReached': '最大300単語まで保存可能',
    'saveMemo': '保存する',
    'closeMemo': '閉じる',
    'addMemo': 'メモ',
    'movieDeleted': '映画を削除しました。',
    'memoDeleted': 'メモを削除しました。',
  },
  'zh': {
    'duplicateMovie': '同样的电影已经存在。',
    'addToLike': '将这部电影添加到"喜欢"',
    'addToDislike': '将这部电影添加到"不喜欢"',
    'addToBookmark': '将此视频添加到"Bookmark"',
    'addToMemo': '将这部电影添加到"备忘录"中',
    'maxMoviesReached': '你已经达到了最高30。',
    'maxMemosReached': '你已达字数上限300',
    'saveMemo': '保存',
    'closeMemo': '关闭',
    'addMemo': '备忘录',
    'movieDeleted': '删除电影',
    'memoDeleted' : '删除备忘录'
  },
  'tw': {
    'duplicateMovie': '同樣的電影已經存在。',
    'addToLike': '將這部電影添加到"喜歡"',
    'addToDislike': '將這部電影添加到"不喜歡"',
    'addToBookmark': '將此視頻添加到"Bookmark"',
    'addToMemo': '將這部電影添加到"備忘錄"中',
    'maxMoviesReached': '你已經達到了最高30。',
    'maxMemosReached': '你已達字數上限300',
    'saveMemo': '保存',
    'closeMemo': '關閉',
    'addMemo': '備忘錄',
    'movieDeleted': '刪除電影',
    'memoDeleted': '刪除備忘錄'
  },
  'fr': {
    'duplicateMovie': 'Le même film existe déjà',
    'addToLike': 'Ajouter ce film à \'J\'aime\'',
    'addToDislike': 'Ajouter ce film à \'Je n\'aime pas\'',
    'addToBookmark': 'Ajouter ce film à \'Marque-page\'',
    'addToMemo': 'Ajouter ce film à \'Mémo\'',
    'maxMoviesReached': 'Vous avez atteint le maximum de 30.',
    'maxMemosReached': 'Vous avez atteint le maximum de 300 mots.',
    'saveMemo': 'Enregistrer',
    'closeMemo': 'Fermer',
    'addMemo': 'Mémo',
    'movieDeleted': 'Supprimé le film.',
    'memoDeleted': 'Supprimé le mémo.'
  },
  'de': {
    'duplicateMovie': 'Der gleiche Film existiert bereits',
    'addToLike': 'Füge diesen Film zu \'Gefällt mir\' hinzu',
    'addToDislike': 'Füge diesen Film zu \'Gefällt mir nicht\' hinzu',
    'addToBookmark': 'Füge diesen Film zu \'Lesezeichen\' hinzu',
    'addToMemo': 'Füge diesen Film zu \'Memo\' hinzu',
    'maxMoviesReached': 'Sie haben das Maximum von 30 erreicht.',
    'maxMemosReached': 'Sie haben das Maximum von 300 Wörtern erreicht',
    'saveMemo': 'Speichern',
    'closeMemo': 'Schließen',
    'addMemo': 'Memo',
    'movieDeleted': 'Den Film gelöscht.',
    'memoDeleted': 'Memo gelöscht.',
  },
  'es': {
    'duplicateMovie': 'La misma película ya existe',
    'addToLike': 'Agregar esta película a \'Me gusta\'',
    'addToDislike': 'Agregar esta película a \'No me gusta\'',
    'addToBookmark': 'Agregar esta película a \'Marcador\'',
    'addToMemo': 'Agregar esta película a \'Nota\'',
    'maxMoviesReached': 'Has alcanzado el máximo de 30.',
    'maxMemosReached': 'Has alcanzado el máximo de 300 palabras.',
    'saveMemo': 'Guardar',
    'closeMemo': 'Cerrar',
    'addMemo': 'Nota',
    'movieDeleted': 'Eliminada la película.',
    'memoDeleted': 'Eliminada la nota.',
  },
  'hi': {
    'duplicateMovie': 'वही फिल्म पहले से मौजूद है',
    'addToLike': 'इस फिल्म को \'पसंद\' में जोड़ें',
    'addToDislike': 'इस फिल्म को \'नापसंद\' में जोड़ें',
    'addToBookmark': 'इस फिल्म को \'बुकमार्क\' में जोड़ें',
    'addToMemo': 'इस फिल्म को \'नोट\' में जोड़ें',
    'maxMoviesReached': 'आप 30 की अधिकतम सीमा पर पहुंच गए हैं',
    'maxMemosReached': 'आपने 300 शब्दों की अधिकतम सीमा तक पहुँच गया है।',
    'saveMemo': 'सहेजें',
    'closeMemo': 'बंद करें',
    'addMemo': 'ज्ञापन',
    'movieDeleted': 'फ़िल्म हटाई गई।',
    'memoDeleted':'मेमो हटा दिया।',
  },
  'th': {
    'duplicateMovie': 'ภาพยนตร์เรื่องเดียวกันมีอยู่แล้ว',
    'addToLike': 'เพิ่มภาพยนตร์เรื่องนี้ไปที่ \'ชอบ\'',
    'addToDislike': 'เพิ่มภาพยนตร์เรื่องนี้ไปที่ \'ไม่ชอบ\'',
    'addToBookmark': 'เพิ่มภาพยนตร์เรื่องนี้ไปที่ \'บุ๊กมาร์ก\'',
    'addToMemo': 'เพิ่มภาพยนตร์เรื่องนี้ไปที่ \'บันทึก\'',
    'maxMoviesReached': 'คุณถึงจำนวนสูงสุดที่ 30 แล้ว',
    'maxMemosReached': 'आपने 300 शब्दों की अधिकतम सीमा तक पहुँच गया है।',
    'saveMemo': 'บันทึก',
    'closeMemo': 'ปิด',
    'addMemo': 'เมโม่',
    'movieDeleted': 'ลบภาพยนตร์แล้ว',
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

const labelFilterAllJP = "すべての予告編";
const labelFilterRunningJP = "上映中";
const labelFilterUpcomingJP = "開封予定";

const labelFilterAllZH = "全部预告片";
const labelFilterRunningZH = "上映中";
const labelFilterUpcomingZH = "已发行";

const labelFilterAllTW = "全部預告片";
const labelFilterRunningTW = "上映中";
const labelFilterUpcomingTW = "已發行 ";

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
    'ja': '上映時間',
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
