REBOL []

script-needs [
	%source-tool.reb
]

do %config.reb

src-output: target-root/%src/

apropos source-tool [

	rebol.source.folder: source-root/%src/

	rebol.output.folder: src-output
	logfile: target-root/%source-tool.log.txt

	attempt [delete logfile]

	update/all
]

