@echo off

if [%1]==[] goto ERROR1
if [%1]==[-cn] goto NET
if not exist %1:\backup goto ERROR2

robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\documents %1:\backup\docs
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\desktop %1:\backup\desktop
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\pictures %1:\backup\pics
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\videos %1:\backup\vids
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\favorites %1:\backup\favs
robocopy /purge /r:5 /w:3 %windir% %1:\backup\scripts *.txt
robocopy /purge /r:5 /w:3 %windir% %1:\backup\scripts *.cmd

goto END

:NET

net use t: \\edgefs\users\fhigman /persistent:no
if not exist t:\backup goto ERROR3
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\documents t:\backup\docs
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\desktop t:\backup\desktop
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\pictures t:\backup\pics
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\videos t:\backup\vids
robocopy /xjd /xa:sh /mir /r:5 /w:3 %userprofile%\favorites t:\backup\favs
robocopy /purge /r:5 /w:3 %windir% t:\backup\scripts *.txt
robocopy /purge /r:5 /w:3 %windir% t:\backup\scripts *.cmd
net use t: /d

goto END

:ERROR1

echo.
echo.
echo You forgot to give me the drive letter of the stick
echo.
echo Here are your choices
echo.
@wmic logicaldisk where drivetype=2 get description,name,volumename
echo.
echo.

goto END

:ERROR2

echo.
echo.
echo That might not be the right drive letter?
echo.
echo Here are your choices
echo.
@wmic logicaldisk where drivetype=2 get description,name,volumename
echo.
echo.

goto END

:ERROR3

echo.
echo.
echo It looks like there was some sort of drive mapping failure
echo.

goto END

:END