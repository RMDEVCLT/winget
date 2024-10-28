@echo off
setlocal

set "psScriptPath=%~dp0WingetAdminSearchV2.ps1"

:: Run the PowerShell script with Bypass ExecutionPolicy
powershell -ExecutionPolicy Bypass -File "%psScriptPath%"

endlocal
pause