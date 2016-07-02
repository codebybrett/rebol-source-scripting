REBOL [
	Title: "Rebol Source Conventions - Test"
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

decode-function-meta-test: requirements 'decode-function-meta [

	[
		none? decode-function-meta {}
	]

	[
		none? decode-function-meta {x}
	]

	[
		[x: C] = first decode-function-meta "x: C"
	]

	[
		[x: native ["desc"]] = first decode-function-meta {x: native {desc}}
	]

	[
		[x: native ["desc"]] = first decode-function-meta {x: native {desc} -}
	]

	[
		[x: native ["desc" /test]] = first decode-function-meta {x: native {desc} - /test}
	]

	[
		[[x: native ["desc" /test]] "Notes"] = decode-function-meta {x: native {desc} - /test^/^/Notes}
	]
]

requirements %test.rebol-source-conventions.reb [

	['passed = last decode-function-meta-test]
]