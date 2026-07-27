if exist %tmp%\whoson.txt del %tmp%\whoson.txt
@for /f %%a in ('"dsquery computer -limit 1000 -o rdn | sort"') do ping %%~a -n 1 && ( echo %%~a >> %tmp%\whoson.txt & quser /server:%%~a >> %tmp%\whoson.txt )
start %tmp%\whoson.txt
