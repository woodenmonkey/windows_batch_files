@echo off

  for /f "tokens=1-4 delims=/ " %%i in ("%date%") do set DT=%%i_%%j.%%k.%%l
  for /f "tokens=1-4 delims=:." %%a in ("%time%") do set TM=_%%a.%%b.%%c
::  set TM=%TM::=-%
  set DTT=%DT%%TM%

if [%2]==[-s] (
	goto SUFFIX
) ELSE (
	goto PREFIX
)

:PREFIX
echo %DTT%
ren %1 %DTT%-%1
goto EOF

:SUFFIX
ren %1 %~n1-%DTT%%~x1
goto EOF

:EOF
set DT=
set TM=
set DTT=