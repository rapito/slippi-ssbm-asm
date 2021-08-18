@echo off


echo "Building Slippi.dat"
cd "m-ex\slippi\Hooks\"
cmd /c "build.bat"
cd "../../../"
echo.

echo Building netplay.json...
gecko build -c netplay.json -defsym "STG_EXIIndex=1"
echo.

echo "Copying Slippi.dat..."
copy ".\m-ex\slippi\Hooks\Slippi.dat" "C:\Users\rober\Documents\Dev\Github\Ishiiruka\Binary\x64\Sys\GameFiles\GALE01\"
echo "Copying gecko codes..."
copy ".\Output\Netplay\GALE01r2.ini" "C:\Users\rober\Documents\Dev\Github\Ishiiruka\Binary\x64\Sys\GameSettings\"


pause