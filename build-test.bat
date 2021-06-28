@echo off
echo Building test.json...
gecko build -c test.json -defsym "STG_EXIIndex=1"
echo.

pause