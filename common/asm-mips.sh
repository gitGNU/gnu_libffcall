#!/bin/sh
# Translate the assembler syntax of mips assembler programs
# Usage: asm-mips.sh < irix-asm-file > portable-asm-file
# The portable-asm-file has to be
#   1. preprocessed,
#   2. grep -v '^ *#line' | grep -v '^#'
#   3. sed -e 's,% ,%,g' -e 's,//.*$,,'

tmpscript1=sed$$tmp1
tmpscript2=sed$$tmp2
tmpremove='rm -f $tmpscript1 $tmpscript2'
trap "$tmpremove" 1 2 15

cat > $tmpscript1 << \EOF
# ----------- Remove gcc self-identification
/gcc2_compiled/d
/gnu_compiled_c/d
/\.ident/d
EOF

cat > $tmpscript2 << \EOF
# ----------- Remove comments, they would cause trouble in preprocessing
s,#.*$,,
# ----------- Remove assembler pseudo-ops that the IRIX assembler does not understand
/\.section/d
/\.previous/d
/\.abicalls/d
# ----------- Massage the beginning of functions
/\.type/{
s/\.type[ 	]\+\([A-Za-z0-9_]*\), *@function/DECLARE_FUNCTION(\1)/
}
EOF

sed -f $tmpscript1 | \
sed -f $tmpscript2

eval "$tmpremove"
