@Echo off 
if [%1]==[] goto error
if [%2]==[] goto error
if [%2]==[r] goto read
if [%2]==[w] goto write
if [%2]==[wa] goto writeall
if [%2]==[set] goto set
if [%2]==[ren] goto rename

:read
more < %1:Build.Info
goto eof

:write
dir/b %1 > %1:Build.Info
goto eof

:writeall
for /f %%a in ('"dir/b *.vhd | find /v "selfhost""') do dir/b %%a > %%a:Build.Info
goto eof

:set
dir/b %1 > %1:Build.Info
ren %1 selfhost.vhd
goto eof

:rename
for /f %%a in (%1:Build.Info) do set bi=%%a
ren %1 %bi%
set bi=
goto eof

:error
echo.
echo.
echo Read the info, or write the info?
echo.
echo Include r to read, or w to write
echo.
echo Include set to rename to selfhost.vhd and ren to name it back
echo.
echo These are the vhd's you have to work with
echo.
dir/b *.vhd
echo.
goto eof

:eof