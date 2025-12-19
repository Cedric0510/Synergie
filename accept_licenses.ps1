$process = Start-Process -FilePath "C:\Android\cmdline-tools\latest\bin\sdkmanager.bat" -ArgumentList "--licenses" -NoNewWindow -PassThru -RedirectStandardInput "C:\Dev\Scard\yes.txt" -Wait
