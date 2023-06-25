@echo off
echo Building netplay.json...
gecko build -c netplay.json -defsym "STG_EXIIndex=1" -batched -warn
echo.

pause