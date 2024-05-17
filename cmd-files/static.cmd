@echo off

set /p REALLY=Set the static IP 1.1.1.1 on all your interfaces? (Y/N)

if [%REALLY%]==[n] (goto END)
if [%REALLY%]==[N] (goto END)

for /f "skip=3 tokens=1-4" %%a in ('netsh int show int') do netsh int ip set addr %%d s 1.1.1.1 255.255.255.255
echo Set static addresses
echo.

:END