#!/bin/bash

REQUIRED_FILES=(
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "Dockerfile"
    "compose.yaml"
    "grade.sh"
    ".dockerignore"
)

echo "Checking for required files..."
EXIT_CODE=0

for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$FILE" ]]; then
        echo "Error: Required file '$FILE' is missing."
        EXIT_CODE=1
    else
        echo "File found: $FILE"
    fi
done

if [ $EXIT_CODE -ne 0 ]; then
    echo "One or more files missing"
    exit 1
fi

echo "All required files exist"
exit 0