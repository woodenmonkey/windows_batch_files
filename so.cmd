@echo off
echo.
tasklist | find /i "outlook"
if ERRORLEVEL 1 goto NOTLOADED

echo.
set /p KILLOUTLOOK=Maybe it's time to kill Outlook again, no? (Y/N)
echo.

if %KILLOUTLOOK%==y (
	goto KILL
)
if %KILLOUTLOOK%==Y (
	goto KILL
) ELSE (
	goto END
)

:KILL
taskkill /im outlook.exe /f
goto END

:NOTLOADED
echo.
echo Outlook isn't loaded right now
echo.
echo.Find something else to kill..
echo.

:END
set KILLOUTLOOK=