@echo off

if [%1]==[] (
	goto ADDDIRECTORY
)
if [%1]==[-r] (
	goto READ
)
if [%1]==[-d] (
	goto DELETE
)
if [%1]==[-l] (
	goto LOWLABEL
) ELSE (
	goto FILE
)

:FILE

( echo [ZoneTransfer] && echo ZoneId=3 && echo ReferrerUrl=https://www.techmeme.com/ && echo HostUrl=https://blog.mozilla.org/blog/2018/04/03/nothing-really-to-see-here-maybe/ ) > %1:Zone.Identifier

goto END

:READ

@streams "%~2" | find "Zone.Identifier" > Nul
if [%errorlevel%]==[0] (
	echo.
	more < "%~2:Zone.Identifier"
) ELSE (
	echo.
	echo No Zone.Identifier stream found
)

goto END

:DELETE

if [%2]==[] goto DELETEDIRECTORY

streams -d "%~2"

goto END

:DELETEDIRECTORY

echo.
echo.
set /P TASKLIST=Would you like to remove MOTW from everything in this directory? (Y/N)

if %TASKLIST%==y (
	goto PROCEEDDELETE
)
if %TASKLIST%==Y (
	goto PROCEEDDELETE
) ELSE (
	goto NOPE
)

:PROCEEDDELETE

for /f "delims==" %%a in ('dir/b') do streams -d "%%a"

goto END

:ADDDIRECTORY

echo.
echo.
set /P TASKLIST=Would you like to set MOTW on all files in this directory? (Y/N)

if %TASKLIST%==y (
	goto PROCEEDADD
)
if %TASKLIST%==Y (
	goto PROCEEDADD
) ELSE (
	goto NOPE
)

:PROCEEDADD

for /f "delims==" %%a in ('dir /a-d-s /b') do ( echo [ZoneTransfer] && echo ZoneId=3 && echo ReferrerUrl=https://www.techmeme.com/ && echo HostUrl=https://blog.mozilla.org/blog/2018/04/03/nothing-really-to-see-here-maybe/ ) > "%%a:Zone.Identifier"
REM for /f "delims==" %%a in ('dir /a-d-s /b') do echo %%a >> file.txt
echo.

goto END

:LOWLABEL

rem icacls "%2" /setintegritylevel (OI)(CI)low
icacls "%2" /setintegritylevel l

goto END

:NOPE
echo.
echo.
echo Pulled back from the brink...
echo.

goto END

:END
set TASKLIST=