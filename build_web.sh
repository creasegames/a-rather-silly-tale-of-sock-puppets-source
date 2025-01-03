#!/bin/bash

EMSCRIPTEN_SDK_DIR="$HOME/emsdk"
OUT_DIR="build/web"

mkdir -p $OUT_DIR

export EMSDK_QUIET=1
# shellcheck disable=SC1091
[[ -f "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh" ]] && . "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh"

if ! odin build main_web -target:freestanding_wasm32 -build-mode:obj -define:RAYLIB_WASM_LIB=env.o -define:RAYGUI_WASM_LIB=env.o -vet -strict-style -out:$OUT_DIR/game; then
  exit 1
fi

ODIN_PATH=$(odin root)
files="main_web/main_web.c $OUT_DIR/game.wasm.o $ODIN_PATH/vendor/raylib/wasm/libraylib.a $ODIN_PATH/vendor/raylib/wasm/libraygui.a"
flags="-sUSE_GLFW=3 -sASYNCIFY -sASSERTIONS -DPLATFORM_WEB"
custom="--shell-file main_web/index_template.html --preload-file assets"

# shellcheck disable=SC2086
# Add `-g` to `emcc` call to enable debug symbols (works in chrome).
emcc -o $OUT_DIR/index.html $files $flags $custom && rm $OUT_DIR/game.wasm.o
cp -R ./assets/ ./$OUT_DIR/assets/
