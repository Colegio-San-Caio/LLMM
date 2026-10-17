#!/bin/sh
cd "$(dirname "$0")"
if command -v go >/dev/null; then
  go run llm.go "${1:-README.md}" "${2:-300}"
elif [ "$(uname)" = Darwin ]; then
  clang -fobjc-arc -framework Foundation LLM.m -o LLM && ./LLM "${1:-README.md}" "${2:-300}"
else
  echo "run: pkg install golang"
fi
