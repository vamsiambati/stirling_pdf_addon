#!/bin/sh

setup_persistent_dir() {
    local src="$1"  # e.g., /data/configs
    local dest="$2" # e.g., /configs
    
    echo "Setting up persistence from $dest to $src..."
    
    # Ensure source directory exists
    mkdir -p "$src"
    
    # Copy contents if the source directory is empty
    if [ -d "$dest" ] && [ -z "$(ls -A "$src" 2>/dev/null)" ]; then
        echo "Copying default files from $dest to $src..."
        cp -rn "$dest"/* "$src"/ 2>/dev/null || true
    fi
    
    # If destination exists and is not already a symbolic link pointing to src
    if [ -d "$dest" ] && [ "$(readlink -f "$dest")" != "$src" ]; then
        # Attempt to delete destination directory
        rm -rf "$dest" 2>/dev/null
    fi
    
    # If destination directory was successfully removed, or didn't exist, create symlink
    if [ ! -e "$dest" ]; then
        ln -s "$src" "$dest"
        echo "Successfully symlinked $dest -> $src"
    else
        # If it's a mount point and couldn't be deleted:
        echo "$dest is a mount point. Attempting bind mount..."
        mount --bind "$src" "$dest" 2>/dev/null || {
            echo "Bind mount failed. Symlinking individual files..."
            # Symlink files individually from src to dest
            for item in "$src"/*; do
                if [ -e "$item" ]; then
                    local name=$(basename "$item")
                    rm -rf "$dest/$name"
                    ln -s "$item" "$dest/$name"
                fi
            done
        }
    fi
}

# Run setup for each folder
setup_persistent_dir "/data/configs" "/configs"
setup_persistent_dir "/data/logs" "/logs"
setup_persistent_dir "/data/pipeline" "/pipeline"
setup_persistent_dir "/data/customFiles" "/customFiles"
setup_persistent_dir "/data/tessdata" "/usr/share/tessdata"

# Change to /data so Stirling-PDF runs in the persistent context
cd /data

# Start the Stirling-PDF application
exec java -Dfile.encoding=UTF-8 -jar /app.jar


