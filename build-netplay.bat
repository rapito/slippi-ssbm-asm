@echo off


echo "Building Slippi.dat"
cd "m-ex\slippi\Hooks\"
cmd /c "build.bat"
cd "../../../"
echo.

echo Building netplay.json...
gecko build -c netplay.json -defsym "STG_EXIIndex=1"
echo.


pause