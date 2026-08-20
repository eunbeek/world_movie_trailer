import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LogHelper {
  static final LogHelper _instance = LogHelper._internal();
  Amplitude? _amplitude;

  factory LogHelper() {
    return _instance;
  }

  LogHelper._internal() {
    // amplitude_flutter 3.x calls a native singleton that is unavailable on
    // Flutter Web. Analytics can be wired to a web SDK separately later.
    if (kIsWeb) return;
    _amplitude = Amplitude.getInstance(instanceName: "default");
    // Initialize Amplitude with your API key
    _amplitude!.init("6339bfab615ac03ea1efef7293b6b4b7");
    _amplitude!.trackingSessionEvents(true);
  }

  // Unified logEvent method for both Google Analytics and Amplitude
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    _amplitude?.logEvent(eventName, eventProperties: parameters);
  }

  void setUserId(String userId) {
    _amplitude?.setUserId(userId);
  }

  void setUserProperties(Map<String, dynamic> properties) {
    _amplitude?.setUserProperties(properties);
  }
}
