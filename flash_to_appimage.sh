#!/bin/bash
set -e

if (($# != 4)); then
    echo >&2 "Usage: [NAME] [PATH TO RUFFLE BINARY] [PATH TO SWF FILE] [PATH TO ICON]"
    exit
fi

# Move into tmp directory to not leave lingering files
random=$RANDOM
dir=$(pwd)
mkdir "/tmp/$random"
cd "/tmp/$random"

# Make directory
mkdir game
mkdir -p game/usr/bin
mkdir -p game/usr/share/icons/hicolor

# Copy files
cp "$dir/$2" game/usr/bin # Ruffle binary
cp "$dir/$3" game/usr/bin # Game swf
cp "$dir/$4" game/        # Icon
mogrify -resize 256x256! "game/$4"

# Write AppRun script
{
    echo '#!/bin/sh'
    echo ''
    echo 'cd "$(dirname "$0")"'
    echo "exec \"./usr/bin/$2\" \"--dont-warn-on-unsupported-content\" \"./usr/bin/$3\""
} >>game/AppRun
chmod +x game/AppRun

# Write desktop file
{
    echo '[Desktop Entry]'
    echo "Name=$1"
    echo "Exec=$2"
    echo "Icon=${4%.*}"
    echo 'Type=Application'
    echo 'Categories=Game;'
} >>game/game.desktop

# Make menu icon
mkdir -p 'game/usr/share/icons/hicolor/256x256/apps/'
cp "$dir/$4" "game/usr/share/icons/hicolor/256x256/apps/$4"
mogrify -resize 256x256! "game/usr/share/icons/hicolor/256x256/apps/$4" # Resize icon

# Make appimage
cd "$dir"
appimagetool "/tmp/$random/game"
rm -rf "/tmp/$random/game"
