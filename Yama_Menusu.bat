@echo off
chcp 65001 >nul
cd /d "%~dp0"
title ROB RUN Turkce Yama Yoneticisi - YAF

if not exist "%~dp0install_patch.ps1" (
    echo [HATA] install_patch.ps1 dosyasi bulunamadi!
    pause
    exit /b 1
)

:menu
cls
echo ===============================================================
echo             ROB RUN - TURKCE YAMA (YAF SURUMU)
echo ===============================================================
echo.
echo   [1] Turkce Yamayi Kur
echo   [2] Turkce Yamayi Kaldir (Orijinal Haline Don)
echo   [3] Cikis
echo.
set "secim="
set /p secim="  Seciminiz (1/2/3): "

if "%secim%"=="1" (
    cls
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_patch.ps1"
    echo.
    pause
    goto menu
)

if "%secim%"=="2" (
    cls
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_patch.ps1" -Kaldir
    echo.
    pause
    goto menu
)

if "%secim%"=="3" (
    exit /b 0
)

goto menu
