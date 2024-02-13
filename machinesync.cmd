@echo off 

if [%1]==[] goto ERROR1
if [%2]==[a] goto ADMIN
if [%1]==[-cn] goto NET
if [%1]==[-cna] goto NETADMIN
if not exist %1:\backup goto ERROR2

robocopy /xj /mir /R:0 /W:0 %1:\backup\docs %userprofile%\documents
robocopy /xj /mir /R:0 /W:0 %1:\backup\pics %userprofile%\pictures
robocopy /xj /mir /R:0 /W:0 %1:\backup\vids %userprofile%\videos
robocopy /xj /mir /R:0 /W:0 %1:\backup\favs %userprofile%\favorites
robocopy /xj /mir /R:0 /W:0 %1:\backup\desktop %userprofile%\desktop

goto EOF

:ADMIN

robocopy /purge %1:\backup\scripts %windir% *.txt
robocopy /purge %1:\backup\scripts %windir% *.cmd

goto EOF

:NETADMIN

net use t: \\iefs\users\%username% /persistent:no
if not exist t:\backup goto ERROR3
robocopy t:\utils\SysInternalsSuite %windir%\system32
robocopy t:\utils\tools %windir%\system32
robocopy /purge t:\backup\scripts %windir% *.txt
robocopy /purge t:\backup\scripts %windir% *.cmd
net use t: /d

goto EOF

:NET

net use t: \\iefs\users\%username% /persistent:no
if not exist t:\backup goto ERROR3
robocopy /xj /mir /R:0 /W:0 t:\backup\docs %userprofile%\documents
robocopy /xj /mir /R:0 /W:0 t:\backup\pics %userprofile%\pictures
robocopy /xj /mir /R:0 /W:0 t:\backup\vids %userprofile%\videos
robocopy /xj /mir /R:0 /W:0 t:\backup\favs %userprofile%\favorites
robocopy /xj /mir /R:0 /W:0 t:\backup\desktop %userprofile%\desktop
net use t: /d

goto EOF

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
goto EOF

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

goto EOF

:ERROR3

echo.
echo.
echo I think some sort of network drive map problem happened
echo.

:EOF