REBOL [
	Title: "All Rebol Source Scripting Tests"
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

script-needs [
	%requirements.reb
]

remove-each test tests: read %./ [
	any [
		find [%_all.tests.reb %config.reb %setup.reb] test
		not parse/all test [thru %.reb]
	]
]

print [{Running} length? tests {tests:}]

requirements %_all.tests.reb map-each test tests [
	compose ['passed = last do (?? test)]
]
