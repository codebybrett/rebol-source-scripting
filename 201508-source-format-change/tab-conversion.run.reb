REBOL []


do %config.reb

rebol.source.folder: source-root/%src/
target-src: target-root/%detab/ ; Change to same as source.

make-dir/deep target-src

logfile: target-root/%detab.log.txt

logfn: func [message] [print mold new-line/all compose/only message false]
log: :logfn

attempt [delete logfile]

folder?: funct [file [file!]][#"/" = last file]

files: map-each file read-below rebol.source.folder [either folder? file [()][file]]

file-extension: funct [file][
	name: second split-path file
	find/last file "."
]

extensions: sort unique map-each file files [file-extension file]
if not empty? exclude extensions [%.c %.h %.r %.txt] [fail {Unexpected extensions.}]

tabbed-files: map-each file files [text: read rebol.source.folder/:file either find text tab [file][()]]

detab-file: funct [file][
	text: read rebol.source.folder/:file
	path-to-file: target-src/:file
	make-dir/deep first split-path path-to-file
	write path-to-file detab text
	log [detabbed (path-to-file)]
]

foreach file files [detab-file file]

HALT