REBOL [
	Title: "Rebol C Source - Example"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {An example of how to use the source tool.}
]

; -------------------------------------------------------------------------
;
; REBOL-C-SOURCE EXAMPLE
;
; Normally the scripts will be run from disk and at mimimum you need:
;
; 1. The source tool script: %rebol-c-source.reb
; 2. The script environment script: %env.reb
;    - which is normally located within a subfolder %reb/ or %lib/
;
; -------------------------------------------------------------------------

; Script locations.
;
tool-folder: https://raw.githubusercontent.com/codebybrett/rebol-source-scripting/master/
reb: tool-folder/(%reb/)

; First set script environment.
;
; DO/ARGS and parameter are not needed when running from disk.
; The argument is used here because we want to run from an url.
;
do/args tool-folder/reb/env.reb reb

; Run the source tool.
;
do tool-folder/rebol-c-source.reb

; Configure the source tool with source folder.
;
base-dir: %../temporary.201508-source-format-change/
rebol-c-source/src-folder: base-dir/(%src/)

; Turn on logging.
;
rebol-c-source/log: get in rebol-c-source 'logfn

; Get list of natives.
;
rebol-c-source/scan
src-natives: rebol-c-source/list/natives

; Generate natives.r write to temporary files.
natives-text: rebol-c-source/generate/natives.r src-natives
write base-dir/data/tmp-natives.reb natives-text
