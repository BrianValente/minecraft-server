#!/bin/sh -e

# If one of the folders starting with "world" has a file named "delete", delete the folder
find /app-data/world* -maxdepth 0 -type d -name 'world*' -exec sh -c 'cd "$0" && [ -f delete ]' '{}' \; -exec rm -rf '{}' \;

# Delete all .jar in /app-data/plugins
rm -rf /app-data/plugins/*.jar

# ProtectionStones
rm -rf /app-data/plugins/ProtectionStones

# Copy all files from /app/data inside /app-data, replacing if needed, recursively
cp -r /app/data/* /app-data/

# Start the server
eval "exec $CMD" 
