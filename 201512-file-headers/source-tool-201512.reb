REBOL [
	Title: "Rebol C Source File Header Conversion TERMS"
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Process Rebol C source to change the source file headers.}
]

script-needs [
	%read-below.reb
	%parse-kit.reb
	%text-lines.reb
]

conversion: context [

	{Conversion terms}

	source.folder: none
	; Path to %src/

	target.folder: none
	; Path to %src/


	logfile: clean-path %source-tool.log.txt
	log: func [message] [write/append logfile join newline mold new-line/all compose/only message false]


	edit: func [
		{Modify source}
		source
	] [

		log [TODO: conversion/edit]
		source
	]

	file: context [

		header-of: func [
			{Return file header dialect.}
			file [file!]
			/local text
		] [

			text: read/string join source.folder file

			source-text/header text
		]

		headers: func [
			{Return file headers.}
			/local result position
		] [

			files: list
			result: make block! 2 * length files

			foreach file files [
				insert position: tail result reduce [file header-of file]
				new-line position true
			]

			result
		]

		list: func [
			{Return files.}
			/local files
		] [

			files: read-below source.folder

			remove-each name files [
				not parse/all name [[%core/ | %os/] thru %.c]
			]

			sort files
		]
	]

	run: func [
		{Convert the files.}
	] [

		foreach file file/list [update file]
	]

	source-text: context [

		header.text: none

		grammar: context [

			rule: [
				(header.text: none)
				format2012.header
				to end
			]

			format2012.header: [
				{/*} 50 100 #"*" newline
				copy header.text some [
					some #"*" newline ; Star line
					| {**} opt wsp newline ; Blank line
					| {**} wsp thru newline ; Text line
				]
				50 100 #"*" {/} newline
			]

			wsp: compose [some (charset { ^-})]
			span-comment: [{/*} thru {*/}]
			line-comment: [{//} to newline]
		]

		header: func [
			{Return file header.}
			text
			/local result hdr
		] [

			if source-text/valid? text [

				if header.text [
					result: parse-format2012-header header.text
				]

				any [
					result
					header.text
				]
			]
		]

		parse-format2012-header: func [
			text
			/local
			hdr-rule hdr emit not-eol not-field title rights trademark rest eol eof meta msg
			field-char field
			position
		] [

			field-char: charset [#"A" - #"Z" #"a" - #"z"]
			field: [some field-char any [#" " some field-char] #":"]

			not-field: parsing-unless [field]
			not-eol: parsing-unless [newline]

			attempt [

				emit-meta: func [/local key] [
					meta: any [meta copy []]
					key: replace/all copy/part position eof #" " #"-"
					remove back tail key
					append meta reduce [
						to word! key
						trim/auto copy/part eof eol
					]
				]

				emit-rights: func [] [
					rights: any [rights copy []]
					append rights copy/part position eol
				]

				hdr-rule: [
					newline
					[
						{REBOL [R3] Language Interpreter and Run-time Environment} (title: 'r3)
						| {REBOL Language Interpreter and Run-time Environment} (title: 'non-r3)
					] newline
					newline
					any [position: {Copyright 20} to newline eol: newline (emit-rights)]
					position:
					opt [{REBOL is a trademark of REBOL Technologies} newline (trademark: 'rebol)]
					opt [
						newline
						position: {Additional code modifications and improvements Copyright 2012 Saphirion AG} eol: newline (emit-rights)
					]
					newline
					position:
					[{Licensed under the Apache License, Version 2.0} thru {limitations under the License.} (notice: 'apache-2.0)] newline
					any newline
					position:
					opt [
						50 100 #"*" newline
						newline
						some [
							position:
							field eof: [
								#" " to newline any [
									newline not-field not-eol to newline
								]
								| any [1 2 newline 2 20 #" " to newline]
							] eol: (emit-meta) newline
							| newline
						]
					]
					position:
					opt [
						50 100 #"*" newline
						newline
						[
							copy msg [{WARNING to PROGRAMMERS} thru {before submitting it.}] newline
							| {NOTE to PROGRAMMERS:

  1. Keep code clear and simple.
  2. Document unusual code, reasoning, or gotchas.
  3. Use same style for code, vars, indent(4), comments, etc.
  4. Keep in mind Linux, OS X, BSD, big/little endian CPUs.
  5. Test everything, then test it again.} newline
							(msg: 'note-to-programmers)
						]
					]
					position:
					opt [
						copy rest [
							50 100 #"*" newline
							to end
						]
					]
					position:
				]

				hdr: decode-lines text {**} {  }

				either parse/all hdr hdr-rule [

					if rights [new-line/all rights true]
					if meta [new-line/all/skip meta true 2]

					compose/only [
						title (title)
						rights (rights)
						trademark (trademark)
						notice (notice)
						meta (meta)
						msg (msg)
						rest (rest)
					]
				] [
					print [{Failed to parse header near:} mold copy/part position 200]
					none
				]
			]
		]

		load: func [
			{Parse source text.}
			text [string!]
		] [

			text
		]

		render: func [
			{Return text of the source.}
			source
		] [

			source
		]

		valid?: function [{Return true if the source text can be parsed by the grammar.} text] [

			parse/all/case text grammar/rule
		]
	]

	update: func [
		{Rewrite the header and save the changes.}
		file [file!]
	] [

		old-text: read/string join source.folder file
		source: source-text/load old-text
		edit source
		new-text: source-text/render source

		if not equal? old-text new-text [
			write join target.folder file new-text
			log [updated (file)]
		]
	]
]
