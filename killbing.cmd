@echo off
tasklist | find /i "bing" > nul
if %ERRORLEVEL% EQU 1 goto nl
for /f "tokens=1-4" %%a in ('"tasklist | find /i "bing""') do taskkill /im %%a /f 
goto eof
:nl
echo.
echo Bing Bar isn't loaded right now
echo.
:eof