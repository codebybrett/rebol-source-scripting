REBOL []

do %setup.reb

dev-stdio: target-root/src/os/windows/dev-stdio.c

text: read/string dev-stdio

text: find text {//*******}

requirements %test.stdio.handle_break.reb [

	[block? rebol-c-source/parser/parse-function-section text]
]
