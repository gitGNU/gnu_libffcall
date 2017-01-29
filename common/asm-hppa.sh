#!/bin/sh
# Translate the assembler syntax of hppa assembler programs
# Usage: asm-hppa.sh < hppalinux-asm-file > portable-asm-file
# The portable-asm-file has to be
#   1. preprocessed,
#   2. grep -v '^ *#line' | grep -v '^#'
#   3. sed -e "s,!,',g"

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
# ----------- Turn ' into !, to avoid trouble in preprocessing
s,',!,g
# ----------- Add some imports
/\.LEVEL/{
s/$/\
	IMPORT_MILLICODE($$dyncall)/
}
# ----------- Section switching
s/\.text/TEXT1()\
	TEXT2()/
# ----------- Declaration of symbols and labels is different
s/^\([A-Za-z0-9_.]\+\):$/DEF(\1)/
# ----------- Label syntax is different
/\.LEVEL/!{
s/\.L\([A-Za-z0-9_]\+\)/L(\1)/
}
# ----------- Introduce macro syntax for assembler pseudo-ops
s/\.globl[ 	]\([A-Za-z0-9_]\+\)/GLOBL(\1)/
# ----------- Massage the beginning of functions
/\.type/{
s/\.type[ 	]\+\([A-Za-z0-9_]*\), *@function/DECLARE_FUNCTION(\1)/
}
# ----------- Massage the end of functions
s/\.size[ 	]\([A-Za-z0-9_]*\),\(.*\)/FUNEND(\1)/
EOF

sed -f $tmpscript1 | \
sed -f $tmpscript2

eval "$tmpremove"
