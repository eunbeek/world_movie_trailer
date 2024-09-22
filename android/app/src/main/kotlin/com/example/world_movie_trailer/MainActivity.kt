package com.sunnyinnolab.worldMovieTrailer

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.google.android.gms.ads.MobileAds // If you're using Google Ads SDK

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Google Mobile Ads SDK
        MobileAds.initialize(this) { initializationStatus ->
            // Handle ad initialization
        }
    }
}
