# Emscripten toolchain file for Dethrace web port
set(CMAKE_SYSTEM_NAME Emscripten)
set(CMAKE_SYSTEM_VERSION 1)

if(NOT DEFINED ENV{EMSDK})
    message(FATAL_ERROR "EMSDK environment variable is not set. Run emsdk_env.bat first.")
endif()

set(CMAKE_C_COMPILER   emcc)
set(CMAKE_CXX_COMPILER em++)
set(CMAKE_AR           emar)
set(CMAKE_RANLIB       emranlib)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(DETHRACE_EMSCRIPTEN TRUE CACHE BOOL "Building for Emscripten/WebAssembly" FORCE)
