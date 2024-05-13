@echo off

@net use * /d /y

@net use H: \\blag\users\%username% /persistent:no > nul
@net use I: \\palador\images /persistent:no > nul
@net use K: \\palador\company /persistent:no > nul
@net use L: \\palador\demoshowcase /persistent:no > nul
@net use M: \\blag\management$ /persistent:no > nul
@net use s: \\smash\machines /persistent:no > nul

echo Mapped H to home
echo Mapped I to palador images
echo Mapped K to company
echo Mapped L to Contoso project
echo Mapped M to Management share
echo Mapped S to Smash

rem echo Mapped M to flip c:
rem echo Mapped N to flip d:

@echo.
@echo.
echo and sadly, cage and rage are no more...