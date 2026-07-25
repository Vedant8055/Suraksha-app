# Flutter and plugins include their own consumer rules. Keep model metadata
# used by platform channels and Firebase serialization.
-keepattributes *Annotation*
-keepattributes Signature
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
