REBOL [
	Title: "Rebol C Source File Header Conversion"
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Process Rebol C source to change the source file headers.}
	Comment: {
		Works with Rebol 2 and Rebol 3 (rebolsource).
		At the time of writing Ren/C is often changing so this script may or may not work with it.
	}
]

script-needs [
	%read-below.reb
	%parse-kit.reb
	%text-lines.reb
]

conversion: context [

	{Conversion terms}

	source.folder: none
	; Path to repo (%src/ is a subfolder).

	target.folder: none
	; Path to repo (%src/ is a subfolder).


	logfile: clean-path %source-tool.log.txt
	log: function [message] [write/append logfile join newline mold new-line/all compose/only message false]

	file: context [

		header-of: function [
			{Return file header dialect.}
			file [file!]
		] [

			log [parsing (file)]

			text: read/string join source.folder file

			source-text/header text
		]

		headers: function [
			{Return file headers.}
		] [

			files: list
			result: make block! 2 * length files

			foreach file files [
				insert position: tail result reduce [file header-of file]
				new-line position true
			]

			result
		]

		list: function [
			{Return files.}
		] [

			files: read-below join source.folder %src/

			files: map-each file files [join %src/ file]

			remove-each name files [
				not parse/all name [[%src/include/ | %src/core/ | %src/os/] thru %. [%c | %h]]
			]

			sort files
		]
	]

	header: context [

		analysis: function [
			{Analyses file headers as returned from file/headers.}
			header-list [block!]
			/nofilecount {Do not replace file lists with count of files.}
		] [

			meta-fields: copy []

			new-line/all/skip collect [

				foreach [file hdr] header-list [
					either string? hdr [
						keep compose [(file) not-parsed]
					] [
						either none? hdr [
							keep compose/only [(file) no-header]
						] [
							if not none? hdr/analysis [
								keep compose/only [(file) (hdr/analysis)]
							]
							if block? hdr/meta [
								foreach [key value] hdr/meta [
									if not files: select meta-fields key [
										append meta-fields reduce [:key files: copy []]
									]
									append files file
								]
							]
						]
					]
				]
				if not nofilecount [
					for i 2 length meta-fields 2 [
						if 10 <= length meta-fields/:i [
							poke meta-fields i length meta-fields/:i
						]
					]
				]
				keep compose/only [meta-fields (meta-fields)]

			] true 2
		]

		as: context [

			format2016: func [
				{Return header text/}
				header [block! string! none!]
			] [

				if none? header [return copy {}]

				either string? header [
					text: copy header
				] [

					section-line: {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^/}
					text: rejoin collect [
						keep newline
						keep reduce [{REBOL [R3] Language Interpreter and Run-time Environment} newline]
						keep reduce [{"Ren-C" branch @ https://github.com/metaeducation/ren-c} newline]

						rights: any [header/rights []]
						if not empty? rights [
						keep newline

							keep reduce [first rights newline]
							keep rejoin [{Copyright 2012-} now/year { Rebol Open Source Contributors.^/}]
							keep {  See CREDITS.md in the top level directory of this distribution
  for more information.^/}
						] ; Needs to be conditional due to s-unicode.c

						if true [
							keep newline
							keep {REBOL is a trademark of REBOL Technologies^/}
						]
						keep newline

						if header/notice = 'apache-2.0 [
							keep {Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.}
							keep newline
							keep newline
						]

						if header/meta [
							keep section-line
							keep newline
							foreach [key value] header/meta [

								if (key <> 'notes) [

									key: join form key #":"

									either find value newline [
										value: join newline encode-lines value {} {  }
									] [
										insert/dup tail key #" " 1 + max 0 10 - length key
										if empty? value [value: none]
										value: join value newline
									]

									keep rejoin [key value]
								]
							]
							keep newline
							keep section-line
						]

if (header/meta false) [
	if not find header/meta 'notes [
		append header/meta [notes {}]
	]
	if empty? header/meta/notes [header/meta/notes: {MYNOTES}]
]

						if notes: all [
							header/meta
							find header/meta 'notes
							not empty? header/meta/notes
						][
							keep newline
							keep header/meta/notes
							keep newline
						]

						if header/msg [
							keep newline
							if notes [
								keep section-line
								keep newline
							]
							either header/msg = 'standard-programmer-note [
								keep {NOTE to PROGRAMMERS:

  1. Keep code clear and simple.
  2. Document unusual code, reasoning, or gotchas.
  3. Use same style for code, vars, indent(4), comments, etc.
  4. Keep in mind Linux, OS X, BSD, big/little endian CPUs.
  5. Test everything, then test it again.}
								keep newline
							] [
								keep header/msg
								keep newline
							]
						]

						if header/rest [
							keep header/rest
						]
					]
				]

				text: rejoin [
					encode-lines text {//} {  }
				]

				;;; replace/all text {^///  //=/} {^///=/}
			]

			format2012: func [
				{Return header text/}
				header [block! string! none!]
			] [

				if none? header [return copy {}]

				either string? header [
					text: copy header
				] [

					section-line: {************************************************************************^/}
					text: rejoin collect [
						keep newline
						keep reduce [{REBOL [R3] Language Interpreter and Run-time Environment} newline]
						keep newline

						foreach right any [header/rights []] [
							keep reduce [right newline]
						]
						if header/trademark = 'rebol [
							keep {REBOL is a trademark of REBOL Technologies^/}
						]
						keep newline

						if header/notice = 'apache-2.0 [
							keep {Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.}
							keep newline
							keep newline
						]

						if header/meta [
							keep section-line
							keep newline
							foreach [key value] header/meta [

								key: join form key #":"

								either find value newline [
									value: join newline encode-lines value {} {  }
								] [
;;									if empty? value [value: none]
									if all [value not empty? value] [insert/dup tail key #" " 1 + max 0 8 - length key]
									value: join value newline
								]

								keep rejoin [key value]
							]
						]

						if header/msg [
							keep newline
							keep section-line
							keep newline
							either header/msg = 'standard-programmer-note [
								keep {NOTE to PROGRAMMERS:

  1. Keep code clear and simple.
  2. Document unusual code, reasoning, or gotchas.
  3. Use same style for code, vars, indent(4), comments, etc.
  4. Keep in mind Linux, OS X, BSD, big/little endian CPUs.
  5. Test everything, then test it again.}
								keep newline
							] [
								keep header/msg
							]
						]

						if header/rest [keep header/rest]
					]
				]

				text: rejoin [
					{/***********************************************************************^/}
					encode-lines text {**} {  }
					{***********************************************************************/^/}
				]

				replace/all text {^/**  ****} {^/****}
			]
		]
	]

	run: function [
		{Convert the files.}
	] [

		foreach file file/list [update ?? file]
	]

	source-text: context [

		eoh:
		header.text:
		none

		grammar: context [

			rule: [
				(header.text: none)
				eoh:
				format2012.header
				eoh:
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

		header: function [
			{Return file header.}
			text
		] [

			all [
				source-text/valid? text
				header.text
				any [
					parse-format2012-header header.text
					header.text
				]
			]
		]

		parse-format2012-header: function [
			text
		] [

			grammar: context [

				hdr-rule: [
					any [
						position:
						newline
						| {REBOL [R3] Language Interpreter and Run-time Environment} (title: 'r3)
						| {REBOL Language Interpreter and Run-time Environment} eol: (title: copy/part position eol)
						| {Copyright 20} to newline eol: newline (emit-rights)
						| {Additional code modifications and improvements Copyright 2012 Saphirion AG} eol: newline (emit-rights)
						| {REBOL is a trademark of REBOL Technologies} newline (trademark: 'rebol)
						| [{Licensed under the Apache License, Version 2.0} thru {limitations under the License.} (notice: 'apache-2.0)] newline
					]
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
							(msg: 'standard-programmer-note)
						]
					]
					position:
					opt [
						(rest: none)
						copy rest [
							50 100 #"*" newline
							to end
						]
					]
					position:
				]

				field-char: charset [#"A" - #"Z" #"a" - #"z"]
				field: [some field-char any [#" " some field-char] #":"]

				not-field: parsing-unless [field]
				not-eol: parsing-unless [newline]

			]

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

			do [

				hdr: decode-lines text {**} {  }

				title: rights: trademark: notice: meta: msg: rest: none

				either parse/all hdr grammar/hdr-rule [

					if rights [new-line/all rights true]
					if meta [new-line/all/skip meta true 2]

					analysis: new-line/all collect [
						if title <> 'r3 [keep 'non-standard-title]
						if all [rights empty? rights] [no-copyright-statement]
						if all [
							rights
							empty? map-each x rights [either parse/all x [{Copyright} thru {REBOL Technologies}][x][()]]
						] [keep 'no-rebol-technologies-copyright]
						if none? trademark [keep 'no-trademark]
						if all [not none? msg msg <> 'standard-programmer-note] [keep 'non-standard-message]
						if none? meta [keep 'missing-meta]
						if not none? rest [keep 'additional-information]
					] true
					if empty? analysis [analysis: none]

					compose/only [
						title (title)
						rights (rights)
						trademark (trademark)
						notice (notice)
						meta (meta)
						msg (msg)
						rest (rest)
						analysis (analysis)
					]
				] [
					log [could-not-parse near (mold copy/part position 200)]
					none
				]
			]
		]

		load: function [
			{Parse source text.}
			text [string!]
		] [

			compose/only [
				header (header text)
				body (eoh)
			]
		]

		render: function [
			{Render as source text.}
			source [block!]
		] [

			hdr: conversion/header/as/format2016 source/header

			join any [hdr {}] source/body
		]

		valid?: function [{Return true if the source text can be parsed by the grammar.} text] [

			parse/all/case text grammar/rule
		]
	]

	update: function [
		{Rewrite the header and save the changes.}
		file [file!]
	] [

		old-text: read/string join source.folder file
		source: source-text/load old-text

		header: source/header
		if all [
			block? header
			block? meta: header/meta
		] [
			replace meta 'Title 'Summary

			replace meta 'Module 'File
			if not find meta 'File [
				insert meta compose [File (form second split-path file)]
				log [add-meta (file) [File]]
			]
		]

		new-text: source-text/render source

		if not equal? old-text new-text [
			target: join target.folder file
			make-dir/deep first split-path target
			write target new-text
			log [updated (file)]
		]
	]
]
