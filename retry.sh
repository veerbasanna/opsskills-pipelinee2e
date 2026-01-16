#!/bin/bash
set -x

FILE_URL="https://www.gnu.org/licenses/gpl-3.0.txt"
wget "$FILE_URL"
if [ $? -eq 0 ]; then
        echo "fiel downloaded successfully"
else
        echo "file download failed"
fi

