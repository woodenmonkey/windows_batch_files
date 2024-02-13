@Echo off
if [%1]==[l] goto local
if [%1]==[r] goto roaming
if [%1]==[] goto local

:local
cd /d %localappdata%
goto end

:roaming
cd /d %appdata%
goto end

:end
