@echo off
setlocal

set "psScriptPath=%~dp0uninstalljob.ps1"

:: Check if running as admin
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo Running as admin...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~0' -Verb RunAs"
    exit /b
)

:: Run the PowerShell script with Bypass ExecutionPolicy
powershell -ExecutionPolicy Bypass -File "%psScriptPath%"

endlocal
pause