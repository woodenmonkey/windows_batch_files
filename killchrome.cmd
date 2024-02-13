@echo off

tasklist | find /i "chrome.exe" > nul
if ERRORLEVEL 1 goto NOTLOADED

taskkill /im chrome.exe /f

goto EOF

:NOTLOADED
echo.
echo Chrome isn't loaded right now...
echo.

:EOF