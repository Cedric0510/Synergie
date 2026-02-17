# Script pour build l'APK en contournant le problème de l'accent dans le nom d'utilisateur
$env:GRADLE_USER_HOME = "C:\Temp\gradle_home"
$env:GRADLE_OPTS = "-Djava.io.tmpdir=C:\Temp"

Write-Host "Building APK with Gradle home in C:\Temp\gradle_home..." -ForegroundColor Green
flutter build apk --release

Write-Host "`nBuild terminé!" -ForegroundColor Green
