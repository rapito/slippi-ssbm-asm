#!/bin/bash

echo Building netplay.json...
gecko build -c netplay.json -defsym "STG_EXIIndex=1" &
echo ""

echo "Building Slippi.dat"
cd ./m-ex/slippi/Hooks/
sh build.sh
cd ../../../
echo ""

echo Copying Slippi.dat...
cp "m-ex/slippi/Hooks/Slippi.dat" "/Users/robertperalta/Dev/github/Ishiiruka/build/Binaries/Slippi Dolphin.app/Contents/Resources/GameFiles/GALE01/"
echo Copying gecko codes...
cp "Output/Netplay/GALE01r2.ini" "/Users/robertperalta/Dev/github/Ishiiruka/build/Binaries/Slippi Dolphin.app/Contents/Resources/GameSettings/"