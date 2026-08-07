# HealthON ProGuard Rules
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase
-keep class io.supabase.** { *; }

# Flutter
-keep class io.flutter.** { *; }

# Health Connect
-keep class androidx.health.** { *; }

# Riverpod
-keep class riverpod.** { *; }
-dontwarn riverpod.**

# Keep R8/ProGuard from stripping generic signatures
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
