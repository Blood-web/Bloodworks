#!/bin/bash

# Check for 3 args
if [ $# -ne 3 ]; then
    echo "Usage: $0 <line_number> <file_name> <new_content>"
    exit 1
fi

line_number=$1
file_name=$2
new_content=$3
old_line=$(read_line $line_number $file_name)

# Check for file
if [ ! -f "$file_name" ]; then
    echo "File not found: $file_name"
    exit 1
fi

# Replace | Report Failure
if ! sed -i "${line_number}s/.*/$new_content/" "$file_name"; then
    echo "Error replacing line $line_number in $file_name"
    exit 1
fi

#echo -e "Replacing Line $line_number in $file_name: \"$old_line\" -> replaced with: \"$new_content\""
