REBOL [
	Title: "Reconcile Natives"
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


if not value? 'env [do %../reb/env.reb]
if not value? 'rebol-c-source [do %../rebol-c-source.reb]

do %config.reb
rebol-c-source/src-folder: target-root/(%src/)

delta: delta-time [src-natives: rebol-c-source/natives]

boot-natives: load %../../ren-c/src/boot/natives.r

missing-natives: exclude set-words-of boot-natives set-words-of src-natives
extra-natives: exclude set-words-of src-natives set-words-of boot-natives

print [{Natives scan took:} delta]
?? missing-natives
?? extra-natives