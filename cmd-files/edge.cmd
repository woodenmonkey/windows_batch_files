@echo off

SETLOCAL enabledelayedexpansion

set T_TEMP=%TEMP%\EdgeProcesses_%RANDOM%
set CHOICES=%T_TEMP%\choices.txt
set CHOSEN=%T_TEMP%\chosen.txt
set ETM=\\iefs\users\alexgl\Tools\EdgeTaskMgr
set TASKLIST=.

for /f %%a in ('quser ^| find /c /v "USERNAME"') do set SESSIONS=%%a
for /f "tokens=1-4" %%a in ('quser ^| find "%username%"') do set SESSIONID=%%c

if not exist %T_TEMP% md %T_TEMP%

echo.
for /f %%i in ('tasklist ^| find "MicrosoftEdge.exe" ^| find /c "Console"') do set MCOUNT=%%i
if %SESSIONS% GTR 1 (
	for /f %%i in ('tasklist ^| find "MicrosoftEdge.exe" ^| find /c /v "Console"') do set OSMCOUNT=%%i
) ELSE (
	set OSMCOUNT=0
)
echo Manager Count %MCOUNT%

echo.
for /f %%i in ('tasklist ^| find "browser_broker.exe" ^| find /c "Console"') do set BCOUNT=%%i
if %SESSIONS% GTR 1 (
	for /f %%i in ('tasklist ^| find "browser_broker.exe" ^| find /c /v "Console"') do set OSBCOUNT=%%i
) ELSE (
	set OSBCOUNT=0
)
echo Broker Count %BCOUNT%

echo.
for /f %%i in ('tasklist ^| find "MicrosoftEdgeSH.exe" ^| find /c "Console"') do set HCOUNT=%%i
if %SESSIONS% GTR 1 (
	for /f %%i in ('tasklist ^| find "MicrosoftEdgeSH.exe" ^| find /c /v "Console"') do set OSHCOUNT=%%i
) ELSE (
	set OSHCOUNT=0
)
echo Jit Host Count %HCOUNT%

echo.
for /f %%i in ('tasklist ^| find "MicrosoftEdgeCP.exe" ^| find /c "Console"') do set CCOUNT=%%i
if %SESSIONS% GTR 1 (
	for /f %%i in ('tasklist ^| find "MicrosoftEdgeCP.exe" ^| find /c /v "Console"') do set OSCCOUNT=%%i
) ELSE (
	set OSCCOUNT=0
)
echo Content Process Count %CCOUNT%

if %MCOUNT%==0 (
	goto UNLOADED
) ELSE (
	goto NEXT
)

:NEXT

echo.>> %CHOICES%
echo.>> %CHOICES%
echo [l] to see a process list>> %CHOICES%
echo [t] to start Edge Task Manager>> %CHOICES%
echo [k] to kill Edge from the top down>> %CHOICES%
if [%1]==[-d] echo [d] to see the debug data>> %CHOICES%
echo [x] to bail>> %CHOICES%
echo.>> %CHOICES%
echo.>> %CHOICES%
if %MCOUNT% GTR 1 (
	echo Too many manager processes^^!^^!  There should be only one^^!>> %CHOICES%
	echo.>> %CHOICES%
	echo.>> %CHOICES%
)
if %BCOUNT% GTR 1 (
	echo Too many broker processes^^!^^!  There should be only one^^!>> %CHOICES%
	echo.>> %CHOICES%
	echo.>> %CHOICES%
)
if %SESSIONS% GTR 1 (
	if %OSMCOUNT% EQU 1 (
		echo %OSMCOUNT% manager process instance is running under the context of another logged in user>> %CHOICES%
		echo.>> %CHOICES%
		echo.>> %CHOICES%
	) ELSE (
		if %OSMCOUNT% GTR 1 (
			echo %OSMCOUNT% manager process instances are running under the context of another logged in user>> %CHOICES%
			echo.>> %CHOICES%
			echo.>> %CHOICES%
		)		
	)
)


type %CHOICES%

set /P SELECTION=Chose and push enter:

find "[!SELECTION!]" < %CHOICES% > %CHOSEN%
if "%errorlevel%"=="1" (
    echo.
    echo.
    echo Invalid choice
    goto END
)

if %SELECTION%==l (
	goto LIST
)
if %SELECTION%==t (
	goto TASKMANAGER
)
if %SELECTION%==k (
	goto KILL
)
if %SELECTION%==d (
	goto DEBUG
)
if %SELECTION%==x (
	goto END
)

:LIST

echo.
echo.
tasklist | find "MicrosoftEdge" | find "Console"

goto END

:KILL

for /f "tokens=1-2" %%i in ('tasklist ^| find "MicrosoftEdge.exe" ^| find "Console"') do  taskkill /pid %%j /f
timeout /t 2
for /f "tokens=1-2" %%i in ('tasklist ^| find "MicrosoftEdgeCP.exe" ^| find "Console"') do  taskkill /pid %%j /f
for /f "tokens=1-2" %%i in ('tasklist ^| find "MicrosoftEdgeSH.exe" ^| find "Console"') do  taskkill /pid %%j /f
for /f "tokens=1-2" %%i in ('tasklist ^| find "browser_broker.exe" ^| find "Console"') do  taskkill /pid %%j /f

goto END

:UNLOADED
echo.
echo.
echo The manager isn't loaded right now..

