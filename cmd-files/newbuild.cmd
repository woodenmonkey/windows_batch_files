@echo off

rem reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set bitness=86 || set bitness=64

rem reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "ARM" > NUL && set arch=arm|| set arch=amd

set CHKFRE=fre

for /f "tokens=1-10 delims=. " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildLab') do set ibuild=%%c& set ibranch=%%d
for /f "delims=" %%i IN ('dir \\winbuilds\release\%ibranch%\ /b /ad-h /t:c /od') do set recent_folder=%%i

if not exist \\winbuilds\release\%ibranch%\%recent_folder%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\enterprise_en-us_vl\setup.exe (
	goto NOTREADY
) ELSE (
	goto INSTALL
)

:NOTREADY

echo.
echo The most recent %ibranch% build folder is:
echo.
echo %recent_folder%
echo.
echo But it lacks %PROCESSOR_ARCHITECTURE%%CHKFRE% install media
echo.
set /P TASKLIST=Would you like to open the media folder in the build path and see? (Y/N)

if %TASKLIST%==y (
	goto CHECK
) ELSE (
	goto END
)

:CHECK
rem DIR \\winbuilds\release\%ibranch%\%recent_folder%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\
start \\winbuilds\release\%ibranch%\%recent_folder%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\

goto END

:INSTALL

echo.
echo Looks like we're good to go
echo.
set /P TASKLIST=%ibranch% %recent_folder% is available, Do you want to install %PROCESSOR_ARCHITECTURE%%CHKFRE%? (Y/N)

if %TASKLIST%==y (
	goto DOIT
) ELSE (
	goto END
)

:DOIT

start \\winbuilds\release\%ibranch%\%recent_folder%\%PROCESSOR_ARCHITECTURE%%CHKFRE%\media\enterprise_en-us_vl\setup.exe /unattend

:END
set recent_folder=
set TASKLIST=
set CHKFRE=
set ARCH=
set BITNESS=
set IBRANCH=
set IBUILD=
