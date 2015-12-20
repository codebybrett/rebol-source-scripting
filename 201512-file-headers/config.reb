REBOL []

ren-c-root: clean-path %../../ren-c/src/

target-root: clean-path %../../temporary.201512-file-headers/src/

if not exists? target-root [
	fail [{Target-root} target-root {does not exist.}]
]


conversion/source.folder: ren-c-root
conversion/target.folder: target-root

