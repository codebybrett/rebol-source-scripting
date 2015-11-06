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


if not value? 'tokenise-parse [do http://codeconscious.com/rebol-scripts/parse-analysis.r]
if not value? 'visualise-parse [do http://codeconscious.com/rebol-scripts/parse-analysis-view.r]
; Will redefines script-needs.

do %../test/setup.reb

view-c: function [text][

	visualise-parse text rebol-c-source/grammar [rebol-c-source/valid? text]
]

dev-stdio: target-root/src/os/windows/dev-stdio.c
