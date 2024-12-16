#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_DIR="$SCRIPT_DIR/.."
ASSETS_DIR="$PROJECT_DIR/assets"
VOICE_DATA_URL="https://switchboard-sdk-public.s3.amazonaws.com/assets/Voicemod/3.12.1/VoiceData.zip"
VOICE_DATA_FOLDER="VoiceData"
ZIP_FILE="VoiceData.zip"

mkdir -p "$ASSETS_DIR"

pushd "$ASSETS_DIR"

# Remove previous VoiceData folder if it exists
if [ -d "$VOICE_DATA_FOLDER" ]; then
    echo "Removing previous $VOICE_DATA_FOLDER folder..."
    rm -rf "$VOICE_DATA_FOLDER"
fi

# Download VoiceData.zip
echo "Downloading VoiceData.zip..."
curl -O "$VOICE_DATA_URL"

# Unzip the downloaded file
echo "Unzipping $ZIP_FILE..."
unzip "$ZIP_FILE" -d .

# Remove the zip file after extraction
echo "Removing $ZIP_FILE..."
rm "$ZIP_FILE"

echo "Done!"

popd