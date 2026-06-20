# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads (AdMob) + Play services
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Google Play Billing / in_app_purchase
-keep class com.android.billingclient.** { *; }
-keep class com.android.vending.billing.** { *; }

# Flutter references Play Core deferred-components classes that we don't ship.
# The app does not use deferred components, so it's safe to ignore them.
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep annotations and generic signatures used via reflection
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
