@echo off
:: Enable delayed variable expansion for safe variable usage within loops
setlocal enabledelayedexpansion

:: Ask for input file path
set /p input_file="Enter the input file path (e.g., C:\path\to\file.mp4): "

:: Remove any leading or trailing quotes (if entered by mistake)
set "input_file=%input_file:"=%"

:: Get the directory and file name from the input file path
for %%f in ("%input_file%") do (
    set "input_dir=%%~dpf"
    set "input_filename=%%~nxf"
)

:: Create the output file path with 'compressed' at the beginning of the file name
set "output_file=!input_dir!compressed_!input_filename!"

:: Ask the user to choose the compression rate (80%, 60%, or 40%)
echo Choose the compression rate:
echo 1. 80%% (default)
echo 2. 60%%
echo 3. 40%%
set /p compression_option="Enter the number of your choice (1/2/3): "

:: Set the compression rate based on the user's choice
if "!compression_option!"=="1" (
    set /a compression_rate=80
) else if "!compression_option!"=="2" (
    set /a compression_rate=60
) else if "!compression_option!"=="3" (
    set /a compression_rate=40
) else (
    echo Invalid option selected. Defaulting to 80%%.
    set /a compression_rate=80
)

:: Detect the original bitrate and other video properties using FFmpeg
for /f "tokens=*" %%a in ('ffmpeg -i "!input_file!" 2^>^&1 ^| findstr /r "bitrate"') do (
    set "original_bitrate=%%a"
)

:: Extract the numerical bitrate from the FFmpeg output
for /f "tokens=3 delims= " %%b in ("!original_bitrate!") do set "bitrate_value=%%b"

:: Optional: Print original bitrate (you can remove this if you want to keep the script clean)
echo Original Bitrate: !bitrate_value!

:: Calculate target bitrate based on the chosen compression rate
set /a target_bitrate=!bitrate_value! * !compression_rate! / 100

:: Optional: Print target bitrate
echo Target Bitrate: !target_bitrate!

:: Run FFmpeg command to compress the video using the calculated target bitrate
ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i "!input_file!" -c:v hevc_nvenc -preset p1 -b:v !target_bitrate! -c:a copy "!output_file!"

:: Pause to see the result
pause
