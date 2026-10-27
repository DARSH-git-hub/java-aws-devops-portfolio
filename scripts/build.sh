#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/classes
# Works on a full JDK even if the javac launcher is not on PATH.
java -m jdk.compiler/com.sun.tools.javac.Main --release 17 -d build/classes src/*.java
printf '%s\n' 'Java build passed.'
