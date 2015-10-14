REBOL [
	purpose: {Install scripts and changes into Ren/C.}
]

ask "Hit Enter to install into Ren/C"

do %config.reb

repo-base: clean-path %../

write probe ren-c-root/.gitignore read %ren-c-install/.gitignore

write probe ren-c-root/src/tools/c-source.reb read %ren-c-install/c-source.reb
write probe ren-c-root/src/tools/make-make.r read %ren-c-install/make-make.r
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

