REBOL [
	Title: "C Source Processing"
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Process Rebol C source, extracting function data, etc.}
]

do %lib/env.reb

script-needs [
	%apropos.reb
	%rebol-c-source.reb
]

base-dir: clean-path %../../

apropos rebol-c-source [

	src-folder: base-dir/(%src/)

	log: :logfn

	scan

	src-natives: list/natives
	natives-text: generate/natives.r src-natives
	write base-dir/src/boot/tmp-natives.reb natives-text
]

HALT