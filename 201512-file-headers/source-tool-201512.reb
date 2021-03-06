REBOL [
	Title: "Rebol C Source File Header Conversion"
	Rights: {
		Copyright 2016 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Process Rebol C source to change the source file headers.}
	Comment: {
		Works with Rebol 2 and Rebol 3 (rebolsource).
		At the time of writing Ren/C is frequently changing so this script may or may not work with it.
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

	issuesfile: clean-path %source-tool.issues.txt
	issue: function [message] [write/append issuesfile join newline mold new-line/all compose/only message false]

	newmetafile: clean-path %source-tool.newmeta.txt
	newmeta: function [message] [write/append newmetafile join newline mold message]
    
    new-meta-order: [File Summary Section Project Homepage]
    new-meta-keys: none
    
    project-string: {Rebol 3 Interpreter and Run-time (Ren-C branch)}

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
            
            conversion/new-meta-keys: copy []

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
                        either find/match hdr {//} [
    						keep compose [(file) not-parsed-2016]
                        ][
    						keep compose [(file) not-parsed]
                        ]
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
				{Return header text}
				source [block! string! none!]
				/local old-text new-text legal project
                p1 p2 thru-divider
			] [
            
                old-text: format2016-firstdraft copy source
                
                ; Apply new ammendment:
                ; - Update the first draft format to newer format
                ; - taking into account that Hostilefork has some added some manually formatted files.
                
                project: rejoin [
                    {//  Project: } project-string newline
                    {//  Homepage: https://github.com/metaeducation/ren-c/^/}
                ]
                
                thru-divider: [thru {//=} 5 100 #"/" thru newline]
                
                if not parse/all new-text: old-text [
                
                    p1:
                    opt {//^/}
                    {// Rebol 3 Language Interpreter and Run-time Environment} newline
                    {// "Ren-C" branch @ https://github.com/metaeducation/ren-c} newline
                    {//^/}
                    p2: (remove/part p1 p2) :p1
                    
                    p1: thru-divider
                    p2: (legal: copy/part p1 p2)
                    
                    any {//^/}
                    p2: (p1: remove/part p1 p2) :p1
                    
                    (
                        if not find/match p1 {//  Project:} [
                            ; For files that did not start as format2012.
                            insert p1 project
                        ]
                        insert p1 {//^/} ; First line.
                    )

                    thru-divider
                    p1: (insert p1 join {//^/} legal) :p1
                    
                    to end
                ][
                    log [not-final-format: (source/file)]
                    RETURN old-text
                ]

                ; Header metadata is now consistent, reload and reformat as required.
                if not parse/all new-text [
                    p1: to {^///=} skip p2: to end
                ][
                    fail {Divider missing.}
                ]
                
                meta: copy/part p1 p2
                decode-lines meta {//} {  }
                meta: keyed-strings/decode meta
                foreach [key value] meta [
                    if not find [File Homepage Section] key [meta/(key): mold value]
                ]
                append new-meta-keys exclude extract meta 2 new-meta-keys ; What keys do we end up with..
                meta: meta-sort meta
                ;; meta: keyed-strings/encode/aligned meta 11 {  }
                meta: keyed-strings/encode meta
                encode-lines meta {//} {  }
                change/part p1 join {//^/} meta p2
                                
                new-text
            ]

			format2016-firstdraft: func [
				{Return header text in first draft format}
				source [block! string!]
				/local header text key-string
			] [

				digit: charset {0123456789}

				header: source/header

				if none? header [return copy {}]

				either string? header [
					text: copy header
				] [

					section-line: {//=////////////////////////////////////////////////////////////////////////=//^/}
                    
					text: rejoin collect [
                    
						keep newline
						keep reduce [{Rebol 3 Language Interpreter and Run-time Environment} newline]
						keep reduce [{"Ren-C" branch @ https://github.com/metaeducation/ren-c} newline]

						rights: any [header/rights []]
						if not empty? rights [
							keep newline

							creator-copyright: first rights
							contributor-date: none
							if not parse/all creator-copyright [
								{Copyright } copy contributor-date 4 digit { } to end
							][
								fail {Could not get creator-copyright date.}
							]
							if contributor-date <> {2012} [
								log [contributor-date (source/file) (contributor-date)]
							]

							keep reduce [creator-copyright newline]
							keep rejoin [{Copyright } contributor-date {-} now/year { Rebol Open Source Contributors^/}]

							if 1 < length rights [
								issue [copyright-notice-removed (source/file) (copy next rights)]
							]

						] ; Needs to be conditional due to s-unicode.c

						if true [
							keep {REBOL is a trademark of REBOL Technologies^/}
						]
						keep newline

						if not empty? rights [
							keep {See README.md and CREDITS.md for more information.^/}
							keep newline
						]

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

                            meta: copy header/meta
                            remove-each [key value] meta [find [Notes Author] key]
;;							meta: keyed-strings/encode/aligned meta 10 {  }
							meta: keyed-strings/encode meta
							keep encode-lines meta {} { }
							keep section-line
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

				if not find/match text {//} [
                    text: rejoin [
					    encode-lines text {//} { }
				    ]
                ]

				replace/all text {^/// //=/} {^///=/}
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
                            keep keyed-strings/encode header/meta 10 {  }
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
        
        meta-sort: function [
            {Sort the meta data in the header.}
            meta
        ][
        
            keys: append copy new-meta-order exclude extract meta 2 new-meta-order
            ; Additional keys come last.
            
            new-line/all/skip collect [
            
                foreach key keys [
                    if pos: find meta key [
                        keep compose/only [(:key) (:pos/2)]
                    ]
                ]
            ] true 2
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
        header.style:
		none

		grammar: context [

			rule: [
				(header.text: none)
				eoh:
				[format2012.header | format2016.header]
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
                (header.style: 'format2012)
			]

			format2016.header: [
				opt [{//} newline]
				copy header.text some [
					{//=} thru newline ; Section line
					| {//} wsp thru newline ; Text line
					| {//} newline ; Blank line
				]
                (header.style: 'format2016)
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
					all [
                        header.style = 'format2012
                        parse-format2012-header header.text
                    ]
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
                        keyed-strings/parser/grammar/fields (meta: keyed-strings/parser/meta)
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

			hdr: conversion/header/as/format2016 source

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

		move-key-to-notes: func [
			key [word!]
		][
			if position: find meta key [
				if not find meta 'Notes [append meta compose [Notes (none)]]
				if none? meta/notes [meta/notes: copy {}]
				value: meta/:key
				if key = 'See [insert value rejoin [mold key {: }]]
				if not empty? meta/notes [append value {^/^/}]
				insert meta/notes value
				remove/part position 2
				log [move-to-notes (file) (key)]
			]
		]

		old-text: read/string join source.folder file
        
		source: compose [
			file (file)
			(source-text/load old-text)
		]

		header: source/header

		if all [
			block? header
			block? meta: header/meta
		] [

			if find [
				%src/core/p-signal.c
				%src/os/linux/dev-signal.c
			] source/file [
				; @zsx (Atronix) created this file.
				new-rights: [{Copyright 2014 Atronix Engineering, Inc.}]
				issue [copyright-notice-removed (source/file) (exclude source/header/rights new-rights)]
				source/header/rights: new-rights
			]

			replace meta 'Title 'Summary
			replace meta 'Module 'File
			replace meta 'Note 'Caution

			if not find meta 'File [
				insert meta compose [File (form second split-path file)]
				log [add-meta (file) File]
			]
			meta/file: mold to file! meta/file

			move-key-to-notes 'Compile-note
			move-key-to-notes 'Flags
			move-key-to-notes 'Usage
			move-key-to-notes 'Design-comments
			move-key-to-notes 'Warning
			move-key-to-notes 'Description
			move-key-to-notes 'See
			move-key-to-notes 'Purpose
			move-key-to-notes 'Special-note
			move-key-to-notes 'Caution
            
            insert meta compose [
                Project (project-string) 
                Homepage https://github.com/metaeducation/ren-c/
            ]

			remove-each [key value] fields: copy meta [key = 'notes]
			newmeta new-line/all/skip compose [source (file) (fields)] true 2
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

keyed-strings: context [

    decode: func [
        {Decode the keyed-strings format.}
        text [string!]
    ][
        if parse/all text parser/grammar/fields [
            parser/meta
        ]
    ]

    encode: func [
        pairs [block!] {Block of key value pairs where value must be a string.}
        /aligned
        key-width [integer!] {Align single line values by using this width for the key column.}
        indent [integer! string!] {Indent used when value is multiple lines. Default is two spaces.}
        /local key-string pad
    ][

        if not aligned [ident: {  }]
        if integer? indent [indent: head insert/dup copy {} { }]

        pad: 0
        if aligned [
            pad: func [][max 0 key-width - length key-string]
        ]

        rejoin collect [
        
            keep {} ; Ensure we return a string result.
        
            foreach [key value] pairs [

                value: form :value

                key-string: join form key #":"

                either find value newline [
                    value: join newline encode-lines value {} indent
                ] [
                    insert/dup tail key-string #" " 1 + pad
                    if empty? value [value: none]
                    value: join value newline
                ]

                keep rejoin [key-string value]
            ]
        ]
    ]
    
    parser: context [
    
        meta: none
        position: eof: eol:
        none
    
        emit-meta: func [/local key] [
            meta: any [meta copy []]
            key: replace/all copy/part position eof #" " #"-"
            remove back tail key
            append meta reduce [
                to word! key
                trim/auto copy/part eof eol
            ]
        ]

        grammar: context [

            fields: [
                (meta: none)
                some [
                    position:
                    field
                    | newline
                ]
            ]
                    
            field: [
                field-name eof: [
                    #" " to newline any [
                        newline not-field-name not-eol to newline
                    ]
                    | any [1 2 newline 2 20 #" " to newline]
                ] eol: (emit-meta) newline
            ]

            field-char: charset [#"A" - #"Z" #"a" - #"z"]
            field-name: [some field-char any [#" " some field-char] #":"]

            not-field-name: parsing-unless [field-name]
            not-eol: parsing-unless [newline]
        ]
    ]
]