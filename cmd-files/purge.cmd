@echo off
echo.
echo You're a young man
echo Don't do it!!
echo.

if [%1]==[-f] goto FILES
if [%1]==[-d] goto DIRS

set /P KILLEMALL=Purge everything in this folder? (Y/N)

if %KILLEMALL%==y (
	goto KILL
)
if %KILLEMALL%==Y (
	goto KILL
) ELSE (
	goto BAIL
)

:KILL

attrib -h -r -s *
del/q/a *
for /f "tokens=*" %%a in ('dir/b/ad') do rd/q/s "%%a"

goto END

:FILES

set /P KILLEMALL=Purge all files in this folder? (Y/N)

if %KILLEMALL%==y (
	goto KILLFILES
)
if %KILLEMALL%==Y (
	goto KILLFILES
) ELSE (
	goto BAIL
)

:KILLFILES

for /f "delims=" %%a in ('dir/a-d/b') do del /f /q "%%a"

goto END

:DIRS

set /P KILLEMALL=Purge all directories in this folder? (Y/N)

if %KILLEMALL%==y (
	goto KILLDIRS
)
if %KILLEMALL%==Y (
	goto KILLDIRS
) ELSE (
	goto BAIL
)

:KILLDIRS

for /f "delims=" %%a in ('dir/b/ad') do rd/q/s "%%a"

goto END

:BAIL

echo.
echo.
echo You made the smart play here...
echo.

:END

set KILLEMALL=