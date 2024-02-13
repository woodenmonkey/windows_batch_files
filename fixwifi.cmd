@echo off
netsh int set int name= air0 admin= disabled 
pause
netsh int set int name= air0 admin= enabled 
