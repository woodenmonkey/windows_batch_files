@echo off

ECHO This batch file shows you your build, branch, version, and the date you installed it.
ECHO Then it checks \\winbuilds\release for newer builds of the installed branch
ECHO All build folders found are checked for install media
ECHO.
ECHO If a newer version(s) is found you will be asked to start an unattended install of that version
ECHO.
ECHO If multiple newer versions are found you will be prompted to select a version to install
ECHO.
ECHO If a newer versions with no media is found you will see an offer to open the folder and es/ri
ECHO.
ECHO Build followed by a machine name will retrieve the build, branch and version installed on the remote machine
ECHO Build follwed by -c, will present a list of edge branches to install

SETLOCAL enabledelayedexpansion
SETLOCAL enableextensions

set B_TEMP=%TEMP%\BuildUpgrade_%RANDOM%
set B_LIST=%B_TEMP%\list.txt
set SHORTLIST=%B_TEMP%\shortlist.txt
set SORTEDLIST=%B_TEMP%\sortedlist.txt
set VALIDATED=%B_TEMP%\validated.txt
set SVALIDATED=%B_TEMP%\validatedbydate.txt
set CANDIDATES=%B_TEMP%\validatedcandidates.txt
set SCANDIDATES=%B_TEMP%\validatedcandidatesbydate.txt
set CHOICES=%B_TEMP%\choices.txt
set CHOSEN=%B_TEMP%\chosen.txt
set BRANCH_LIST=%B_TEMP%\branchlist.txt
set SKU=enterprise_en-us_vl
set TASKLIST=.

set B_SHARE=\\winbuilds\release
set CANDIDATE_THRESHOLD=1
set CHKFRE=fre
if [%2]==[] (
	set MAXITEMS=15
) ELSE (
	set MAXITEMS=%2
)

if not exist %B_TEMP% md %B_TEMP%

if [%1]==[] (
	goto LOCAL
)
if [%1]==[-c] (
	goto LOCAL
) else (
	goto REMOTE
)

:LOCAL

for /f "tokens=1-10" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildLab') do set BUILDLAB=%%c

for /f "tokens=1-10 delims=. " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildLab') do set IBUILD=%%c& set IBRANCH=%%d

for /f "tokens=1-10 delims=. " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildLabEx') do set IBUILD_FOLDER=%%c.%%d.%%g

for /f "tokens=1-10 delims=_" %%a in ("%IBRANCH%") do set RELEASE=%%a

echo.
echo %BUILDLAB%
echo.
@systeminfo | @find "Original Install Date:"

if not exist %B_SHARE%\%IBRANCH%\ goto NONET

REM ---------------------------------Switch banches----------------------------------------

if [%1]==[-c] (
	goto ORG
) ELSE (
	goto NEVERMIND
)

:ORG

if exist %B_LIST% (del %B_LIST%)
if exist %SHORTLIST% (del %SHORTLIST%)
if exist %SORTEDLIST% (del %SORTEDLIST%)
if exist %CHOICES% (del %CHOICES%)
if exist %CHOSEN% (del %CHOSEN%)
if exist %VALIDATED% (del %VALIDATED%)
if exist %SVALIDATED% (del %SVALIDATED%)
if exist %CANDIDATES% (del %CANDIDATES%)
if exist %SCANDIDATES% (del %SCANDIDATES%)

for /f "delims=" %%i IN ('dir %B_SHARE%\*edge* /b /ad-h') do echo %%i>> %B_LIST%
rem for /f "delims=" %%i IN ('dir %B_SHARE%\rs_edge* /b /ad-h') do echo %%i>> %B_LIST%
for /f %%i in ('find /V /C "" ^< %B_LIST%') do set ORG_BRANCHCOUNT=%%i

echo. >> %CHOICES%
echo ------------------------------------------------------------------------------>> %CHOICES%
echo.>> %CHOICES%
echo This is the current list of Edge branches>> %CHOICES%
echo.>> %CHOICES%

