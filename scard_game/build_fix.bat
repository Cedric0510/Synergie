@echo off
echo ============================================
echo Build APK avec GRADLE_USER_HOME permanent
echo ============================================
set GRADLE_USER_HOME=C:\GradleHome
set GRADLE_OPTS=-Dfile.encoding=UTF-8
echo GRADLE_USER_HOME = %GRADLE_USER_HOME%
echo.
cd /d "C:\Dev\Scard\scard_game"
flutter build apk --release --verbose
echo.
if %ERRORLEVEL% EQU 0 (
    echo ============================================
    echo BUILD REUSSI !
    echo APK : build\app\outputs\flutter-apk\app-release.apk
    echo ============================================
) else (
    echo ============================================
    echo BUILD ECHOUE - Code erreur: %ERRORLEVEL%
    echo ============================================
)
pause
