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

do %lib/env.reb

script-needs [
	%requirements.reb
]

do %config.reb
do %../rebol-c-source.reb

rebol-c-source/src-folder:  target-root/(%src/)
rebol-c-source/log: get in rebol-c-source 'logfn

