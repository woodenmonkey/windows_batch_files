@echo off
setlocal enabledelayedexpansion

:: Check if correct parameters are provided
if "%~1"=="" (
    echo Usage: split_csv_with_header.bat input_file.csv lines_per_file
    exit /b 1
)

set "input_file=%~1"
set "lines_per_file=%~2"
set "temp_file=temp_data.tmp"
set /a counter=1
set /a line_count=0

:: Check if file exists
if not exist "%input_file%" (
    echo File not found!
    exit /b 1
)

:: Extract header
set "header="
for /f "usebackq delims=" %%A in ("%input_file%") do (
    set "header=%%A"
    goto :get_data
)

:get_data
:: Remove existing temp file if exists
if exist "%temp_file%" del "%temp_file%"

:: Read file, skipping the first line (header)
set "skip_header=1"
for /f "usebackq delims=" %%A in ("%input_file%") do (
    if !skip_header! equ 1 (
        set "skip_header=0"
    ) else (
        echo %%A >> "%temp_file%"
    )
)

:: Split file into parts
for /f "delims=" %%A in (%temp_file%) do (
    if !line_count! equ 0 (
        set "outfile=%~n1-part-!counter!.csv"
        echo %header% > "!outfile!"
    )
    
    echo %%A >> "!outfile!"
    set /a line_count+=1

    if !line_count! geq %lines_per_file% (
        set /a counter+=1
        set /a line_count=0
    )
)

:: Clean up temp file
del "%temp_file%"

echo CSV split into smaller files with header retained.
exit /b 0
