@echo off
@echo off
for /f %%a in ('type %systemroot%\batchlist.txt') do copy %systemroot%\%%a \\%1\admin$