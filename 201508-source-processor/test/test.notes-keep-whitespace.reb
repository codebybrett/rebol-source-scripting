REBOL [
	Title: "Parser Faithfullness"
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

requirements %test.notes-keep-whitespace.reb [

	[{Parser must return notes faithfully.}

		text: {//
//  X: C
//
//  Y
}
		"  Y" = second rebol-c-source/parser/parse-intro text
	]
]