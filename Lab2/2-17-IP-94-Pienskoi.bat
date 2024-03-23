set fileName=%1
set searchPath=D:\

cd /d %searchPath%
for /f "delims=" %%g in ('dir /b /s %fileName%') do set foundFilePath=%%~dpg

if exist "%foundFilePath%" (
	cd %foundFilePath%
    ML /Bl LINK16 %foundFilePath%%fileName%
) else (
    echo File not found
)
