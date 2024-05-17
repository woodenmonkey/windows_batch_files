@echo off

@net use * /d /y

@net use H: \\blag\users\%username% /persistent:no > nul
@net use I: \\palador\images /persistent:no >nul
@net use K: \\palador\company /persistent:no > nul
@net use M: \\blag\management$ /persistent:no > nul
rem @net use U: \\blag\users /persistent:no > nul
@net use s: \\smash\machines /persistent:no > nul
@net use u: \\smash\d$ /persistent:no > nul
@net use V: \\flash\d$ /persistent:no > nul

echo Mapped H to home
echo Mapped I to images
echo Mapped K to company
echo Mapped M to management
echo Mapped S to smash machines
echo Mapped U to smash d:
echo Mapped V to flash d:
@echo.
@echo.
echo and sadly, cage and rage are no more...