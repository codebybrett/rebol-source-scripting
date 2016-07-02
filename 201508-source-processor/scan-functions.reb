REBOL [
	Title: "Scan all functions"
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


do %test/setup.reb

rebol-c-source/scan

write target-root/data/function-list.reb mold rebol-c-source/cached/functions

