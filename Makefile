.PHONY: release-check release-android release-ios

# Store releases use the single V2 app configuration.
release-check:
	flutter pub get
	flutter analyze
	flutter test

# Google Play artifact: build/app/outputs/bundle/release/app-release.aab
release-android:
	flutter build appbundle --release

# TestFlight artifact: build/ios/ipa/*.ipa
release-ios:
	flutter build ipa --release
	/usr/libexec/PlistBuddy -c "Set :Name World Movie Trailer" build/ios/archive/Runner.xcarchive/Info.plist
	/usr/libexec/PlistBuddy -c "Set :SchemeName World Movie Trailer" build/ios/archive/Runner.xcarchive/Info.plist
