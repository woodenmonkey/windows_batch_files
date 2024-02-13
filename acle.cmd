@echo off
if [%1]==[1] goto edge
if [%1]==[2] goto applyall
if [%1]==[0] goto remove
if [%1]==[3] goto nuke
if [%1]==[c] goto clear
if [%1]==[] goto error1

:edge
checknetisolation loopbackexempt -a -p=S-1-15-2-3624051433-2125758914-1423191267-1740899205-1073925389-3782572162-737981194-2385269614-3243675-834220592-3047885450
goto eof

:applyall
checknetisolation loopbackexempt -a -p=S-1-15-2-242350657-3959402886-270292430-1225993453-2592757292-4162947980-553669249
checknetisolation loopbackexempt -a -p=S-1-15-2-1430448594-2639229838-973813799-439329657-1197984847-4069167804-1277922394
checknetisolation loopbackexempt -a -p=S-1-15-2-3624051433-2125758914-1423191267-1740899205-1073925389-3782572162-737981194-4256926629-1688279915-2739229046-3928706915
checknetisolation loopbackexempt -a -p=S-1-15-2-3624051433-2125758914-1423191267-1740899205-1073925389-3782572162-737981194-2385269614-3243675-834220592-3047885450
goto eof

:remove
checknetisolation loopbackexempt -d -p=S-1-15-2-3624051433-2125758914-1423191267-1740899205-1073925389-3782572162-737981194-2385269614-3243675-834220592-3047885450
goto eof

:nuke
checknetisolation loopbackexempt -d -p=S-1-15-2-242350657-3959402886-270292430-1225993453-2592757292-4162947980-553669249
checknetisolation loopbackexempt -d -p=S-1-15-2-1430448594-2639229838-973813799-439329657-1197984847-4069167804-1277922394
checknetisolation loopbackexempt -d -p=S-1-15-2-3624051433-2125758914-1423191267-1740899205-1073925389-3782572162-737981194-2385269614-3243675-834220592-3047885450

:clear
checknetisolation loopbackexempt -c
goto eof

:error1
echo.
echo.
echo This batch needs inputs to make changes, otherwise it just shows the ACs with exemptions (below)
echo. 
echo Here are your choices
echo. 
echo A value of 1 will apply the loopback exemption to:
echo The IE MRAC and LRAC ACs, and the Edge Intranet and MRAC RACs
echo.
echo A value of 0 will remove the loopback exemption from:
echo The IE MRAC and LRAC ACs, and the Edge Intranet  and MRAC RACs
echo.
echo A value of 2 will apply the loopback exemption to:
echo Edge MRAC only
echo.
echo A value of C, will clear all exemptions
echo.
echo ___________________________________________________________
echo.
echo These are the appcontainers that currently have exemptions
echo.
checknetisolation loopbackexempt -s
:EOF