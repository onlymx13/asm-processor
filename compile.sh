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
CCFLAGS="-Cpp_exceptions off -proc gekko -fp hard -O4"
AS="$WINE $DEVKITPPC/bin/powerpc-eabi-as.exe"
ASFLAGS="-mgekko" # -I include

python3 asm_processor.py "$INPUT" | $CC -c $CCFLAGS include-stdin.c -o "$OUTPUT" "$OPTFLAGS"
echo python3 asm_processor.py "$INPUT" --post-process "$OUTPUT" --assembler "$AS $ASFLAGS" --asm-prelude prelude.s
python3 asm_processor.py "$INPUT" --post-process "$OUTPUT" --assembler "$AS $ASFLAGS" --asm-prelude prelude.s
