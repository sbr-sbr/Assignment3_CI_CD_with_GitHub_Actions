#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-devops-tool}"

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not installed or not on PATH." >&2
    exit 1
fi

if [[ ! -f "Dockerfile" ]]; then
    echo "Error: Dockerfile not found in project root." >&2
    exit 1
fi

echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

echo "Smoke test: help command"
docker run --rm "$IMAGE_NAME" help >/dev/null

echo "Build completed successfully."
exit 0