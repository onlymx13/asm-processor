#!/bin/bash
set -e
set -o pipefail
INPUT="$1"
OUTPUT="${INPUT%.c}.o"

if grep -Fq -- Microsoft /proc/version; then
    WINE=""
else
    WINE=wine
fi

CC="$WINE $CODEWARRIOR/mwcceppc.exe"
CFLAGS="-Cpp_exceptions off -proc gekko -fp hard -O4"
AS="powerpc-eabi-as"
ASFLAGS="-mgekko" # -I include
set +e
OPTFLAGS=""
set -e

python3 asm_processor.py "$OPTFLAGS" "$INPUT" | $CC -c $CFLAGS include-stdin.c -o "$OUTPUT" "$OPTFLAGS"
python3 asm_processor.py "$OPTFLAGS" "$INPUT" --post-process "$OUTPUT" --assembler "$AS $ASFLAGS" --asm-prelude prelude.s
