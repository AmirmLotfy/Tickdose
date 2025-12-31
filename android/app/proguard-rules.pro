# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }

# Keep Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Keep Firebase Firestore
-keep class com.google.firestore.** { *; }
-keep class com.google.cloud.firestore.** { *; }

# Keep Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# Keep Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep Play Core classes (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }

# Keep Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep Gson classes (used by Firebase)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep data classes (models)
-keep class * extends java.lang.Exception {
    <fields>;
}

# Keep annotation default values
-keepattributes AnnotationDefault

# Keep inner classes
-keepclassmembers class * {
    ** *$*;
}

# Keep native method names
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Keep JavaScript interface (for WebView)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep WorkManager
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Keep Hive (local storage)
-keep class hive.** { *; }
-keep class hive_flutter.** { *; }

# Keep timezone classes
-keep class tzdata.** { *; }

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep speech recognition classes
-keep class com.google.speech.** { *; }
-dontwarn com.google.speech.**

# Keep audio player classes
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Keep location classes
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Keep permission handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Keep image picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Keep shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Keep secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Keep path provider
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# Keep package info
-keep class io.flutter.plugins.packageinfo.** { *; }
-dontwarn io.flutter.plugins.packageinfo.**

# Keep device info
-keep class io.flutter.plugins.deviceinfo.** { *; }
-dontwarn io.flutter.plugins.deviceinfo.**

# Keep URL launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# Keep health plugin
-keep class dev.pedrolassalle.health.** { *; }
-dontwarn dev.pedrolassalle.health.**

# Keep pedometer
-keep class com.health.pedometer.** { *; }
-dontwarn com.health.pedometer.**

# Keep QR code
-keep class net.touchcapture.qr.flutterqr.** { *; }
-dontwarn net.touchcapture.qr.flutterqr.**

# Keep app links
-keep class com.llfbandit.app_links.** { *; }
-dontwarn com.llfbandit.app_links.**

# Keep share plus
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# Keep work manager
-keep class be.tramckrijte.workmanager.** { *; }
-dontwarn be.tramckrijte.workmanager.**

# Keep local auth
-keep class io.flutter.plugins.localauth.** { *; }
-dontwarn io.flutter.plugins.localauth.**

# Keep Google Sign-In
-keep class io.flutter.plugins.googlesignin.** { *; }
-dontwarn io.flutter.plugins.googlesignin.**

# Keep speech to text
-keep class com.csdcorp.speech_to_text.** { *; }
-dontwarn com.csdcorp.speech_to_text.**

# Keep text to speech
-keep class com.tundralabs.fluttertts.** { *; }
-dontwarn com.tundralabs.fluttertts.**

# Keep record
-keep class com.llfbandit.record.** { *; }
-dontwarn com.llfbandit.record.**

# Keep just audio
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.just_audio.**

# Keep PDF
-keep class io.github.afreakyelf.pdf.** { *; }
-dontwarn io.github.afreakyelf.pdf.**

# Keep printing
-keep class net.nfet.flutter.printing.** { *; }
-dontwarn net.nfet.flutter.printing.**

# Keep cached network image
-keep class flutter.plugins.cachednetworkimage.** { *; }
-dontwarn flutter.plugins.cachednetworkimage.**

# Keep flutter map
-keep class com.fleaflet.flutter_map.** { *; }
-dontwarn com.fleaflet.flutter_map.**

# Keep fl chart
-keep class com.github.imaNNeoFighT.fl_chart.** { *; }
-dontwarn com.github.imaNNeoFighT.fl_chart.**

# Keep table calendar
-keep class com.apparence.calendar.** { *; }
-dontwarn com.apparence.calendar.**

# Keep intl
-keep class intl.** { *; }
-dontwarn intl.**

# Keep sqflite
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# Keep path
-keep class path.** { *; }
-dontwarn path.**

# Keep uuid
-keep class uuid.** { *; }
-dontwarn uuid.**

# Keep dio
-keep class dio.** { *; }
-dontwarn dio.**

# Keep http
-keep class http.** { *; }
-dontwarn http.**

# Keep provider
-keep class provider.** { *; }
-dontwarn provider.**

# Keep riverpod
-keep class riverpod.** { *; }
-dontwarn riverpod.**

# Keep flutter_riverpod
-keep class flutter_riverpod.** { *; }
-dontwarn flutter_riverpod.**

# Preserve line numbers for stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Remove logging in release (optional)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
