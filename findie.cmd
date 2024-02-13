@echo off
tasklist | find /i "iexplore.exe"
if %ERRORLEVEL% NEQ 1 goto EOF
ECHO.
ECHO IE isn't loaded right now...
ECHO.
:EOF