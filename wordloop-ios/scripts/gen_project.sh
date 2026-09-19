#!/bin/bash
# Why: one command to emit Loopfolio.xcodeproj from project.yml.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v xcodegen >/dev/null || { echo "Install xcodegen first: brew install xcodegen"; exit 1; }
xcodegen generate
echo "Open Loopfolio.xcodeproj in Xcode and run the Debug configuration."
