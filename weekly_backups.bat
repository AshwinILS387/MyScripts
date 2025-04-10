@echo off
setlocal enabledelayedexpansion

:: Check if source and destination parameters are provided
if "%1"=="" (
    echo ERROR: Source folder is not specified.
    echo Usage: backup.bat ^<SourcePath^> ^<DestinationPath^>
    pause
    exit /b
)

if "%2"=="" (
    echo ERROR: Destination folder is not specified.
    echo Usage: backup.bat ^<SourcePath^> ^<DestinationPath^>
    pause
    exit /b
)

:: Set the source and destination to the provided parameters
set SOURCE=%1
set DESTINATION=%2

echo SOURCE: %SOURCE%
echo SOURCE: %DESTINATION%

if not exist "%DESTINATION%" mkdir "%DESTINATION%"

:: Get the current date and time, formatted as YYYY-MM-DD_HH-MM-SS
:: ('"wmic os get localdatetime /value"') = LocalDateTime=20250409121557.079000+330
::
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set DATE=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%
set TIME=%datetime:~8,2%-%datetime:~10,2%-%datetime:~12,2%

set FOLDER_NAME=%DATE%_%TIME%

echo DATE: %DATE%
echo TIME: %TIME%
echo FOLDERNAME: %FOLDER_NAME%

:: Create a new folder with the current date and time inside the destination folder
set NEW_FOLDER=%DESTINATION%\%FOLDER_NAME%
mkdir "%NEW_FOLDER%"

:: Copy all files from the source folder to the new folder
:: \*: The * (asterisk) is a wildcard character that matches all files and folders within the source directory. This means you're copying everything in the source folder.
:: \, which is required to denote the folder where the files will go.
xcopy "%SOURCE%\*" "%NEW_FOLDER%\" /s /e /h /y

:: Get a list of all the backup folders in the destination folder
set BACKUP_COUNT=0
set BACKUP_LIST=

:: Gather all backup folders
for /d %%D in ("%DESTINATION%\*") do (
    set /a BACKUP_COUNT+=1
    set BACKUP_LIST=!BACKUP_LIST! "%%D"
)

echo EXISTING BACKUPS: !BACKUP_COUNT!

:: If there are more than 2 backups, delete the older ones
if !BACKUP_COUNT! gtr 2 (
    echo More than 2 backups found. Deleting backups older than the 2 most recent...

    set DEL_COUNT=0
    set KEEP_COUNT=0
    for /f "tokens=*" %%F in ('dir "%DESTINATION%" /b /ad /o-d') do (
        if !KEEP_COUNT! lss 2 (
            set /a KEEP_COUNT+=1
        ) else (
            echo Deleting backup folder: %%F
            rd /s /q "%DESTINATION%\%%F"
        )
    )
)

echo Backup completed.
pause