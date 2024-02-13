@echo off
if [%1]==[] goto error1
if [%1]==[1] goto apply
if [%1]==[0] goto remove

:apply
checknetisolation loopbackexempt -a -p=S-1-15-2-242350657-3959402886-270292430-1225993453-2592757292-4162947980-553669249
checknetisolation loopbackexempt -a -p=S-1-15-2-1430448594-2639229838-973813799-439329657-1197984847-4069167804-1277922394
goto eof

:remove
checknetisolation loopbackexempt -d -p=S-1-15-2-242350657-3959402886-270292430-1225993453-2592757292-4162947980-553669249
checknetisolation loopbackexempt -d -p=S-1-15-2-1430448594-2639229838-973813799-439329657-1197984847-4069167804-1277922394
goto eof

:error1
echo.
echo.
echo This batch needs inputs to work
echo. 
echo Here are your choices
echo. 
echo A value of 1 will apply the loopback exemption to both the MRAC and LRAC ACs
echo A value of 0 will remove the loopback exemption from the MRAC and LRAC
echo.
echo These are the appcontainers that currently have exemptions
echo.
checknetisolation loopbackexempt -s
:EOF