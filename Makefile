.PHONY: release-check release-android release-ios

# Store releases always use the production bundle IDs and Firebase project.
release-check:
	flutter pub get
	flutter analyze
	flutter test

# Google Play artifact: build/app/outputs/bundle/prodRelease/app-prod-release.aab
release-android:
	flutter build appbundle --release --flavor prod --target lib/main_prod.dart

# TestFlight artifact: build/ios/ipa/*.ipa
release-ios:
	flutter build ipa --release --flavor prod --target lib/main_prod.dart
	/usr/libexec/PlistBuddy -c "Set :Name World Movie Trailer" build/ios/archive/Runner.xcarchive/Info.plist
	/usr/libexec/PlistBuddy -c "Set :SchemeName World Movie Trailer" build/ios/archive/Runner.xcarchive/Info.plist
