import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class LogHelper {
  static final LogHelper _instance = LogHelper._internal();
  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
  final Amplitude _amplitude = Amplitude.getInstance(instanceName: "default");

  factory LogHelper() {
    return _instance;
  }

  LogHelper._internal() {
    // Initialize Amplitude with your API key
    _amplitude.init("6339bfab615ac03ea1efef7293b6b4b7"); // Replace with your actual API key
  }

  // Unified logEvent method for both Google Analytics and Amplitude
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (parameters != null) {
      // Convert parameters to Map<String, Object> for Firebase
      final Map<String, Object> firebaseParams = parameters.map((key, value) {
        if (value is String || value is int || value is double || value is bool || value == null) {
          return MapEntry(key, value as Object); // Cast to Object
        } else {
          // Convert unsupported types to String for Firebase
          return MapEntry(key, value.toString() as Object);
        }
      });

      // Log event to Firebase Analytics with the converted parameters
      _firebaseAnalytics.logEvent(name: eventName, parameters: firebaseParams);
    } else {
      // Log event to Firebase without parameters if null
      _firebaseAnalytics.logEvent(name: eventName);
    }

    _amplitude.logEvent(eventName, eventProperties: parameters);
  }

  void setUserId(String userId) {
    _firebaseAnalytics.setUserId(id: userId);
    _amplitude.setUserId(userId);
  }

  void setUserProperties(Map<String, dynamic> properties) {
    _firebaseAnalytics.setUserProperty(name: 'user_properties', value: properties.toString());
    _amplitude.setUserProperties(properties);
  }
}
