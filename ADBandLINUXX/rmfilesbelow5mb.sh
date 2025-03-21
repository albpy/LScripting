#!/bin/bash
for file in /storage/emulated/0/Music/Recordings/Call\ Recordings/*; do
    if test -f "$file" && [ $(stat -c%s "$file") -lt 5242880 ]; then
        rm "$file"
    fi
done

