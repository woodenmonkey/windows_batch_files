@echo off
tasklist | find /i "chrome.exe"
if %ERRORLEVEL% NEQ 1 goto EOF
echo.
echo Chrome isn't loaded right now...
echo.
:EOF