#!/bin/sh
cd "$(dirname "$0")"
if [ "$(uname)" = Darwin ]; then
  clang -fobjc-arc -framework Foundation LLM.m -o LLM && ./LLM "${1:-README.md}" "${2:-300}"
else
  echo "Objective-C Foundation is not available here; CI builds and runs LLM.m on macOS."
  echo "Check it with: gh run list --repo Colegio-San-Caio/LLMM"
fi
