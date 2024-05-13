@echo off

setlocal enabledelayedexpansion

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

set PATH=%PATH%;C:\Program Files (x86)\Edge Task Manager\
start "EdgeTaskMgr" EdgeTaskMgr.exe

goto END

:32BIT

set PATH=%PATH%;C:\Program Files\Edge Task Manager\
start "EdgeTaskMgr" EdgeTaskMgr.exe

:END
exit