REBOL [
	Title: "Rebol C Source - Test"
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

requirements %rebol-c-source.reb [

	[{Parse source text.}

		rebol-c-source/valid? text: read/string %source/n-system.c
	]

	[{Find function.}

		found? position: rebol-c-source/parser/find-function text
	]

	[{Load function intro.}

		block? intro: rebol-c-source/parser/parse-intro/next position 'next-position
	]

	[{Load function declaration.}

		[["REBNATIVE"] ["halt"]] = rebol-c-source/parser/parse-decl next-position
	]
]
