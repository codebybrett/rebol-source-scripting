REBOL [
	Title: "Debug Parsing"
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
	%../rebol-c-source.reb
]

do http://codeconscious.com/rebol-scripts/parse-analysis-view.r
; Will redefines script-needs.

do %../reb/env.reb

view-c: funct [text][

	visualise-parse text rebol-c-source/grammar [rebol-c-source/valid? text]
]

