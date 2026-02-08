#!/bin/sh

# Configuration
REPO="Shaifhassan/open-report-cli-release"
BINARY_NAME="open_report.exe" # Or "open_report" for Linux/Mac

echo "Fetching latest release from $REPO..."

# 1. Get the download URL for the latest release asset
# This uses the GitHub 'latest' redirect to find the right file
DOWNLOAD_URL="https://github.com/$REPO/releases/latest/download/$BINARY_NAME"

# 2. Download the file
curl -L -o "$BINARY_NAME" "$DOWNLOAD_URL"

# 3. Make it executable (for Linux/Mac users)
chmod +x "$BINARY_NAME"

echo "Successfully installed $BINARY_NAME"