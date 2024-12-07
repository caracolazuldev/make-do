#!/bin/sh

# Check if the version argument is provided
if [ $# -ne 1 ]; then
  echo "Error: Version argument is required"
  exit 1
fi

# Get the version number from the argument
version_number=$1

# Define the comment header format
# define in parts to avoid matching this file
format_prefix="Make-do Makefile Library"
format_suffix="Version:"
header_format="$format_prefix $format_suffix"

# Find all files in the repo that contain the header
echo "grep -rl $header_format ."
for file in $(grep -rl "$header_format" .); do
  echo "Updating version in $file"
  sed -E "s/($header_format) ([0-9]+\.[0-9]+\.[0-9]+)/\1 $version_number/" --in-place "$file"
done
