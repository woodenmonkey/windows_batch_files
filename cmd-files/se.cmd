@ECHO off
ECHO.
tasklist | find /i "MicrosoftEdge"
if ERRORLEVEL 1 GOTO notloaded

ECHO.
set /p KillEdge=Maybe it's time to kill all these edge processes? (Y/N)
ECHO.
if %KillEdge%==y (
	goto kill
) ELSE (
	goto end
)

:kill
taskkill /im MicrosoftEdge.exe /f
taskkill /im MicrosoftEdgeCP.exe /f
GOTO END

:notloaded
ECHO.
ECHO Edge isn't loaded right now
ECHO.
ECHO.
ECHO.
:end
set KillEdge=