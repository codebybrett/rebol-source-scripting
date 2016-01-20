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

apropos conversion [


	if %temporary.201512-file-headers/ = second split-path conversion/target.folder [
		path: join conversion/target.folder %src/
		attempt [
			foreach file reverse read-below path [
				delete join path file
			]
		]
	]

	logfile: clean-path join target.folder %source-tool.log.txt
	attempt [delete logfile]

	issuesfile: clean-path join target.folder %source-tool.issues.txt
	attempt [delete issuesfile]

	headers: file/headers

	save join target.folder %source-tool.headers.r headers

	save join target.folder %source-tool.analysis.r header/analysis headers
]

conversion/run

HALT