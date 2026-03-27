#!/bin/bash

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null
then
    echo "❌ ffmpeg is not installed. Please install it first."
    exit 1
fi

# Check input
if [ -z "$1" ]; then
    echo "Usage: $0 <file-or-directory>"
    exit 1
fi

INPUT="$1"

convert_file () {
    FILE="$1"
    OUTPUT="${FILE%.*}.mp3"

    echo "🎵 Converting: $FILE -> $OUTPUT"
    ffmpeg -y -i "$FILE" -vn -ar 44100 -ac 2 -b:a 192k "$OUTPUT"
}

# If input is a file
if [ -f "$INPUT" ]; then
    convert_file "$INPUT"

# If input is a directory
elif [ -d "$INPUT" ]; then
    for file in "$INPUT"/*.mp4a; do
        [ -e "$file" ] || continue
        convert_file "$file"
    done
else
    echo "❌ Invalid input: $INPUT"
    exit 1
fi

echo "✅ Done!"