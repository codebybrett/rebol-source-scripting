REBOL [
	Title: "Rebol C Source - Parse All Sources Test"
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
	%read-below.reb
	%../rebol-c-source.reb
]

parse-all-c-sources: funct [root][

	files: read-below root

	remove-each file files [
		not parse/all file [thru %.c | thru %.h]
	]

	requirements 'all-c-source-parsed map-each file files [

		compose [rebol-c-source/valid? to string! read/string (root/:file)]
	]
]

requirements %rebol-c-sources-parsed.reb [

	['passed = last parse-all-c-sources %../../temporary.201508-source-format-change/]
]