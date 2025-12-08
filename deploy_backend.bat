echo ===================================================
echo Deploying Backend Functions for Law Genie...
echo ===================================================

:: Ensure we are in the script's directory (Project Root)
cd /d "%~dp0"

cd backend_functions

echo.
echo Installing dependencies...
call npm install

echo.
echo Deploying to Firebase...
call firebase deploy --only functions

echo.
echo ===================================================
echo Deployment Process Complete.
echo Please check the output above for any errors.
echo ===================================================
pause
