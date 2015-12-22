REBOL [
	Title: "Rebol C Source File Header Conversion RUN"
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Converts REBOL source file headers to a new format.}
]

do %setup.reb

script-needs [
	%apropos.reb
]

attempt [delete %source-tool.log.txt]

conversion/run

HALT