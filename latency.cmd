@echo off

  for /f "Tokens=1-4 Delims=/ " %%i in ('date /t') do set   dt=%%i-%%j-%%k-%%l
  for /f "Tokens=1" %%i in ('time /t') do set tm=-%%i
  set tm=%tm::=-%
  set dtt=%dt%%tm%

	pathping %1 > path-%computername%-%dtt%.txt
rem	tracert %1 > trace-"%computername%-%dtt%.txt