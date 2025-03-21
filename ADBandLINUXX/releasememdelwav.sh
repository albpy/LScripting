#!/bin/bash

#ANDROID_FOLDER="/storage/emulated/0/files/"
ANDROID_FOLDER="/storage/emulated/0/Music/Recordings/Call\ Recordings/"
LOCAL_FOLDER="./audio_metadata"

mkdir -p "$LOCAL_FOLDER"

printf "$(adb shell ls "$ANDROID_FOLDER")"
# Set IFS to handle spaces in filenames

IFS=$'\n'

# Store file list in an array to avoid subshell issues
mapfile -t files < <(adb shell ls -1 "$ANDROID_FOLDER"/*.mp3 2>/dev/null | tr -d '\r')

# Store file list in a variable to avoid subshell issues
#files=$(adb shell ls "$ANDROID_FOLDER"/*.wav 2>/dev/null | tr -d '\r')
#while IFS= read -r file; do

for file in "${files[@]}"; do

#adb shell ls "$ANDROID_FOLDER"/*.wav | tr -d '\r' | while IFS= read -r file; do
        
        filename=$(basename "$file" | sed 's/\\//g')  # Remove backslashes
        
        echo "Processing: $filename"

        adb pull "$file" "$LOCAL_FOLDER/$filename"

        duration=$(ffprobe -i "$LOCAL_FOLDER/$filename" -show_entries format=duration -v quiet -of csv="p=0")
        duration=${duration%.*}

        if [ "$duration" -lt 180 ]; then
                echo "Deleting $filename (Duration: ${duration}s)"
                rm "$LOCAL_FOLDER/$filename"
                adb shell "rm \"$file\"" || true
        else
                echo "Keeping $filename (Duration: ${duration}s)"
                rm "$LOCAL_FOLDER/$filename"
        fi      
done 

echo "Done!"
