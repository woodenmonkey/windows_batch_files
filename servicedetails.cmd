@ECHO OFF
for /f "tokens=1-2 delims= " %%a in ('"sc queryex state= all | find "SERVICE_NAME""') do sc qc %%b