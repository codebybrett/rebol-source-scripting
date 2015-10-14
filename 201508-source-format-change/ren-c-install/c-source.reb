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

repo-path: clean-path %../../

data-path: repo-path/make/(%data/)
make-dir data-path

apropos rebol-c-source [
	src-folder: repo-path/(%src/)
	log: :logfn
	scan
]

save/header data-path/function-list.reb rebol-c-source/cached/functions context [
	title: {Function list}
	date: now
	comment: {This file is generated during build process.}
]

apropos rebol-c-source [
	src-natives: list/natives
	natives-text: generate/natives.r src-natives
	write repo-path/src/boot/tmp-natives.reb natives-text
]
