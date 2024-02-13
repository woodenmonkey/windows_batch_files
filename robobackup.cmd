@echo off
for /f %%a in (%systemroot%\robobackup.txt) do robocopy %userprofile%\%%a %1\%%a /xj /mir
robocopy %systemroot% %1\scripts *.cmd
robocopy %systemroot% %1\scripts *.txt
robocopy c:\drives %1\drives /mir