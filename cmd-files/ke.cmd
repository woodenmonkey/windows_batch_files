@echo off

echo.
for /f %%i in ('tasklist ^| find /c "explorer.exe"') do set PCOUNT=%%i

if [%PCOUNT%] EQU [0] (
	goto ASK
) ELSE (
	goto NEXT
)

:NEXT

tasklist | find /i "explorer.exe"
echo.
set /p KILLIT=How about we kill explorer.exe (Y/N)
echo.

if %KILLIT%==y (
	goto KILL
)
if %KILLIT%==Y (
	goto KILL
) ELSE (
	goto END
)

:KILL

echo.
echo.
echo Killing explorer.exe

taskkill /im explorer.exe /f

echo.
echo.
echo.
echo.


:ASK
set /P RESTART=Would you like restart explorer again? (Y/N)

if %RESTART%==y (
	goto START
)
if %RESTART%==Y (
	goto START
) ELSE (
	goto END
)


:START
echo.
echo.
start explorer.exe

:END

set RESTART=
set KILLIT=