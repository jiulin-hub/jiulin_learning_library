@echo off
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0download-latest.ps1" %*
set "rc=%errorlevel%"
if not "%rc%"=="0" echo Download failed. Read the PowerShell error above.
pause
exit /b %rc%
