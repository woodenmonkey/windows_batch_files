@echo off
for /f %%a in ('dir/b ex09%1*') do echo %%a >> count%2.txt & elcg %%a >> count%2.txt" 
