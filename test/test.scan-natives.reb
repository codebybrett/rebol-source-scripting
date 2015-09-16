REBOL []

do %setup.reb

requirements %scan-natives.reb [

	[{Full scan.}
		scan-time: delta-time [rn: rebol-c-source/scan/natives]
		time? ?? scan-time
	]
]



