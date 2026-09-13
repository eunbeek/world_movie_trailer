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
      title: '국가 순서 변경',
      description: '국가를 길게 눌러 원하는 위치로 드래그하세요.',
      icon: Icons.drag_indicator_rounded,
    ),
    OnboardingCopy(
      title: '내 언어로 번역',
      description: '탭하여 원문과 번역문을 자유롭게 전환하세요.',
      icon: Icons.translate_rounded,
    ),
    OnboardingCopy(
      title: '예고편 연속 재생',
      description: '다음 예고편이 자동으로 연속 재생됩니다.',
      icon: Icons.play_circle_fill_rounded,
    ),
    OnboardingCopy(
      title: '스와이프하여 다음 영화 페이지로 이동',
      description: '좌우로 스와이프하여 영화를 쉽게 탐색하세요.',
      icon: Icons.swipe_rounded,
    ),
  ],
  'en': [
    OnboardingCopy(
        title: 'Reorder Countries',
        description: 'Touch and hold a country to drag it anywhere.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Translate to My Language',
        description: 'Tap to switch between original and translated text.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Continuous Autoplay',
        description: 'Autoplay the next trailer automatically.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Swipe for Next Movie Page',
        description: 'Swipe left or right to switch movies easily.',
        icon: Icons.swipe_rounded),
  ],
  'ja': [
    OnboardingCopy(
        title: '国の順序を変更',
        description: '国を長押しして好きな位置へドラッグします。',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: '自分の言語に翻訳',
        description: 'タップで原文と翻訳を切り替えます。',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: '予告編の連続再生',
        description: '次の予告編が自動で再生されます。',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'スワイプで次の映画ページへ',
        description: '左右にスワイプして簡単に映画を切り替えます。',
        icon: Icons.swipe_rounded),
  ],
  'zh': [
    OnboardingCopy(
        title: '调整国家顺序',
        description: '长按国家并拖动到任意位置。',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: '翻译为我的语言',
        description: '点击在原文和翻译之间切换。',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: '连续自动播放',
        description: '自动播放下一部预告片。',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: '滑动前往下一个电影页面',
        description: '左右滑动即可轻松切换电影。',
        icon: Icons.swipe_rounded),
  ],
  'tw': [
    OnboardingCopy(
        title: '調整國家順序',
        description: '長按國家並拖動至任意位置。',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: '翻譯為我的語言',
        description: '點擊在原文和翻譯之間切換。',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: '連續自動播放',
        description: '自動播放下一部預告片。',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: '滑動前往下一個電影頁面',
        description: '左右滑動即可輕鬆切換電影。',
        icon: Icons.swipe_rounded),
  ],
  'fr': [
    OnboardingCopy(
        title: 'Réorganiser les pays',
        description: 'Appuyez longuement sur un pays pour le faire glisser.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Traduire dans ma langue',
        description: 'Appuyez pour basculer entre texte original et traduit.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Lecture en continu',
        description: 'Lecture automatique de la bande-annonce suivante.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Balayer pour la page du film suivant',
        description:
            'Balayez vers la gauche ou la droite pour changer de film.',
        icon: Icons.swipe_rounded),
  ],
  'de': [
    OnboardingCopy(
        title: 'Reihenfolge der Länder ändern',
        description: 'Drücken und halten Sie ein Land, um es zu verschieben.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'In meine Sprache übersetzen',
        description:
            'Tippen Sie, um zwischen Original und Übersetzung zu wechseln.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Automatische Dauerausgabe',
        description: 'Spielt den nächsten Trailer automatisch ab.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Wischen zur nächsten Filmseite',
        description:
            'Wischen Sie nach links oder rechts, um Filme zu wechseln.',
        icon: Icons.swipe_rounded),
  ],
  'es': [
    OnboardingCopy(
        title: 'Reordenar países',
        description: 'Mantén presionado un país para arrastrarlo.',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'Traducir a mi idioma',
        description:
            'Toca para alternar entre el texto original y el traducido.',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'Reproducción continua',
        description: 'Reproduce automáticamente el siguiente tráiler.',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'Desliza para la página de la siguiente película',
        description:
            'Desliza a la izquierda o derecha para cambiar de película.',
        icon: Icons.swipe_rounded),
  ],
  'hi': [
    OnboardingCopy(
        title: 'देशों का क्रम बदलें',
        description: 'किसी देश पर लंबा दबाएं और उसे कहीं भी खींचें।',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'मेरी भाषा में अनुवाद करें',
        description: 'मूल और अनुवादित पाठ के बीच स्विच करने के लिए टैप करें।',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'लगातार ऑटोप्ले',
        description: 'अगला ट्रेलर स्वचालित रूप से चलाएं।',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'अगले फिल्म पेज के लिए स्वाइप करें',
        description:
            'फिल्मों को आसानी से बदलने के लिए बाएं या दाएं स्वाइप करें।',
        icon: Icons.swipe_rounded),
  ],
  'th': [
    OnboardingCopy(
        title: 'จัดเรียงลำดับประเทศ',
        description: 'แตะค้างที่ประเทศแล้วลากไปที่ใดก็ได้',
        icon: Icons.drag_indicator_rounded),
    OnboardingCopy(
        title: 'แปลเป็นภาษาของฉัน',
        description: 'แตะเพื่อสลับระหว่างข้อความต้นฉบับและข้อความแปล',
        icon: Icons.translate_rounded),
    OnboardingCopy(
        title: 'เล่นตัวอย่างต่อเนื่อง',
        description: 'เล่นตัวอย่างถัดไปโดยอัตโนมัติ',
        icon: Icons.play_circle_fill_rounded),
    OnboardingCopy(
        title: 'ปัดเพื่อไปยังหน้าภาพยนตร์ถัดไป',
        description: 'ปัดซ้ายหรือขวาเพื่อเปลี่ยนภาพยนตร์ได้ง่ายๆ',
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
