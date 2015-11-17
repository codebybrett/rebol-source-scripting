REBOL []


do %config.reb

rebol.source.folder: source-root/%src/
target-src: rebol.source.folder

make-dir/deep target-src

logfile: target-root/%detab.log.txt

logfn: func [message] [print mold new-line/all compose/only message false]
log: :logfn

attempt [delete logfile]

folder?: function [file [file!]][#"/" = last file]

files: map-each file read-below rebol.source.folder [either folder? file [()][file]]

file-extension: function [file][
	name: second split-path file
	find/last file "."
]

extensions: sort unique map-each file files [file-extension file]
unxpected-extensions: exclude extensions [%.c %.h %.r %.txt %.inc]
?? unxpected-extensions
; if not empty? unxpected-extensions [fail {Unexpected extensions.}]

detab-file: function [file][
	text: read rebol.source.folder/:file
	path-to-file: target-src/:file
	make-dir/deep first split-path path-to-file
	write path-to-file detab text
	log [detabbed (path-to-file)]
]

detab-ext: function [ext {eg. %.c} [file!]][
	foreach file files [
		if ext = file-extension file [detab-file file]
	]
]

tabbed-files: map-each file files [
	text: read rebol.source.folder/:file
	either find text tab [file][()]
]


HALT