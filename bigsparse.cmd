@echo off
for /f %%a in ('dir/b ex09%1*') do echo %%a >> count%3.txt & lc %%a %2 >> count%3.txt" 
