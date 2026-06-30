@echo off
rem Set to 'false' to skip zipping and only keep the extracted folders in 'build/'
set ZIP_ENABLED=true

mkdir build

echo Building and packaging for linux/amd64...
set GOOS=linux
set GOARCH=amd64
if exist "build\telegram-sniffer-linux-amd64" rmdir /s /q "build\telegram-sniffer-linux-amd64"
mkdir "build\telegram-sniffer-linux-amd64\public"
go build -o "build\telegram-sniffer-linux-amd64\telegram-sniffer-linux-amd64" cmd\server\main.go
xcopy /E /I /Y public "build\telegram-sniffer-linux-amd64\public"
if exist .env copy .env build\telegram-sniffer-linux-amd64\
if not exist .env if exist .env.example copy .env.example build\telegram-sniffer-linux-amd64\
if "%ZIP_ENABLED%"=="true" (
    echo Creating zip for telegram-sniffer-linux-amd64...
    powershell -Command "Compress-Archive -Path 'build\telegram-sniffer-linux-amd64' -DestinationPath 'build\telegram-sniffer-linux-amd64.zip' -Force"
    echo Done: build\telegram-sniffer-linux-amd64.zip
) else (
    echo Skipped zipping. Files are in: build\telegram-sniffer-linux-amd64\
)

echo Building and packaging for linux/arm64...
set GOOS=linux
set GOARCH=arm64
if exist "build\telegram-sniffer-linux-arm64" rmdir /s /q "build\telegram-sniffer-linux-arm64"
mkdir "build\telegram-sniffer-linux-arm64\public"
go build -o "build\telegram-sniffer-linux-arm64\telegram-sniffer-linux-arm64" cmd\server\main.go
xcopy /E /I /Y public "build\telegram-sniffer-linux-arm64\public"
if exist .env copy .env build\telegram-sniffer-linux-arm64\
if not exist .env if exist .env.example copy .env.example build\telegram-sniffer-linux-arm64\
if "%ZIP_ENABLED%"=="true" (
    echo Creating zip for telegram-sniffer-linux-arm64...
    powershell -Command "Compress-Archive -Path 'build\telegram-sniffer-linux-arm64' -DestinationPath 'build\telegram-sniffer-linux-arm64.zip' -Force"
    echo Done: build\telegram-sniffer-linux-arm64.zip
) else (
    echo Skipped zipping. Files are in: build\telegram-sniffer-linux-arm64\
)

echo Building and packaging for windows/amd64...
set GOOS=windows
set GOARCH=amd64
if exist "build\telegram-sniffer-windows-amd64" rmdir /s /q "build\telegram-sniffer-windows-amd64"
mkdir "build\telegram-sniffer-windows-amd64\public"
go build -o "build\telegram-sniffer-windows-amd64\telegram-sniffer-windows-amd64.exe" cmd\server\main.go
xcopy /E /I /Y public "build\telegram-sniffer-windows-amd64\public"
if exist .env copy .env build\telegram-sniffer-windows-amd64\
if not exist .env if exist .env.example copy .env.example build\telegram-sniffer-windows-amd64\
if "%ZIP_ENABLED%"=="true" (
    echo Creating zip for telegram-sniffer-windows-amd64...
    powershell -Command "Compress-Archive -Path 'build\telegram-sniffer-windows-amd64' -DestinationPath 'build\telegram-sniffer-windows-amd64.zip' -Force"
    echo Done: build\telegram-sniffer-windows-amd64.zip
) else (
    echo Skipped zipping. Files are in: build\telegram-sniffer-windows-amd64\
)

echo Building and packaging for darwin/amd64...
set GOOS=darwin
set GOARCH=amd64
if exist "build\telegram-sniffer-macos-amd64" rmdir /s /q "build\telegram-sniffer-macos-amd64"
mkdir "build\telegram-sniffer-macos-amd64\public"
go build -o "build\telegram-sniffer-macos-amd64\telegram-sniffer-macos-amd64" cmd\server\main.go
xcopy /E /I /Y public "build\telegram-sniffer-macos-amd64\public"
if exist .env copy .env build\telegram-sniffer-macos-amd64\
if not exist .env if exist .env.example copy .env.example build\telegram-sniffer-macos-amd64\
if "%ZIP_ENABLED%"=="true" (
    echo Creating zip for telegram-sniffer-macos-amd64...
    powershell -Command "Compress-Archive -Path 'build\telegram-sniffer-macos-amd64' -DestinationPath 'build\telegram-sniffer-macos-amd64.zip' -Force"
    echo Done: build\telegram-sniffer-macos-amd64.zip
) else (
    echo Skipped zipping. Files are in: build\telegram-sniffer-macos-amd64\
)

echo Building and packaging for darwin/arm64...
set GOOS=darwin
set GOARCH=arm64
if exist "build\telegram-sniffer-macos-arm64" rmdir /s /q "build\telegram-sniffer-macos-arm64"
mkdir "build\telegram-sniffer-macos-arm64\public"
go build -o "build\telegram-sniffer-macos-arm64\telegram-sniffer-macos-arm64" cmd\server\main.go
xcopy /E /I /Y public "build\telegram-sniffer-macos-arm64\public"
if exist .env copy .env build\telegram-sniffer-macos-arm64\
if not exist .env if exist .env.example copy .env.example build\telegram-sniffer-macos-arm64\
if "%ZIP_ENABLED%"=="true" (
    echo Creating zip for telegram-sniffer-macos-arm64...
    powershell -Command "Compress-Archive -Path 'build\telegram-sniffer-macos-arm64' -DestinationPath 'build\telegram-sniffer-macos-arm64.zip' -Force"
    echo Done: build\telegram-sniffer-macos-arm64.zip
) else (
    echo Skipped zipping. Files are in: build\telegram-sniffer-macos-arm64\
)

echo.
if "%ZIP_ENABLED%"=="true" (
    echo Build complete! Ready-to-run zipped packages are in the 'build' directory:
    dir build\*.zip
) else (
    echo Build complete! Extracted folders are in the 'build' directory:
    dir build
)

pause
