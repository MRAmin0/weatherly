# ---------- Flutter & Dart ----------
# Keep everything in the Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep everything in your main app package
-keep class com.weathely.app.** { *; }

# ---------- JSON serialization ----------
# Keep model classes that might be used via reflection (e.g. from JSON)
-keep class *.model.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ---------- Retrofit / HTTP libraries (if used) ----------
-keepattributes Signature
-keepattributes *Annotation*
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }

# ---------- Avoid removing entry points ----------
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugin.**
-dontwarn io.flutter.app.**
