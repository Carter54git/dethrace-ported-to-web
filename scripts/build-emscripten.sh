#!/usr/bin/env bash
# Carmageddon Web Port — Emscripten build (Linux / macOS)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DETHRACE="$ROOT/dethrace-0.10.1"
BUILD="$ROOT/build-emscripten"
WEB="$ROOT/web"
CARMA="$ROOT/Carma"

echo "=== Carmageddon Web Build ==="

if [[ ! -f "$CARMA/DATA/GENERAL.TXT" ]]; then
  echo "ERROR: Game data not found at $CARMA"
  echo "Place a legal copy of Carmageddon in ./Carma/ (see README.md)."
  exit 1
fi

if [[ -z "${EMSDK:-}" ]]; then
  echo "ERROR: Activate Emscripten first, e.g.: source ~/emsdk/emsdk_env.sh"
  exit 1
fi

mkdir -p "$BUILD"

emcmake cmake -G Ninja -S "$DETHRACE" -B "$BUILD" \
  -DCMAKE_BUILD_TYPE=Release \
  -DDETHRACE_NET_ENABLED=OFF \
  -DDETHRACE_PLATFORM_SDL2=ON \
  -DDETHRACE_PLATFORM_SDL_DYNAMIC=OFF

cmake --build "$BUILD" -j --target dethrace

cp "$BUILD/carmaweb.js" "$BUILD/carmaweb.wasm" "$WEB/"
[[ -f "$BUILD/carmaweb.data" ]] && cp "$BUILD/carmaweb.data" "$WEB/"

echo ""
echo "Build complete! Output in: $WEB"
echo "Run: python3 web/serve.py"
