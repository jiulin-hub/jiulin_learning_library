@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0download-latest.ps1" %*
if errorlevel 1 echo Download failed. Read the PowerShell error above.
pause
