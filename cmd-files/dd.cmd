@echo off

  for /f "tokens=1-4 delims=/ " %%i in ("%date%") do set DT=%%i_%%j.%%k.%%l
  for /f "tokens=1-4 delims=:." %%a in ("%time%") do set TM=_%%a.%%b.%%c
  set DTT=%DT%%TM%

move %1 %dtt%-%1

set DT=
set TM=
set DTT=