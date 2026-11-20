@echo off
chcp 65001 >nul
cd /d "%~dp0"
title ROB RUN Turkce Yama Kaldirici - YAF

if not exist "%~dp0install_patch.ps1" (
    echo [HATA] install_patch.ps1 dosyasi bulunamadi!
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_patch.ps1" -Kaldir

echo.
pause
