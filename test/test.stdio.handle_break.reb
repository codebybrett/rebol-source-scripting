REBOL [
	Title: "Test STDIO Handle_Break"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
]

do %setup.reb

dev-stdio: target-root/src/os/windows/dev-stdio.c

text: read/string dev-stdio

text: find text {//*******}

requirements %test.stdio.handle_break.reb [

	[block? rebol-c-source/parser/parse-function-section text]
]