set NUM=0
for /f "delims=;" %%D in (%B_LIST%) do (
    if not "%%D"==" " (
        set /a NUM+=1
        echo [!NUM!] %%D>> %CHOICES%
        if !NUM!==%ORG_BRANCHCOUNT% goto ORGBRANCHES
    )
)

:ORGBRANCHES

echo.>> %CHOICES%
echo.>> %CHOICES%
echo [c] to enter another branch name>> %CHOICES%
echo [x] to exit>> %CHOICES%
echo.>> %CHOICES%
echo.>> %CHOICES%

type %CHOICES%

set /P SELECTION=Choose the branch you want:

find "[!SELECTION!]" < %CHOICES%> %CHOSEN%
if "%ERRORLEVEL%"=="1" (
    echo.
    echo Invalid choice
    echo.
    goto END
)

if %SELECTION%==x (
	goto END
)
if %SELECTION%==c (
	goto SWITCH
)
if %SELECTION% GEQ 1 (
	if %selection% LEQ %ORG_BRANCHCOUNT% (
		goto SETORG
	)
) ELSE (
	goto END
)

:SETORG
for /f "tokens=1-2" %%i in (%CHOSEN%) do set IBRANCH=%%j

if exist %CHOICES% (del %CHOICES%)
if exist %CHOSEN% (del %CHOSEN%)
if exist %B_LIST% (del %B_LIST%)

goto NEVERMIND

:SWITCH

if exist %B_LIST% (del %B_LIST%)
if exist %CHOICES% (del %CHOICES%)