if %SESSIONS% GTR 1 (
	if %OSMCOUNT% EQU 1 (
		echo.
		echo %OSMCOUNT% manager process instance is running under the context of another logged in user
		echo.>> %CHOICES%
		echo.>> %CHOICES%
	) ELSE (
		if %OSMCOUNT% GTR 1 (
			echo.
			echo %OSMCOUNT% manager process instances are running under the context of another logged in user
			echo.>> %CHOICES%
			echo.>> %CHOICES%
		)		
	)
)
echo.

goto END

:TASKMANAGER

if [%PROCESSOR_ARCHITECTURE%]==[AMD64] (
	goto 64BIT
)
if [%PROCESSOR_ARCHITECTURE%]==[x86] (
	goto 32BIT
)
if [%PROCESSOR_ARCHITECTURE%]==[ARM64] (
	goto 64BIT
)
if [%PROCESSOR_ARCHITECTURE%]==[ARM32] (
	goto 32BIT
) ELSE (
	goto END
)

:64BIT

if exist "%SYSTEMDRIVE%\Program Files (x86)\Edge Task Manager\" (
	goto CHECK64
) ELSE (
	goto INSTALL
)

:CHECK64

for /f %%a in ('dir "%SYSTEMDRIVE%\Program Files (x86)\Edge Task Manager" ^| find "EdgeTaskMgr.exe"') do set ETMIVER=%%a

if exist %ETM% (
	for /f %%a in ('dir %ETM% ^| find /i "EdgeTaskMgr.msi"') do set ETMAVER=%%a
) ELSE (
	goto START
)

set SDATE1=%ETMIVER:~-4%%ETMIVER:~0,2%%ETMIVER:~3,2%
set SDATE2=%ETMAVER:~-4%%ETMAVER:~0,2%%ETMAVER:~3,2%

if %SDATE2% GTR %SDATE1% (
	goto UPGRADE
) ELSE (
	goto START
)

goto END

:32BIT

if exist "%SYSTEMDRIVE%\Program Files\Edge Task Manager\" (
	goto CHECK32
) ELSE (
	goto INSTALL
)

:CHECK32

for /f %%a in ('dir "%SYSTEMDRIVE%\Program Files\Edge Task Manager" ^| find "EdgeTaskMgr.exe"') do set ETMIVER=%%a

if exist %ETM% (
	for /f %%a in ('dir %ETM% ^| find /i "EdgeTaskMgr.msi"') do set ETMAVER=%%a
) ELSE (
	goto START
)

set SDATE1=%ETMIVER:~-4%%ETMIVER:~0,2%%ETMIVER:~3,2%
set SDATE2=%ETMAVER:~-4%%ETMAVER:~0,2%%ETMAVER:~3,2%

if %SDATE2% GTR %SDATE1% (
	goto UPGRADE
) ELSE (
	goto START
)

goto END

:START

if [%1]==[-d] (goto DEBUG)

echo.
start etm.cmd

goto END

:INSTALL

if not exist %ETM% (goto NOETM)

echo.
set /P TASKLIST=Edge Task Manager isn't where it should be, do you want to install it? (Y/N)
echo.

if %TASKLIST%==y (
	%ETM%\EdgeTaskMgr.msi
)
if %TASKLIST%==Y (
	%ETM%\EdgeTaskMgr.msi
) ELSE (
	goto END
)

:UPGRADE

if [%1]==[-d] (goto DEBUG)

echo.
set /P TASKLIST=It looks like there might be a newer version. Want to install? (Y/N)
echo.

if %TASKLIST%==y (
	%ETM%\EdgeTaskMgr.msi
)
if %TASKLIST%==Y (
	%ETM%\EdgeTaskMgr.msi
) ELSE (
	goto END
)

goto END

:NOETM

echo.
echo Edge Task Manager isn't where it should be, and I couldn't get to the install share
echo.
echo Sorry

goto END

:DEBUG

echo.
echo MCOUNT: %MCOUNT%
echo BCOUNT: %BCOUNT%
echo HCOUNT: %HCOUNT%
echo CCOUNT: %CCOUNT%
echo OSMCOUNT: %OSMCOUNT%
echo OSBCOUNT: %OSBCOUNT%
echo OSHCOUNT: %OSHCOUNT%
echo OSCCOUNT: %OSCCOUNT%
echo SESSIONS: %SESSIONS%
echo SESSIONID: %SESSIONID%
echo TASKLIST: %TASKLIST%
echo ETMIVER: %ETMIVER%
echo ETMAVER: %ETMAVER%
echo SDATE1: %SDATE1%
echo SDATE2: %SDATE2%
echo SELECTION: %SELECTION%
echo T_TEMP: %T_TEMP%
echo CHOICES: %CHOICES%
echo CHOSEN: %CHOSEN%
echo ETM: %ETM%

:END

if exist %T_TEMP% (
    rd /s /q %T_TEMP%
)

set MCOUNT=
set BCOUNT=
set CCOUNT=
set HCOUNT=
set OSMCOUNT=
set OSBCOUNT=
set OSHCOUNT=
set OSCCOUNT=
set TASKLIST=
set ETM=
set ETMIVER=
set ETMAVER=
set SDATE1=
set SDATE2=
set SELECTION=
set T_TEMP=
set CHOICES=
set CHOSEN=
set SESSIONS=
set SESSIONID=