import 'package:amplitude_flutter/amplitude.dart';

class LogHelper {
  static final LogHelper _instance = LogHelper._internal();
  Amplitude? _amplitude;

  factory LogHelper() {
    return _instance;
  }

  LogHelper._internal() {
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