for /f %%a in ('dir/ad/b %B_SHARE%\') do echo %%a>> %CHOICES%
echo [x] to exit>> %CHOICES%
echo x>> %CHOICES%

:RESWITCH
if exist %CHOSEN% (del %CHOSEN%)

echo.
echo.
set /P SELECTION=Type the branch name, or x to bail:

findstr /i /x "!SELECTION!" < %CHOICES%> %CHOSEN%

if "%ERRORLEVEL%"=="1" (
    echo.
    echo.
    echo Invalid branch name
    goto RESWITCH
)

if %SELECTION%==x (
	goto END
)

for /f "delims=" %%i in ("%selection%") do set IBRANCH=%%i

if exist %CHOICES% (del %CHOICES%)
if exist %CHOSEN% (del %CHOSEN%)

:NEVERMIND
		
REM -------------------------------------------------------------------------
REM Start sorting out which builds exist and whatnot

REM get the list of build folders, set the most recent folder

for /f %%i in ('dir/ad/b %B_SHARE%\%IBRANCH%\ ^| find /c /v ""') do set FOLDERCOUNT=%%i

if %MAXITEMS% GTR %FOLDERCOUNT% (
	set ITEMCOUNT=%FOLDERCOUNT%
) ELSE (
	set ITEMCOUNT=%MAXITEMS%
)

for /f "delims=" %%i IN ('dir %B_SHARE%\%IBRANCH%\ /b /ad-h /t:c /od') do echo %%i>> %B_LIST%& set RECENT_FOLDER=%%i

if not exist %B_LIST% (goto NOFOLDERS)

REM Sort the list of builds so we can loop through media checks
REM sort /r %B_LIST% > %SORTEDLIST%
REM then again.. why sort
for /f "delims=" %%i IN ('dir %B_SHARE%\%IBRANCH%\ /b /ad-h /t:c /o-d') do echo %%i>> %SORTEDLIST%

REM Shorten the lists
set NUM=0
for /f "delims=;" %%a in (%SORTEDLIST%) do (
    if not "%%a"==" " (
	set /a NUM+=1
	echo %%a>> %SHORTLIST%
	if !NUM!==%ITEMCOUNT% goto MEDIACHECK
    )
)

:MEDIACHECK

REM Check for setup.exe in the build folders for the current architecture

for /f "delims=" %%i IN (%SHORTLIST%) do if exist %B_SHARE%\%IBRANCH%\%%i\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\%SKU%\setup.exe echo %%i>> %VALIDATED%

REM Check that there were any

if not exist %VALIDATED% (goto NOBUILDS)

REM Re-sort the validated list again so we can find the most recent with avaliable media
sort %VALIDATED% > %SVALIDATED%

for /f "delims=." %%i IN (%SVALIDATED%) do set ABUILD=%%i
for /f "delims=" %%i IN (%SVALIDATED%) do set ABUILD_FOLDER=%%i
for /f "delims=." %%i IN (%B_LIST%) do set XBUILD=%%i
for /f "delims=" %%i IN (%B_LIST%) do set XBUILD_FOLDER=%%i

REM ------------------Switch Logic-----------------------
if [%1]==[-c] (
	for /f "delims=" %%a in (%SVALIDATED%) do echo %%a>> %CANDIDATES%
) ELSE (
	for /f "delims=" %%a in (%SVALIDATED%) do if %IBUILD_FOLDER% lss %%a (echo %%a>> %CANDIDATES%)
)

if [%1]==[-c] (
	goto UPGRADE
)
if %IBUILD_FOLDER% EQU %ABUILD_FOLDER% (
	goto CURRENT
)
if %ABUILD_FOLDER% LSS %IBUILD_FOLDER% (
	goto WOBBLE
) ELSE (
	goto UPGRADE
)

:UPGRADE

REM Find the number of candidate builds
for /f %%i in ('find /V /C "" ^< %CANDIDATES%') do set CANDIDATE_COUNT=%%i

if %ABUILD_FOLDER% LSS %XBUILD_FOLDER% (
	goto NOTREADY
)
if %ABUILD_FOLDER% EQU %XBUILD_FOLDER% (
	goto INSTALL
) ELSE (
	goto ERROR
)

:NOTREADY

REM resort the validated candidate list for display in the choices menu
sort /r %CANDIDATES% > %SCANDIDATES%

echo. >> %CHOICES%
echo ------------------------------------------------------------------------------>> %CHOICES%
echo.>> %CHOICES%

if [%1]==[-c] (
	if %CANDIDATE_COUNT% GTR %CANDIDATE_THRESHOLD% (
		if %ITEMCOUNT% EQU 1 (
			echo I found %CANDIDATE_COUNT% %IBRANCH% builds in the %ITEMCOUNT% build folder (this can't happen^)>> %CHOICES%
		) ELSE (
			echo I found %CANDIDATE_COUNT% %IBRANCH% builds in the most recent %ITEMCOUNT% build folders>> %CHOICES%
		)
	) ELSE (
		if %ITEMCOUNT% EQU 1 (
			echo I found %CANDIDATE_COUNT% %IBRANCH% build in the %ITEMCOUNT% build folder I could check>> %CHOICES%
		) ELSE (
			echo I found %CANDIDATE_COUNT% %IBRANCH% build in the most recent %ITEMCOUNT% build folders>> %CHOICES%
		)
	)
)

if [%1]==[] (
	if %CANDIDATE_COUNT% GTR %CANDIDATE_THRESHOLD% (
		echo I found %CANDIDATE_COUNT% newer %IBRANCH% builds>> %CHOICES%
	) ELSE (
		echo I found %CANDIDATE_COUNT% newer %IBRANCH% build>> %CHOICES%
	)
)

echo.>> %CHOICES%
echo Also, a recent build folder exists for %IBRANCH% %XBUILD%,>> %CHOICES%
echo but media isn't available for %PROCESSOR_ARCHITECTURE% yet..>> %CHOICES%
echo.>> %CHOICES%
echo.>> %CHOICES%
if %CANDIDATE_COUNT% GTR %CANDIDATE_THRESHOLD% (
	echo These are the %IBRANCH% builds with media available>> %CHOICES%
) ELSE (
	echo This is the %IBRANCH% build with media available>> %CHOICES%
)

echo.>> %CHOICES%

set NUM=0
for /f "delims=;" %%D in (%SCANDIDATES%) do (
    if not "%%D"==" " (
        set /a NUM+=1
        echo [!NUM!] %%D>> %CHOICES%
        if !NUM!==%ITEMCOUNT% goto CHOOSE
    )
)

:CHOOSE
echo.>> %CHOICES%
echo.>> %CHOICES%
echo [c] to check out %IBRANCH% build %XBUILD_FOLDER%>> %CHOICES%
echo [i] to install the most recent available (%ABUILD%)>> %CHOICES%
echo        or type the number of the build you'd like>> %CHOICES%
if [%1]==[-c] (
	echo [l] to go back to the list>>%CHOICES%
)
echo [x] to bail>> %CHOICES%
echo.>> %CHOICES%
echo.>> %CHOICES%

type %CHOICES%

set /P SELECTION=Choose:

find "[!SELECTION!]" < %CHOICES% > %CHOSEN%
for /f "tokens=1-2" %%i in (%CHOSEN%) do set TARGET=%%j
if "%ERRORLEVEL%"=="1" (
    echo.
    echo Invalid choice
    echo.
    goto END
)

if %SELECTION%==c (
	goto OPENFOLDER
)
if %SELECTION%==i (
	goto DOIT
)
if %SELECTION%==l (
	goto ORG
)
if %SELECTION%==x (
	goto END
)
if %SELECTION% GEQ 1 (
	if %selection% LEQ %CANDIDATE_COUNT% (
		goto DOOTHER
	)
) ELSE (
	goto END
)
 
goto END

:OPENFOLDER

if exist %B_SHARE%\%IBRANCH%\%RECENT_FOLDER%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media (
	start %B_SHARE%\%IBRANCH%\%RECENT_FOLDER%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media & goto STARTES
)
if exist %B_SHARE%\%IBRANCH%\%RECENT_FOLDER%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\ (
	start %B_SHARE%\%IBRANCH%\%RECENT_FOLDER%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\ & goto STARTES
) ELSE (
	start %B_SHARE%\%IBRANCH%\%RECENT_FOLDER%\
)

:STARTES

for /f "tokens=1-3 delims=." %%i IN ("%RECENT_FOLDER%") do (
	start https://es.microsoft.com/BranchAnalysis/#/ExecutionStatus?releaseName=%RELEASE%^&branchName=%IBRANCH%^&buildString=%IBRANCH%.%%i.%%j.20%%k
)

goto END

:INSTALL

if %CANDIDATE_COUNT% GTR %CANDIDATE_THRESHOLD% (
	goto STALE
)
if %CANDIDATE_COUNT% LSS %CANDIDATE_THRESHOLD% (
	goto NOBUILDS
)
if [%1]==[-c] (
	goto STALE
) ELSE (
	goto CONTINUEINSTALL
)

:CONTINUEINSTALL

echo.
echo ------------------------------------------------------------------------------
echo.
echo I found a newer build
echo.
echo You are running %IBRANCH% %IBUILD%
echo.
echo And %IBRANCH% %ABUILD% is available here:
echo.
echo %B_SHARE%\%IBRANCH%\%ABUILD_FOLDER%\%PROCESSOR_ARCHITECTURE%%CHKFRE%
echo.
set /P TASKLIST=Do you want to start an unattended install? (Y/N)

if %TASKLIST%==y (
	goto DOIT
)
if %TASKLIST%==Y (
	goto DOIT
) ELSE (
	goto END
)


:STALE

REM resort the validated candidate list for display in the choices menu
sort /r %CANDIDATES% > %SCANDIDATES%

echo. >> %CHOICES%
echo ------------------------------------------------------------------------------>> %CHOICES%
echo.>> %CHOICES%
if [%1]==[-c] (
	if %CANDIDATE_COUNT% GTR %CANDIDATE_THRESHOLD% (
		if %ITEMCOUNT% EQU 1 (
			echo I found %CANDIDATE_COUNT% %IBRANCH% builds in the %ITEMCOUNT% build folder (this can't happen^)>> %CHOICES%
		) ELSE (
			echo I found %CANDIDATE_COUNT% %IBRANCH% builds in the most recent %ITEMCOUNT% build folders>> %CHOICES%
		)
	) ELSE (
		if %ITEMCOUNT% EQU 1 (
			echo I found %CANDIDATE_COUNT% %IBRANCH% build in the %ITEMCOUNT% build folder I could check>> %CHOICES%
		) ELSE (
			echo I found %CANDIDATE_COUNT% %IBRANCH% build in the most recent %ITEMCOUNT% build folders>> %CHOICES%
		)
	)
)

if [%1]==[] (echo I found %CANDIDATE_COUNT% newer %IBRANCH% builds>> %CHOICES%)
echo.>> %CHOICES%
echo.>> %CHOICES%
if %CANDIDATE_COUNT% GTR %CANDIDATE_THRESHOLD% (
	echo These are the %IBRANCH% builds with media available>> %CHOICES%
) ELSE (
	echo This is the %IBRANCH% build with media available>> %CHOICES%
)
echo.>> %CHOICES%

set NUM=0
for /f "delims=;" %%D in (%SCANDIDATES%) do (
    if not "%%D"==" " (
        set /a NUM+=1
        echo [!NUM!] %%D>> %CHOICES%
        if !NUM!==%ITEMCOUNT% goto STALECHOOSE
    )
)

:STALECHOOSE
echo.>> %CHOICES%
echo.>> %CHOICES%
if [%BUILDERROR%] EQU [1] (
	echo.
) ELSE (
	echo [i] to install the most recent available (%ABUILD%^)>> %CHOICES%
)

if [%BUILDERROR%] EQU [1] (
	echo     Type the number of the build you'd like>> %CHOICES%
) ELSE (
	echo     or type the number of the build you'd like>> %CHOICES%
)
if [%1]==[-c] (
	echo [l] to go back to the list>>%CHOICES%
)
echo [x] to bail>> %CHOICES%
echo.>> %CHOICES%
echo.>> %CHOICES%

set BUILDERROR=

type %CHOICES%

set /P SELECTION=Choose:

find "[!SELECTION!]" < %CHOICES% > %CHOSEN%
for /f "tokens=1-2" %%i in (%CHOSEN%) do set TARGET=%%j
if "%ERRORLEVEL%"=="1" (
    echo.
    echo Invalid choice
    echo.
    goto END
)

if %SELECTION%==c (
	goto OPENFOLDER
)
if %SELECTION%==i (
	goto DOIT
)
if %SELECTION%==l (
	goto ORG
)
if %SELECTION%==x (
	goto END
)
if %SELECTION% GEQ 1 (
	if %selection% LEQ %CANDIDATE_COUNT% (
		goto DOOTHER
	)
) ELSE (
	goto END
)
 
goto END

:DOIT

echo.
echo Do it!!
echo.
start %B_SHARE%\%IBRANCH%\%ABUILD_FOLDER%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\%SKU%\setup.exe /unattend

goto END

:DOOTHER

echo.
echo Do it!!
echo.
start %B_SHARE%\%IBRANCH%\%TARGET%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\%SKU%\setup.exe /unattend

goto END

:REMOTE

for /f "tokens=1-10" %%a in ('reg query "\\%1\HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildLab') do set BUILDLAB=%%c
echo.
echo %BUILDLAB%
rem  @systeminfo /s %1 | @find "Original Install Date:"

goto END

:CURRENT

if %ABUILD_FOLDER% LSS %XBUILD_FOLDER% (goto CURRENTFORNOW)

echo.
echo ------------------------------------------------------------------------------
echo.
echo It looks like you have the current available build
echo.

goto END

:CURRENTFORNOW

echo.
echo ------------------------------------------------------------------------------
echo.
echo It looks like you have the current available build
echo.
echo Also, a recent build folder exists for %IBRANCH% %XBUILD%,
echo but media isn't available for %PROCESSOR_ARCHITECTURE% yet..
echo.
echo.

set /P TASKLIST=Do you want to check out build %XBUILD_FOLDER%? (Y/N)

if %TASKLIST%==y (
	goto OPENFOLDER
)
if %TASKLIST%==Y (
	goto OPENFOLDER
) ELSE (
	goto END
)

goto END

:NONET

echo.
echo ------------------------------------------------------------------------------
echo.
echo I tried to check for an updated build, but I can't get to the build share
echo.
echo Are you connected to CorpNet?
echo.

goto END

:NOBUILDS

echo.
echo ------------------------------------------------------------------------------
echo.
		if %ITEMCOUNT% EQU 1 (
			echo I didn't find install media in the %ITEMCOUNT% %IBRANCH% build folder I could check
		) ELSE (
			echo I didn't find install media in the last %ITEMCOUNT% %IBRANCH% build folders
		)
echo.
echo.
if %FOLDERCOUNT% GTR %MAXITEMS% (
	echo You could try increasing the maxitems variable (build -c #^)
	echo That will check more folders for media
)
echo.

goto END

:NOFOLDERS

echo.
echo ------------------------------------------------------------------------------
echo.
echo I couldn't get a list of build folders for some reason
echo.
echo It looks like you're on corpnet
echo.
echo You'll have to investigate manually
echo.

goto END

:WOBBLE

echo.
echo ------------------------------------------------------------------------------
echo.
echo I checked for an updated build, but I didn't find what I expected
echo.
echo You are running %IBRANCH% %IBUILD_FOLDER%, but the most recent build of %IBRANCH% I could find is %ABUILD_FOLDER%
echo.
echo That shouldn't be.. somthing might be wrong with the world.
echo.
echo I hope it's not bent...
echo.

goto END

:ERROR

set BUILDERROR=1

echo.
echo.
echo Something unexpected...
echo.
echo Generally, older build folders have the oldest build numbers
echo But in %IBRANCH% the largest build number isn't the most recent folder
echo.
echo Diagnostics:
echo BUILDLAB: %BUILDLAB%
echo IBUILD: %IBUILD%
echo IBRANCH: %IBRANCH%
echo ABUILD: %ABUILD%
echo XBUILD: %XBUILD%
echo IBUILD_FOLDER: %IBUILD_FOLDER%
echo ABUILD_FOLDER: %ABUILD_FOLDER%
echo XBUILD_FOLDER: %XBUILD_FOLDER%
echo RECENT_FOLDER: %RECENT_FOLDER%
echo TARGET: %TARGET%
echo CANDIDATE_THRESHOLD: %CANDIDATE_THRESHOLD%
echo CANDIDATE_COUNT: %CANDIDATE_COUNT%
echo ORG_BRANCHCOUNT: %ORG_BRANCHCOUNT%
echo TASKLIST: %TASKLIST%
echo B_SHARE: %B_SHARE%
echo B_TEMP: %B_TEMP%
echo B_LIST: %B_LIST%
echo SORTEDLIST: %SORTEDLIST%
echo CHOICES: %CHOICES%
echo BUILDERROR: %BUILDERROR%
echo NUM: %NUM%
echo CHKFRE: %CHKFRE%
echo SKU: %SKU%
echo MAXITEMS: %MAXITEMS%
echo FOLDERCOUNT: %FOLDERCOUNT%
echo ITEMCOUNT: %ITEMCOUNT%
echo RELEASE: %RELEASE%

echo.
echo.
set /p TASKLIST=Want to continue anyway? (Y/N)

if [%TASKLIST%]==[y] (
	goto INSTALL
)
if [%TASKLIST%]==[Y] (
	goto INSTALL
) ELSE (
	goto END
)

:END

if exist %B_TEMP% (
    rd /s /q %B_TEMP%
)

set BUILDLAB=
set IBUILD=
set IBRANCH=
set ABUILD=
set XBUILD=
set IBUILD_FOLDER=
set ABUILD_FOLDER=
set XBUILD_FOLDER=
set RECENT_FOLDER=
set TASKLIST=
set B_SHARE=
set B_TEMP=
set B_LIST=
set SORTEDLIST=
set CANDIDATE_THRESHOLD=
set CANDIDATE_COUNT=
set ORG_BRANCHCOUNT=
set TARGET=
set BUILDERROR=
set NUM=
set CHOICES=
set CHOSEN=
set CHKFRE=
set SKU=
set ITEMCOUNT=
set FOLDERCOUNT=
set MAXITEMS=
set RELEASE=

endlocal