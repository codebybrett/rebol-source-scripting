REBOL [
	Title: "Test Scan Natives"
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

requirements %scan-natives.reb [

	[{Full scan.}
		scan-time: delta-time [rn: rebol-c-source/scan/natives]
		time? ?? scan-time
	]
]



