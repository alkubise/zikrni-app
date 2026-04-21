# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver { *; }

# Android Alarm Manager Plus
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }
-keep class dev.fluttercommunity.plus.androidalarmmanager.AlarmService { *; }
-keep class dev.fluttercommunity.plus.androidalarmmanager.AlarmBroadcastReceiver { *; }
-keep class dev.fluttercommunity.plus.androidalarmmanager.RebootBroadcastReceiver { *; }

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }

# Flutter Engine & Play Store
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Fix for Play Store Core / Split Install (The error you got)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Additional fixes for missing classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
