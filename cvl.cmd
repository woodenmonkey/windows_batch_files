@echo off
if [%1]==[] goto error
if [%1]==[e] goto IE
if [%1]==[s] goto spartan

:IE
cd/d "%userprofile%\appdata\local\microsoft\Internet Explorer\iecompatdata"
goto eof

:spartan
cd/d "%userprofile%\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\Microsoft\Internet Explorer\IECompatData"
goto eof

:error
echo.
echo.
echo This batch requires input
echo.
echo Include E for IE
echo.
echo Include S for Spartan
echo.
echo.
goto eof

:eof