@echo off
setlocal enabledelayedexpansion

:: ==============================
::  MKV Conversion Script (v2)
::  Usage: conv.bat [input_folder] [output_folder]
:: ==============================

:: ---- 1. Input folder ----
if "%~1"=="" (
    cls
    echo.
    echo ===========================================
    echo  MKV Conversion Script
    echo ===========================================
    echo.
    set /p "INPUT_DIR=Enter input folder path (drag & drop supported): "
) else (
    set "INPUT_DIR=%~1"
)

if "!INPUT_DIR!"=="" (
    echo.
    echo Error: No input path entered.
    timeout /t 2 /nobreak >nul
    exit /b 1
)

:: Remove surrounding quotes if any
set "INPUT_DIR=!INPUT_DIR:"=!"
set "QUOTED_INPUT_DIR="!INPUT_DIR!""

:: Check if input folder exists
if not exist !QUOTED_INPUT_DIR! (
    echo.
    echo Error: Input folder does not exist.
    echo Entered path: !INPUT_DIR!
    timeout /t 3 /nobreak >nul
    exit /b 1
)

:: ---- 2. Output folder ----
if "%~2"=="" (
    set /p "OUTPUT_DIR=Enter output folder path (default = same as this script): "
    if "!OUTPUT_DIR!"=="" set "OUTPUT_DIR=%~dp0"
) else (
    set "OUTPUT_DIR=%~2"
)

:: Remove quotes if any
set "OUTPUT_DIR=!OUTPUT_DIR:"=!"
set "QUOTED_OUTPUT_DIR="!OUTPUT_DIR!""

:: Create output folder if it doesn't exist
if not exist !QUOTED_OUTPUT_DIR! (
    echo [Info] Output folder does not exist. Creating...
    mkdir !QUOTED_OUTPUT_DIR! >nul 2>&1
)

echo.
echo Input folder : !INPUT_DIR!
echo Output folder: !OUTPUT_DIR!
echo.
pause

:: ---- 3. Conversion process ----
set "FOUND=0"
for %%F in ("!INPUT_DIR!\*.mkv") do (
    set /a FOUND+=1
    echo.
    echo Processing: %%~nxF
    ffmpeg -i "%%F" -map 0:v -map 0:a -c:v hevc_nvenc -preset p4 -tune hq -cq 20 -profile:v main10 -pix_fmt p010le -maxrate 4M -bufsize 4M -f mp4 -c:a copy "!OUTPUT_DIR!\%%~nF.mp4" -y
    if errorlevel 1 (
        echo Error: Failed to convert %%~nxF
    ) else (
        echo Done: %%~nF.mp4
    )
)

:: ---- 4. Final message ----
if "!FOUND!"=="0" (
    echo.
    echo Warning: No .mkv files found in the specified folder.
) else (
    echo.
    echo All conversions completed.
)

pause
