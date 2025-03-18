@echo off
setlocal enabledelayedexpansion

:: Check if correct parameters are provided
if "%~1"=="" (
    echo Usage: split_csv_with_header.bat input_file.csv lines_per_file
    exit /b 1
)

set "input_file=%~1"
set "lines_per_file=%~2"
set /a counter=1

:: Check if file exists
if not exist "%input_file%" (
    echo File not found!
    exit /b 1
)

:: Read header
for /f "delims=" %%A in ('powershell -command "(Get-Content '%input_file%' | Select-Object -First 1)"') do set "header=%%A"

:: Get total number of lines (excluding header)
for /f %%A in ('powershell -command "(Get-Content '%input_file%' | Measure-Object -Line).Lines - 1"') do set total_lines=%%A

:: Create temporary file without header
powershell -command "(Get-Content '%input_file%' | Select-Object -Skip 1) | Set-Content 'temp_data.csv'"

:: Split the file
for /f "delims=" %%A in ('powershell -command "[System.IO.File]::ReadLines('temp_data.csv') | ForEach-Object {$_}"') do (
    echo %%A >> "temp_part_!counter!.csv"
    set /a line_count+=1
    if !line_count! GEQ %lines_per_file% (
        set /a counter+=1
        set line_count=0
    )
)

:: Add header to each part
for /f "tokens=*" %%F in ('dir /b temp_part_*.csv') do (
    echo %header% > "split_part_!counter!.csv"
    type "%%F" >> "split_part_!counter!.csv"
    del "%%F"
    set /a counter+=1
)

:: Clean up
del temp_data.csv

echo CSV split into smaller files with header retained.
exit /b 0
