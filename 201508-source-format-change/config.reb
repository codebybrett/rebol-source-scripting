REBOL []

source-root: clean-path %../../ren-c/

target-root: clean-path %../../temporary.201508-source-format-change/


if not exists? target-root [
	fail [{Target-root} target-root {does not exist.}]
]