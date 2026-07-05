# Carmageddon Web Port — Emscripten build (Windows)
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$Dethrace = Join-Path $Root "dethrace-0.10.1"
$BuildDir = Join-Path $Root "build-emscripten"
$WebDir = Join-Path $Root "web"
$CarmaDir = Join-Path $Root "Carma"

Write-Host "=== Carmageddon Web Build ===" -ForegroundColor Cyan

if (-not (Test-Path (Join-Path $CarmaDir "DATA\GENERAL.TXT"))) {
    throw @"
Game data not found at: $CarmaDir
Place a legal copy of Carmageddon (DATA folder) in ./Carma/
See README.md — retail assets are not included in this repository.
"@
}

$EmsdkEnv = Join-Path $env:USERPROFILE "emsdk\emsdk_env.bat"
if (-not (Test-Path $EmsdkEnv)) {
    throw "Emscripten SDK not found. Install from https://emscripten.org/docs/getting_started/downloads.html"
}

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

Write-Host "Configuring CMake..."
cmd /c "`"$EmsdkEnv`" && emcmake cmake -G Ninja -S `"$Dethrace`" -B `"$BuildDir`" -DCMAKE_BUILD_TYPE=Release -DDETHRACE_NET_ENABLED=OFF -DDETHRACE_PLATFORM_SDL2=ON -DDETHRACE_PLATFORM_SDL_DYNAMIC=OFF"

Write-Host "Building..."
cmd /c "`"$EmsdkEnv`" && cmake --build `"$BuildDir`" -j --target dethrace"

$OutputJs = Join-Path $BuildDir "carmaweb.js"
$OutputWasm = Join-Path $BuildDir "carmaweb.wasm"
$OutputData = Join-Path $BuildDir "carmaweb.data"

if (-not (Test-Path $OutputJs)) {
    throw "Build failed: carmaweb.js not found in $BuildDir"
}

Copy-Item $OutputJs $WebDir -Force
Copy-Item $OutputWasm $WebDir -Force
if (Test-Path $OutputData) {
    Copy-Item $OutputData $WebDir -Force
}

Write-Host ""
Write-Host "Build complete! Files copied to: $WebDir" -ForegroundColor Green
Write-Host "Run: python web/serve.py"
Write-Host "Open: http://localhost:8080"
