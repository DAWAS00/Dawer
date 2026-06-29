# ProGuard/R8 rules for Dwaar
# Ignore missing classes from firebase-iid which is excluded in build.gradle.kts
-dontwarn com.google.firebase.iid.**
