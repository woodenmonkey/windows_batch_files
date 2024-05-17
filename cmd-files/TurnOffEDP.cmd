::
:: Script Configuration
::
@if NOT "%_ECHO%"=="1" echo off
@SETLOCAL
@set SRCDIR=%~dp0
@for /f "tokens=3,4,5,6,7,8 delims=. " %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -v BuildLabEx') do (
  @set BUILDNUMBER=%%a
  @set BUILDVERSION=%%b
  @set BUILDARCH=%%c
  @set BUILDBRANCH=%%d
  @set BUILDDATETIME=%%e
)
@for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -v EditionID') do (
  @set EDITIONID=%%a
)
@for /f "tokens=3" %%a in ('net config workstation ^| findstr /c:"Workstation domain"') do (
  @set MACHINEDOMAIN=%%a
)
@set LOCALAUDITLOG=%windir%\EDP-%COMPUTERNAME%.csv
@set WINDIR_EDP=%windir%\EDP
@set LOGINFO=%USERNAME%,%USERDOMAIN%,%COMPUTERNAME%,%MACHINEDOMAIN%,%BUILDNUMBER%,%BUILDVERSION%,%BUILDARCH%,%BUILDBRANCH%,%BUILDDATETIME%,%EDITIONID%,-1,%~n0
@set ISWMIBRIDGEENROLLED=0


::
:: Start Turning Off EDP
::
@echo %DATE%,%TIME%,%LOGINFO%,%AUDITLOG%,START >> %LOCALAUDITLOG%
@echo.
@echo.
@echo Turning Off Enterprise Data Protection ...


::
:: Make sure this is being run as SYSTEM
::
@if NOT "%USERNAME:~-1%"=="$" (
  @set EXITMSG=Wrong script...Please run the %SRCDIR%EDPTurnOff.cmd instead.
  @goto :error
)


::
:: Make sure this is being run from an elevated command shell
::
@if EXIST %windir%\is-elevated ( rd %windir%\is-elevated)
@md %windir%\is-elevated > NUL 2>&1
@if ERRORLEVEL 1 (
  @set EXITMSG=You must run this script from an elevated command prompt.
  @goto :error
)
@rd %windir%\is-elevated > NUL 2>&1


::
:: Delete EDP Force Opt-in Registry Key
::
@reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EFS" /v EdpPolicyFilter /f > NUL 2>&1
::@if ERRORLEVEL 1 (
::  @set EXITMSG=Unable to delete EDP Force Opt-in Registry Key.
::  @goto :error
::)


::
:: Add Disable Remote Copy Encryption Registry Key
::
@reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\EFS" /v EdpDisableRemoteCopyEncryption /t REG_DWORD /d 1 /f
::@if ERRORLEVEL 1 (
::  @set EXITMSG=Unable to add Disable Remote Copy Encryption registry key.
::  @goto :error
::)


::
:: Turn Off Enterprise Data Protection
::
@PowerShell -ExecutionPolicy unrestricted -command "%~dpn0.ps1 -ScriptDate '%DATE%' -ScriptTime '%TIME%' -ScriptLogInfo '%LOGINFO%' -ScriptLogFile '%LOCALAUDITLOG%'"> NUL 2>&1
@if ERRORLEVEL 1 (
  @set EXITMSG=Unable to turn off Enterprise Data Protection.
  @goto :error
)


::
:: Delete Disable Remote Copy Encryption Registry Key
::
@reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\EFS" /v EdpDisableRemoteCopyEncryption /f
::@if ERRORLEVEL 1 (
::  @set EXITMSG=Unable to delete Disable Remote Copy Encryption registry key.
::  @goto :error
::)


::
:: Block EDP from being re-enabled on the machine
::
@reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EFS" /v EdpPolicyFilter /t REG_DWORD /d 0 /f > NUL 2>&1
@if ERRORLEVEL 1 (
  @set EXITMSG=Unable to block EDP from being re-enabled on the machine.
  @goto :error
)


::
:: Delete EDP Marker Folder
::
@rd /s /q %WINDIR_EDP% > NUL 2>&1


::
:: Enable the option for users NOT managed by MDM WMI Bridge enrollment to enroll in Device Management
::
@reg query hklm\software\microsoft\enrollments /s | findstr /i /c:"EnrollmentType    REG_DWORD    0xc" > NUL 2>&1
@if %ERRORLEVEL%==0 (
  @set ISWMIBRIDGEENROLLED=1
)
@if %ISWMIBRIDGEENROLLED%==0 (
  @reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Enrollments" /v ExternallyManaged /t REG_DWORD /d 0 /f > NUL 2>&1
)
::@if ERRORLEVEL 1
::  @set EXITMSG=Unable to enable the option for users NOT managed by MDM WMI Bridge enrollment to enroll in Device Management.
::  @goto :error
::)


::
:: Success
::
@echo.
@echo Successfully Turned Off Enterprise Data Protection.
@echo %DATE%,%TIME%,%LOGINFO%,%AUDITLOG%,SUCCESS >> %LOCALAUDITLOG%
@echo.
@exit /B 0


::
:: Error Exit
::
:error
@echo %EXITMSG%
@echo %DATE%,%TIME%,%LOGINFO%,%AUDITLOG%,FAILURE,%EXITMSG% >> %LOCALAUDITLOG%
@exit /B 1


::
:: Error Exit No Log
::
:errornolog
@echo %EXITMSG%
@exit /B 1