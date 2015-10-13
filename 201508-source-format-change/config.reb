REBOL []

ren-c-root: clean-path %../../ren-c/

source-root: ren-c-root

target-root: clean-path %../../temporary.201508-source-format-change/

if not exists? target-root [
	fail [{Target-root} target-root {does not exist.}]
]