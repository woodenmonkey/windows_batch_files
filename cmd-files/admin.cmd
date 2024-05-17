@echo off

SETLOCAL enabledelayedexpansion

net localgroup administrators | find "REDMOND\fhigman" > nul

if %errorlevel% EQU 1 (
	echo.
	set /P CHOOSE=Looks like you are not an administrator, want to be ^(Y/N^)?
		if [!CHOOSE!]==[y] (
			net localgroup administrators redmond\fhigman /add
			echo.
			goto END
		) ELSE (
			echo.
			goto END
		)
) ELSE (
	echo.
	set /P CHOOSE=Looks like you are an administrator, want to give that up ^(Y/N^)?
		if [!CHOOSE!]==[y] (
			net localgroup administrators redmond\fhigman /del
			echo.
			goto END
		) ELSE (
			echo.
			goto END
		)
)
	


:END

set CHOOSE=

::net localgroup administrators redmond\fhigman %1