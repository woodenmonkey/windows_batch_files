if exist %tmp%\drives.txt del %tmp%\drives.txt
@for /f %%a in ('"dsquery computer ou=servers,dc=watermark,dc=local -limit 1000 -o rdn | sort"') do ping %%~a -n 1 && ( echo %%~a >> %tmp%\drives.txt & psinfo -d  \\%%~a | find "NTFS" >> %tmp%\drives.txt & echo ............ >> %tmp%\drives.txt )
start %tmp%\drives.txt
