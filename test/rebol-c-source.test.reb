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


script-needs [
	%requirements.reb
	%../rebol-c-source.reb
]

requirements %rebol-c-source.reb [

	[{Parse source text.}

		rebol-c-source/valid? text: read/string %source/n-system.c
	]

	[{Find function.}

		found? position: rebol-c-source/function/find text
	]

	[{Load function.}

		block? intro: rebol-c-source/function/intro position
	]

	[{Halt is first function.}

		'halt = to word! intro/1/1
	]
]
