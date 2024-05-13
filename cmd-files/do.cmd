@echo off
for /f %%a in (%1) do systeminfo /s %%a | @find "System Up Time:"