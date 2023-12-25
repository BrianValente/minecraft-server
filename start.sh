#!/bin/sh -e

# If one of the folders starting with "world" has a file named "delete", delete the folder
find /app-data/world* -maxdepth 0 -type d -name 'world*' -exec sh -c 'cd "$0" && [ -f delete ]' '{}' \; -exec rm -rf '{}' \;

# Delete all .jar in /app-data/plugins
rm -rf /app-data/plugins/*.jar

# ProtectionStones
rm -rf /app-data/plugins/ProtectionStones

# server.properties
rm /app-data/server.properties*

# Copy all files from /app/data inside /app-data, replacing if needed, recursively
cp -r /app/data/* /app-data/

# Merge server.properties
if [ -f /app-data/server.properties.$ENVIRONMENT ]; then
    cat /app-data/server.properties /app-data/server.properties.$ENVIRONMENT > /app-data/server.properties.tmp
    mv /app-data/server.properties.tmp /app-data/server.properties
fi

# Delete server.properties.*
rm /app-data/server.properties.*

# Start the server
eval "exec $CMD" 
