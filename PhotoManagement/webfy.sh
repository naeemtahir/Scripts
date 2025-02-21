#!/bin/bash

# Function for usage instructions
usage() {
    echo "Strips EXIF data, shrinks to given width, and renames image files."
    echo "Usage: $(basename "$0") <width (0 for no resize)> <file_counter (0 for no rename)>"
    exit 1
}

# Function for validating if string is a number
isNumber() {
    [[ $1 =~ ^[0-9]+$ ]] && return 0 || return 1
}

set -e
if [ "$#" -eq 2 ]; then
    if ! isNumber "$1"; then echo 'Width should be a number.'; usage; fi
    if ! isNumber "$2"; then echo 'File counter should be a number.'; usage; fi

    width=$1
    file_counter=$2
    prefix=$(cat /dev/urandom | tr -dc 'A-Z' | fold -w 4 | head -n 1)
    OLD_IFS="$IFS"
    IFS=$'\n'

    for file in $(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort); do
        fext="${file##*.}"
        mogrify -strip -auto-orient "$file"

        if [ "$width" -gt 0 ]; then
            mogrify -resize $width -verbose "$file"
        fi

        new_filename=$(printf "%s_%06d.%s" "$prefix" "$file_counter" "$fext")

        if [ "$2" -gt 0 ]; then
            mv -iv "$file" "$new_filename"
        fi

        file_counter=$((file_counter+1))
    done

    IFS="$OLD_IFS"
else
    usage
fi
