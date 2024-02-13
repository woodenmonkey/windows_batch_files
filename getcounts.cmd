@echo off

SETLOCAL enabledelayedexpansion

if [%1]==[] (
	set TARGET=\\winbuilds\release
) ELSE (
	set TARGET=%~1
)

if exist counts.txt (
	if exist %windir%\df.cmd (
		@call df counts.txt -s
	)
)

for /f %%i in ('dir/ad/b "%TARGET%" ^| find /c /v ""') do set WORK=%%i

for /f %%a in ('dir/od/ad/b "%TARGET%"') do (
	echo %~n0: !WORK! %%a
	set NAME=%%a
	if exist "%TARGET%\%%a\" (
		dir/ad/b "%TARGET%\%%a\" | find /c /v "" > %tmp%\c.txt
		) ELSE (
		echo -1 > %tmp%\c.txt
		)
	set /p COUNT= < %tmp%\c.txt
	echo !NAME! !COUNT! >> counts.txt
	set /a WORK-=1
)

if exist %tmp%\c.txt (del %tmp%\c.txt)
set NAME=
set COUNT=
set WORK=
set TARGET=