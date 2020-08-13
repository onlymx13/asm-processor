#!/usr/bin/python3
import argparse
import subprocess
from os import uname # For WSL detection

parser = argparse.ArgumentParser()
parser.add_argument("cfile", type=str, help="The filename of the C file to process.")
parser.add_argument("devkitppc", type=str, help="The path to DevKitPPC tools.")
args = parser.parse_args()
if args.devkitppc[-1] == "/":
    args.devkitppc = args.devkitppc[:-1]

if 'Microsoft' in uname().release: # WSL
    WINE = ""
else:
    WINE = "wine "

CC=f"{WINE}./mwcceppc.exe"
CCFLAGS="-Cpp_exceptions off -proc gekko -fp hard -O4".split()
AS = f"{WINE}{args.devkitppc}/bin/powerpc-eabi-as.exe"
ASFLAGS="-mgekko -mregnames" # -I include

temp_filename = "temp_file.c"
out_filename = temp_filename[:-1] + "o" # .o file

with open(temp_filename, 'wb') as temp_file:
    temp_file.write(subprocess.run(["./asm_processor.py", args.cfile, "--assembler", f"{AS} {ASFLAGS}"], stdout=subprocess.PIPE).stdout)
subprocess.run([CC, "-nolink"] + CCFLAGS + [temp_filename])
subprocess.run(["./asm_processor.py", args.cfile, "--post-process", out_filename, "--assembler", f"{AS} {ASFLAGS}", "--asm-prelude", "prelude.s"])
