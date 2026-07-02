@echo off
cd /d C:\Users\dawas\dwaar
echo === Flutter Devices ===
flutter devices
echo.
echo === Available Emulators ===
flutter emulators
echo.
echo === Starting Flutter on Android Emulator ===
flutter run -d emulator-5554
pause
