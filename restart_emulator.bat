@echo off
echo ==============================================
echo          RESTARTING ANDROID EMULATOR            
echo ==============================================
echo.

set AVD_NAME=Pixel_10_Pro_XL
if not "%~1"=="" set AVD_NAME=%~1

echo [1/4] Force-closing any frozen emulator processes...
taskkill /F /IM emulator.exe 2>nul
taskkill /F /IM qemu-system-x86_64.exe 2>nul

echo [2/4] Resetting the ADB connection server...
"C:\Users\dawas\AppData\Local\Android\Sdk\platform-tools\adb.exe" kill-server
"C:\Users\dawas\AppData\Local\Android\Sdk\platform-tools\adb.exe" start-server

echo.
echo [3/4] Finding available Android Virtual Devices (AVDs)...
"C:\Users\dawas\AppData\Local\Android\Sdk\emulator\emulator.exe" -list-avds

echo.
echo [4/4] Starting emulator '%AVD_NAME%' with clean boot...
echo (Using -no-snapshot-load to ensure a clean boot and avoid restoring from corrupted state)
start "" "C:\Users\dawas\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd %AVD_NAME% -no-snapshot-load

echo.
echo ==============================================
echo Emulator '%AVD_NAME%' launch requested.
echo Please wait 1-2 mins for it to boot up.
echo ==============================================
echo.
