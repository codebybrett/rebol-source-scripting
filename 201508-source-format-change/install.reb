REBOL [
	purpose: {Install scripts and changes into Ren/C.}
]

ask "Hit Enter to install into Ren/C"

do %config.reb

update-file: funct [{Update a file.} file replacements [block!]][
	text: read file
	foreach [old new] replacements [
		if not find/case text old [
			print reform [{Could not update file} file {with replacement} (mold new)]
		]
		replace/case text old new
	]
	write file text
]

repo-base: clean-path %../

update-file probe ren-c-root/src/core/m-pools.c [
	"*/^-void Check_Pool_Map(void)^/**" "** ////^-void Check_Pool_Map(void)^/**"
]

update-file probe ren-c-root/.gitignore [
	"make/objs/^/^/" "make/objs/^/make/data/^/^/"
	"src/boot/host-init.r^/^/" "src/boot/host-init.r^/src/boot/tmp-*^/^/"
]

update-file probe ren-c-root/src/tools/make-make.r [
	{prep: $(REBOL_TOOL)
^-$(REBOL) $T/make-headers.r}

{prep: $(REBOL_TOOL)
^-$(REBOL) $T/c-source.reb
^-$(REBOL) $T/make-headers.r}
]

write probe ren-c-root/src/tools/c-source.reb read %ren-c-install/c-source.reb
write probe ren-c-root/src/tools/make-headers.r read %ren-c-install/make-headers.r

; -- Copy lib files

files: exclude read path: repo-base/(%lib/) [%r2r3-future.r]
files: map-each x files [join path x]

append files reduce [repo-base/%rebol-c-source.reb repo-base/%rebol-source-conventions.reb]

lib-path: ren-c-root/src/tools/(%lib/)
make-dir/deep probe lib-path

foreach file files [
?? file
	name: second split-path file
	write probe lib-path/:name read file
]

