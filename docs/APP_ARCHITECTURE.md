# World Movie Trailer v2 구조

이 문서는 현재 v2 앱의 실제 실행 흐름을 기준으로 작성한다. 구조를 변경할 때 기능이 사라지지 않도록 각 책임과 연결 지점을 기록한다.

## 앱 실행 흐름

```text
main.dart
  -> app/app_bootstrap.dart
       Firebase / Hive / 광고 / 알림 / 날짜 포맷 초기화
       SettingsProvider 생성
  -> app/world_movie_trailer_app.dart
       라이트·다크 테마와 전역 ScaffoldMessenger 구성
  -> v2/home/home_shell.dart
       국가별 / 박스오피스 / 특별기획 / 영화명언 / 북마크 표시
  -> layout/movie_detail_page.dart
       플랫폼에 맞는 YouTube 상세 페이지 선택
```

## 디렉터리 책임

| 경로 | 책임 |
|---|---|
| `lib/app/` | 앱 부팅, 전역 Provider, 테마, 최상위 화면 |
| `lib/v2/home/` | v2 메인 화면과 Home 전용 위젯 |
| `lib/layout/` | 설정, 알림, 구매, 상세 등 독립 화면 |
| `lib/common/services/` | 영화·명언·북마크·알림·구매 데이터 처리 |
| `lib/common/ad_manager/` | 전면·보상형 광고 정책과 SDK 연결 |
| `lib/common/providers/` | 사용자 설정 상태와 Hive 저장 연결 |
| `lib/common/constants.dart` | 번역가가 제공한 다국어 문구와 앱 상수 |
| `lib/common/translate.dart` | 언어 코드로 상수 및 번역 데이터를 선택 |
| `lib/model/` | Movie, Quote, Bookmark, Settings 및 Hive 어댑터 |
| `functions/` | 국가별 Fetch/Store 및 예약 실행 백엔드 |

## Home 화면 섹션

`HomeShell`은 현재 다음 섹션 상태를 관리한다.

| 값 | 화면 | 데이터 |
|---:|---|---|
| 0 | 국가별 영화 | `MovieService.fetchMovies` |
| 1 | 박스오피스 | `MovieService.fetchMovies` |
| 2 | 북마크 | `MovieByUserService.getBookmarks` |
| 3 | 특별기획 | `MovieService.fetchMovies` |
| 4 | 영화명언 | `QuoteService.fetchQuote` |

Home의 로딩·필터·선택 상태는 `home_shell.dart`에 남아 있으며, 재사용 가능한 빈 화면·오류 화면·스토어 배지는 `widgets/home_state_widgets.dart`로 분리했다.

## 번역과 원본 표시

```text
SettingsProvider.language
  + HomeShell의 번역/원본 선택 상태
  -> Movie.originSource 또는 선택 언어 필드 결정
  -> 상세 페이지 initialShowOriginal 전달
```

- 무료 모바일 사용자는 원본이 기본값이다.
- 번역을 선택하면 광고 시청 또는 구매 정책을 확인한다.
- 웹은 번역 제한 없이 표시하고 배너 광고 정책을 사용한다.
- 번역 데이터가 없으면 원문 또는 영어 데이터로 안전하게 대체한다.
- 번역가가 제공한 `constants.dart` 문구는 구조 정리 과정에서 임의로 변경하지 않는다.

## 북마크와 알림

북마크는 `MovieByUser`에 영화와 저장 시각, 원본 피드 국가(`sourceFeedCode`)를 저장한다. 알림 서비스는 저장된 개봉일과 국가 정보를 사용해 알림 제목과 내용을 현지화한다.

```text
상세 페이지 북마크
  -> MovieByUserService
  -> Hive bookmark box
  -> AlarmService.registerReleaseAlarmsFromList
```

## 광고 지점

- 번역·북마크·개봉 예정: 모바일 무료 사용자에게 보상형 광고 또는 구매 팝업
- 보상형 광고 완료: 세 기능을 10분 동안 공통 해제
- 특별기획 진입: 인터스티셜 광고 표시 후 10분 동안 재표시하지 않음
- 앱 시작 시 전면 광고를 표시하지 않음
- 설정 하단: 무료 모바일 사용자에게 배너 광고 표시
- 웹: 모바일 보상형·인터스티셜 광고 정책을 적용하지 않음
- 구매 사용자: 모든 광고와 기능 잠금을 우회

## Hive 저장소

현재 앱은 부팅 시 어댑터를 등록하고 신규 v2 박스를 연다. `_obsoleteHiveBoxes` 목록의 과거 박스는 제거 대상이다. 모델 필드를 변경할 때는 기존 `HiveField` 번호를 재사용하지 않는다.

## 안전한 구조 변경 원칙

1. UI 문구나 비즈니스 조건을 바꾸지 않고 파일만 분리한다.
2. 기존 공개 모델 필드와 HiveField 번호를 유지한다.
3. 분리 전후에 `flutter analyze`와 전체 테스트를 실행한다.
4. 한 단계에서 한 책임만 옮긴다.
5. 자동 생성 파일과 사용자 에셋을 임의로 삭제하지 않는다.

## 다음 분리 후보

1. Home 헤더와 언어 토글
2. 국가·박스오피스 선택기
3. 영화 행과 포스터 카드
4. 북마크 화면
5. Home 전용 다국어 문구

이 순서는 상태 의존성이 낮은 영역부터 시작하도록 정한 것이다. `HomeShell`의 로딩과 광고 정책은 마지막에 Controller로 옮기는 편이 안전하다.
