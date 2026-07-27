@echo off
echo.
echo Really...?
echo.
echo You sure you want to date all these files?
echo.
Pause
for /f "delims=" %%a in ('dir/a-d/b') do df "%%a"
