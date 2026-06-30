#!/bin/bash

# Set to 'false' to skip zipping and only keep the extracted folders in 'build/'
ZIP_ENABLED=true

# Create build directory
mkdir -p build

# Function to build and package
build_and_package() {
    local os=$1
    local arch=$2
    local dir_name=$3
    local binary_name=$4
    local zip_name=$5

    echo "Building for ${os}/${arch}..."
    
    # Create build directory for this platform
    local build_dir="build/${dir_name}"
    rm -rf "${build_dir}"
    mkdir -p "${build_dir}/public"
    
    # Build binary
    GOOS=${os} GOARCH=${arch} go build -o "${build_dir}/${binary_name}" cmd/server/main.go
    
    # Copy public folder
    cp -r public/* "${build_dir}/public/"
    
    # Copy .env if exists, else .env.example
    if [ -f ".env" ]; then
        cp .env "${build_dir}/"
    elif [ -f ".env.example" ]; then
        cp .env.example "${build_dir}/"
    fi
    
    # Create zip if ZIP_ENABLED is true
    if [ "$ZIP_ENABLED" = "true" ]; then
        echo "Creating zip for ${dir_name}..."
        cd build
        zip -r "${zip_name}.zip" "${dir_name}"
        cd ..
        
        echo "Done: build/${zip_name}.zip"
    else
        echo "Skipped zipping. Files are in: ${build_dir}/"
    fi
}

build_and_package linux amd64 telegram-sniffer-linux-amd64 telegram-sniffer-linux-amd64 telegram-sniffer-linux-amd64
build_and_package linux arm64 telegram-sniffer-linux-arm64 telegram-sniffer-linux-arm64 telegram-sniffer-linux-arm64
build_and_package windows amd64 telegram-sniffer-windows-amd64 telegram-sniffer-windows-amd64.exe telegram-sniffer-windows-amd64
build_and_package darwin amd64 telegram-sniffer-macos-amd64 telegram-sniffer-macos-amd64 telegram-sniffer-macos-amd64
build_and_package darwin arm64 telegram-sniffer-macos-arm64 telegram-sniffer-macos-arm64 telegram-sniffer-macos-arm64

echo ""
if [ "$ZIP_ENABLED" = "true" ]; then
    echo "Build complete! Ready-to-run zipped packages are in the 'build' directory:"
    ls -la build/*.zip
else
    echo "Build complete! Extracted folders are in the 'build' directory:"
    ls -la build/
fi
