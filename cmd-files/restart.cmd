@echo off 
      if ["%~1"]==[""] (
        goto LOCAL
) ELSE (
	goto REMOTE
)

:LOCAL

shutdown -r -t 0 

goto END

:REMOTE

shutdown -r -m \\%1 -t 0 -f -c "remote administration" -d p:0:0

:END