@echo off
echo ========================================
echo ETH Portfolio Tracker - Demo Launcher
echo ========================================

echo.
echo Starting Python Backend...
echo.
start "ETH Backend" cmd /c "cd /d d:\Projects\eth_backend && python main.py"

echo Waiting for backend to start...
timeout /t 5 >nul

echo.
echo Starting Flutter Frontend...
echo.
cd /d d:\Projects\ethfront
flutter run -d web

echo.
echo Demo completed!
pause