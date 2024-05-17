@echo off
tasklist | find /i "iexplore.exe" > nul

if ERRORLEVEL 1 goto NOTLOADED

taskkill /im iexplore.exe /f

GOTO EOF

:NOTLOADED

ECHO.
ECHO IE isn't loaded right now...
ECHO.

:EOF