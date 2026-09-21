@echo off
rem Run the POSIX nav script under Git Bash.
rem Herdr executes Windows custom commands through cmd.exe, so this shim keeps
rem the shared logic in .config/herdr/scripts/nav (same script as macOS/Linux).
"%ProgramFiles%\Git\bin\bash.exe" "%~dp0nav" %*
