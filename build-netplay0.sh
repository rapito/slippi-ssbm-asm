#!/bin/bash
echo Building netplay.json...
gecko build -c netplay.json -defsym "STG_EXIIndex=1"
gecko build -c netplay0.json -defsym "STG_EXIIndex=1"
echo ""
