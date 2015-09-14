REBOL []

script-needs [
	%source-tool.reb
]

do %config.reb

src-output: target-root/%src/

source-tool/logfile: target-root/%source-tool.log.txt
source-tool/rebol.output.folder: src-output

attempt [delete source-tool/logfile]

source-tool/update/all