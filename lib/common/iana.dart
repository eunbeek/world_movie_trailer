import 'dart:ui';

const Map<String, String> timeZoneMapping = {
  // 북미 시간대
  'EST': 'America/New_York', // Eastern Standard Time
  'EDT': 'America/New_York', // Eastern Daylight Time
  'CST-America': 'America/Chicago', // Central Standard Time
  'CDT': 'America/Chicago', // Central Daylight Time
  'MST': 'America/Denver', // Mountain Standard Time
  'MDT': 'America/Denver', // Mountain Daylight Time
  'PST': 'America/Los_Angeles', // Pacific Standard Time
  'PDT': 'America/Los_Angeles', // Pacific Daylight Time

  // 유럽 시간대
  'GMT': 'Europe/London', // Greenwich Mean Time
  'BST': 'Europe/London', // British Summer Time
  'CET': 'Europe/Paris', // Central European Time
  'CEST': 'Europe/Paris', // Central European Summer Time
  'EET': 'Europe/Athens', // Eastern European Time
  'EEST': 'Europe/Athens', // Eastern European Summer Time

  // 아시아 시간대
  'KST': 'Asia/Seoul', // Korea Standard Time
  'JST': 'Asia/Tokyo', // Japan Standard Time
  'IST': 'Asia/Kolkata', // Indian Standard Time
  'CST-Asia': 'Asia/Shanghai', // China Standard Time (중복 - Asia)
  'HKT': 'Asia/Hong_Kong', // Hong Kong Time
  'SGT': 'Asia/Singapore', // Singapore Time
  'AWST': 'Australia/Perth', // Australian Western Standard Time

  // 호주 시간대
  'ACST': 'Australia/Adelaide', // Australian Central Standard Time
  'AEST': 'Australia/Sydney', // Australian Eastern Standard Time

  // 남미 시간대
  'BRT': 'America/Sao_Paulo', // Brasilia Time
  'ART': 'America/Argentina/Buenos_Aires', // Argentina Time

  // 아프리카 시간대
  'SAST': 'Africa/Johannesburg', // South Africa Standard Time
  'EAT': 'Africa/Nairobi', // East Africa Time

  // 기타 지역
  'NZST': 'Pacific/Auckland', // New Zealand Standard Time
  'HST': 'Pacific/Honolulu', // Hawaii Standard Time
  'AKST': 'America/Anchorage', // Alaska Standard Time
};

/// IANA TimeZone 이름 가져오기
String getIANATimeZone(String abbreviation) {
  final String locale = window.locale.countryCode ?? 'Unknown';

  // 약어 + 지역 조합
  String key = '$abbreviation-$locale';

  // 맵핑된 시간대 찾기
  return timeZoneMapping[key] ?? timeZoneMapping[abbreviation] ?? 'UTC';
}
