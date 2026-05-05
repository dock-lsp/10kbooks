package com.tengkbooks.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize Google Mobile Ads
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "adFactoryBanner",
            BannerAdFactory(binding.adView!!)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "adFactoryNative",
            NativeAdFactory(binding.nativeAdView!!)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "adFactoryBanner"
        )
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(
            flutterEngine,
            "adFactoryNative"
        )
    }
}

// Banner Ad Factory
class BannerAdFactory(private val adView: android.view.View) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: com.google.android.gms.ads.nativead.NativeAd,
        customOptions: android.os.Bundle?
    ): android.view.View {
        return adView
    }
}

// Native Ad Factory
class NativeAdFactory(private val nativeAdView: android.view.View) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: com.google.android.gms.ads.nativead.NativeAd,
        customOptions: android.os.Bundle?
    ): android.view.View {
        return nativeAdView
    }
}
