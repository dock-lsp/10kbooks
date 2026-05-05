# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Dart classes
-keep class dart.** { *; }
-keep class **.DartClass { *; }

# Keep generated Plugin Registrant
-keep class **.GeneratedPluginRegistrant { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Stripe
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# PayPal
-keep class com.paypal.** { *; }
-dontwarn com.paypal.**

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Retrofit
-keepattributes Signature
-keepattributes Exceptions
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class com.tenkbooks.app.shared.models.** { *; }

# Braintree
-keep class com.braintreepayments.** { *; }
-dontwarn com.braintreepayments.**

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**
