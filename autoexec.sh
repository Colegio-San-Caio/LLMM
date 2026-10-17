#!/bin/sh
cd "$(dirname "$0")"
if command -v go >/dev/null; then
  go run . "${1:-llm.go}" "${2:-300}" "${3:-3}"
else
  echo "run: pkg install golang"
fi
