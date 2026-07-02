@echo off
echo ==========================================
echo Firebase Final Collections Creator
echo ==========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://python.org
    pause
    exit /b 1
)

echo Python found. Installing required packages...
echo.

REM Install required packages
pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo ERROR: Failed to install required packages
    pause
    exit /b 1
)

echo.
echo Running the collection creation script...
echo.

REM Run the Python script
python create_final_collections.py

echo.
echo Script execution completed.
pause
