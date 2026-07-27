@echo off
for /f "skip=3 tokens=1-4" %%a in ('netsh int show int') do netsh int ip set addr "%%d" dhcp & netsh int ip set dns "%%d" dhcp & netsh int ip set wins "%%d" dhcp
echo Set all interfaces to DHCP
echo.
