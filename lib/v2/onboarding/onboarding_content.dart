import 'package:flutter/material.dart';

class OnboardingCopy {
  const OnboardingCopy({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

const onboardingCopies = <String, List<OnboardingCopy>>{
  'ko': [
    OnboardingCopy(
      title: '국가 순서도\n내 마음대로',
      description: '국가를 길게 누른 뒤 원하는 위치로 옮겨 순서를 변경하세요.',
      icon: Icons.drag_indicator_rounded,
    ),
    OnboardingCopy(
      title: '원하는 언어로\n바로 번역',
      description: '한국어와 원본을 버튼 하나로 간편하게 전환하세요.',
      icon: Icons.translate_rounded,
    ),
    OnboardingCopy(
      title: '예고편을 연속으로\n자동 재생',
      description: '재생이 끝나면 다음 예고편이 자동으로 이어져 끊김 없이 감상할 수 있어요.',
      icon: Icons.play_circle_fill_rounded,
    ),
    OnboardingCopy(
      title: '스와이프로\n다음 영화 예고편',
      description: '상세 화면에서 좌우로 스와이프하여 이전·다음 영화 예고편을 빠르게 탐색하세요.',
      icon: Icons.swipe_rounded,
    ),
  ],
  'en': [
    OnboardingCopy(
        title: 'Countries in\nyour order',
        description: 'Long-press a country and move it wherever you want.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Translate to\nyour language',
        description:
            'Switch between your language and the original with one tap.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Autoplay trailers\ncontinuously',
        description: 'When one trailer ends, the next starts automatically.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Swipe to the next\nmovie trailer',
        description:
            'Swipe on the detail screen to browse the previous or next movie trailer.',
        icon: Icons.swipe_rounded),
  ],
  'ja': [
    OnboardingCopy(
        title: '国の順番を\n自由に変更',
        description: '国を長押しして、好きな位置へ移動できます。',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: '好きな言語に\nすぐ翻訳',
        description: '翻訳と原文をボタンひとつで簡単に切り替えられます。',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: '予告編を自動で\n連続再生',
        description: '再生が終わると、次の予告編が自動で始まります。',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'スワイプで次の\n映画予告編へ',
        description: '詳細画面を左右にスワイプして、前後の映画予告編をすばやく確認できます。',
        icon: Icons.swipe_rounded),
  ],
  'zh': [
    OnboardingCopy(
        title: '自定义国家\n顺序',
        description: '长按国家并将其移动到想要的位置。',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: '即时翻译为\n所选语言',
        description: '轻点按钮，即可在翻译和原文之间切换。',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: '自动连续播放\n预告片',
        description: '当前预告片结束后，下一部将自动播放。',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: '滑动查看下一部\n电影预告片',
        description: '在详情页左右滑动，快速浏览上一部或下一部电影预告片。',
        icon: Icons.swipe_rounded),
  ],
  'tw': [
    OnboardingCopy(
        title: '自訂國家\n順序',
        description: '長按國家並將它移動到想要的位置。',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: '即時翻譯為\n所選語言',
        description: '輕觸按鈕，即可在翻譯與原文之間切換。',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: '自動連續播放\n預告片',
        description: '目前預告片結束後，下一部會自動播放。',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: '滑動查看下一部\n電影預告片',
        description: '在詳細頁左右滑動，快速瀏覽上一部或下一部電影預告片。',
        icon: Icons.swipe_rounded),
  ],
  'fr': [
    OnboardingCopy(
        title: 'Classez les pays\nà votre façon',
        description: 'Maintenez un pays appuyé et déplacez-le où vous voulez.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Traduisez dans\nvotre langue',
        description: 'Passez de la traduction au texte original en un geste.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Lecture automatique\ndes bandes-annonces',
        description:
            'À la fin d’une bande-annonce, la suivante démarre automatiquement.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Balayez vers la\nbande-annonce suivante',
        description:
            'Balayez la fiche pour voir rapidement la bande-annonce précédente ou suivante.',
        icon: Icons.swipe_rounded),
  ],
  'de': [
    OnboardingCopy(
        title: 'Länder nach Wunsch\nsortieren',
        description:
            'Halte ein Land gedrückt und verschiebe es an die gewünschte Position.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Direkt in deine Sprache\nübersetzen',
        description:
            'Wechsle mit einem Tippen zwischen Übersetzung und Original.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Trailer automatisch\nweiterspielen',
        description: 'Nach einem Trailer startet der nächste automatisch.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Zum nächsten Filmtrailer\nwischen',
        description:
            'Wische auf der Detailseite zum vorherigen oder nächsten Filmtrailer.',
        icon: Icons.swipe_rounded),
  ],
  'es': [
    OnboardingCopy(
        title: 'Ordena los países\na tu gusto',
        description:
            'Mantén pulsado un país y muévelo a la posición que quieras.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Traduce a tu idioma\nal instante',
        description:
            'Cambia entre la traducción y el original con un solo toque.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Reproducción continua\nde tráilers',
        description:
            'Cuando termina un tráiler, el siguiente comienza automáticamente.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Desliza al siguiente\ntráiler',
        description:
            'Desliza en la ficha para ver rápidamente el tráiler anterior o siguiente.',
        icon: Icons.swipe_rounded),
  ],
  'hi': [
    OnboardingCopy(
        title: 'देशों का क्रम\nअपने हिसाब से',
        description: 'किसी देश को देर तक दबाएँ और मनचाही जगह पर ले जाएँ।',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'अपनी भाषा में\nतुरंत अनुवाद',
        description: 'एक टैप में अनुवाद और मूल भाषा के बीच बदलें।',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'ट्रेलर लगातार\nअपने आप चलें',
        description:
            'एक ट्रेलर खत्म होते ही अगला ट्रेलर अपने आप शुरू हो जाएगा।',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'अगले फ़िल्म ट्रेलर के लिए\nस्वाइप करें',
        description:
            'पिछला या अगला फ़िल्म ट्रेलर देखने के लिए विवरण स्क्रीन पर स्वाइप करें।',
        icon: Icons.swipe_rounded),
  ],
  'th': [
    OnboardingCopy(
        title: 'จัดลำดับประเทศ\nได้ตามใจ',
        description: 'กดประเทศค้างไว้แล้วเลื่อนไปยังตำแหน่งที่ต้องการ',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'แปลเป็นภาษาที่ต้องการ\nทันที',
        description: 'สลับระหว่างคำแปลและต้นฉบับได้ด้วยการแตะเพียงครั้งเดียว',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'เล่นตัวอย่างต่อเนื่อง\nอัตโนมัติ',
        description:
            'เมื่อตัวอย่างหนึ่งจบ ตัวอย่างถัดไปจะเริ่มเล่นโดยอัตโนมัติ',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'ปัดเพื่อดูตัวอย่าง\nเรื่องถัดไป',
        description:
            'ปัดหน้ารายละเอียดเพื่อดูตัวอย่างภาพยนตร์ก่อนหน้าหรือถัดไปอย่างรวดเร็ว',
        icon: Icons.swipe_rounded),
  ],
};

const onboardingActionLabels = <String, Map<String, String>>{
  'ko': {'skip': '건너뛰기', 'next': '다음', 'start': '시작하기'},
  'en': {'skip': 'Skip', 'next': 'Next', 'start': 'Get Started'},
  'ja': {'skip': 'スキップ', 'next': '次へ', 'start': '始める'},
  'zh': {'skip': '跳过', 'next': '下一步', 'start': '开始使用'},
  'tw': {'skip': '略過', 'next': '下一步', 'start': '開始使用'},
  'fr': {'skip': 'Passer', 'next': 'Suivant', 'start': 'Commencer'},
  'de': {'skip': 'Überspringen', 'next': 'Weiter', 'start': 'Loslegen'},
  'es': {'skip': 'Omitir', 'next': 'Siguiente', 'start': 'Comenzar'},
  'hi': {'skip': 'छोड़ें', 'next': 'आगे', 'start': 'शुरू करें'},
  'th': {'skip': 'ข้าม', 'next': 'ถัดไป', 'start': 'เริ่มใช้งาน'},
};
