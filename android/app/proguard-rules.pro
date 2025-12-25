# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep Gson classes for JSON parsing
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep R8 from removing important classes
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep Play Core library
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep deferred components
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Razorpay Proguard Rules
-keep class com.razorpay.** {*;}
-dontwarn com.razorpay.**
-keep class com.google.android.gms.wallet.** {*;}
-keep class com.google.android.gms.auth.api.phone.** {*;}
-keep class com.google.android.gms.safetynet.** {*;}
-keep class com.google.android.apps.nbu.paisa.** {*;}

