REBOL [
	title: {source-tool}
	purpose: {Automatic source code modifications.}
	author: {Brett Handley}
	license: {Apache 2.0}
]

; --------------------------------------------------------------
; Change the CONFIG section below as necessary.
; Debugging mode writes old and new files to subfolders of current.
;
; INITIAL CONVERSION of old format to new
;
;	Run it once for the conversion to the new format.
;
;
; NORMAL USAGE:
;
;	source-tool/update/all
;
; AD HOC USAGE:
;
;	source-tool/init ; Need this to load and index data.
;
;	help source-tool/list
;
;
; OBJECTIVES:
;
;	* Write function specification into c source file comments.
;	* Index native function arguments.
;	* Not write files unless necessary.
;	* Not overwrite any existing notes in the comments.
;	* Be robust in the face of introduced parse rule bugs.
;
; NOTE:
;
;	Some C identifiers are different to the words they define.
;	- See C-ID-TO-WORD for the mapping.
;
;	Supports tools (e.g. coverity that use comments
;	to annotate declarations by maintaing a comment intact
;	that follows the intro comment but just prior to the
;	declaration.
;
;	Runs on Rebol 2 and Rebol 3.
;
; --------------------------------------------------------------

script-needs [
	%apropos.reb
	%parse-kit.reb
	%trees.reb
	%read-below.reb
	%text-lines.reb
	%../rebol-source-conventions.reb
]

source-tool: context [

	; --- Config 

	rebol.source.folder: clean-path %../../ren-c/src/
	rebol.output.folder: rebol.source.folder

	boot.natives.file: rebol.source.folder/boot/natives.r

	notes-edit-list: %notes-edit-list.reb

	max-line-length: 79 ; Not counting newline.

	logfile: clean-path %source-tool.log.txt
	log: func [message] [write/append logfile join newline mold new-line/all compose/only message false]

	debug: none
	; Set to NONE or :LOG ...

	timing: function [code /local result] [
		started: now/precise
		log [started (code)]
		set/any 'result do code
		finished: now/precise
		log [finished (code) (difference finished started)]
		get/any 'result
	]

	; --- End Config

	stats: context [
		parsed: none
		not-parsed: none
		decl-updated: none
		files-written: none
		width-exceeded: none
	]


	init: func [{Load and index the data.}] [

		reset ; Start fresh.

		timing [r-source/process]
		timing [c-source/process]

		log [words-missing-specs (new-line/all list/missing/specs false)]
		log [words-missing-rebnatives (new-line/all list/missing/rebnatives false)]
	]

	list: context [

		missing: context [

			rebnatives: func [] [
				exclude r-source/native/names c-source/rebnatives
			]

			specs: func [] [
				exclude c-source/rebnatives r-source/native/names
			]

		]
	]

	reset: func [{Clear caches.}] [

		r-source/reset
		c-source/reset

		set stats none
	]

	update: context [

		all: func [] [

			timing [init]
			timing [code]
			timing [files]

			log [stats (body-of stats)]

			reset ; Allow caches to be garbage collected.
		]

		code: func [{Update source (in-memory).}] [

			debug [update-code]

			apropos c-source/decl [
				foreach def list [sync-to-code def]
			]
		]

		files: func [{Write changes to source files.}] [

			debug [update-files]

			apropos c-source [
				foreach name list/changed [file/update name]
			]

			exit
		]
	]

	c-source: context [

		rebnative-index: none

		comment: context [

			format: context [

				slashed: func [text] [

					encode-lines copy text {//} { }
				]

				starred: function [text] [

					width: max-line-length - 2

					rejoin [
						{/*} line* width newline
						encode-lines copy text {**} {  }
						line* width {*/} newline
					]
				]
			]

			line*: func [{Return a line of *.} count] [

				head insert/dup copy {} #"*" count
			]

			load: func [string /local lines prefix] [

				if none? string [return none]

				parse/all string [

					; Slashed.
					copy lines some [{//} [newline | #" " thru newline]]
					(prefix: {//})

					| [ ; Starred
						{/*} 20 200 #"*" newline
						copy lines some [{**} [newline | #" " thru newline]]
						20 200 #"*" #"/" newline
						to end
						(prefix: {**})
					]
				]

				if lines [
					lines: decode-lines lines prefix {  }
					decode-function-meta lines
				]
			]
		]

		decl: context [

			list: none

			format: function [def][

				intro: comment/format/slashed def/intro-notes

				if lines-exceeding max-line-length intro [
					log [line-width-exceeded intro (mold def/file) (def/name) (def/param)]
					stats/width-exceeded: 1 + any [stats/width-exceeded 0]
				]

				parts: collect [

					if def/pre-comment [
						keep def/pre-comment
						keep newline
					]

					foreach word def/keywords [
						keep word
						if "*" <> word [keep #" "]
					]

					keep def/name
					keep rejoin [#"(" def/param #")" newline]

					if def/post-notes [
						post-comments: trim/tail copy def/post-notes
						encode-lines post-comments {//} { }
						keep post-comments
					]

					keep "^{^/"

					if def/body-notes [
						body-comments: copy def/body-notes
						encode-lines body-comments {^-//} { }
						keep body-comments
					]
				]

				rest: rejoin parts

				if lines-exceeding max-line-length rest [
					log [line-width-exceeded non-intro (mold def/file) (def/name) (def/param)]
				]

				join intro rest
			]

			normalise: function [def][

				debug [normalising (def)]

				name: def/name
				r.id: none

				either def/style = 'new-style-decl [

					set [meta notes] comment/load def/intro-notes
					if none? meta [
						log [warning meta-not-decoded (def)]
					]
				][

					either rebnative? def [

						r.id: c-id-to-word name: def/param
						r-info: attempt [copy r-source/native/cache/:r.id]

						meta: compose/only [
							(to set-word! r.id) native (r-info)
						]
					][

						meta: compose/only [
							(to set-word! form name) C
						]
					]

					new-line meta true

					if def/post-notes [def/post-notes: rejoin [newline def/post-notes newline]]
					notes: def/post-notes
					def/post-notes: none

					if def/intro-notes [
						def/pre-comment: rejoin [{/*} def/intro-notes {*/}]
						def/intro-notes: none
					]

					if all [
						notes
						r.id
						edit: attempt [r-source/notes-to-edit/:r.id]
						edit/checksum = checksum/secure to binary! notes
					][
						notes: edit/new
						if empty? trim copy notes [notes: none]
					]
				]

				if all [
					rebnative? def
					notes
				] [
					if find notes {1: } [
						log [suspected-numbered-arg-in-notes (def/file) (mold def/param)]
					]
					assert [none? def/post-notes]
					def/post-notes: notes
					notes: none
				]

				notes: any [notes {}]

				def/intro-notes: rejoin [mold-spec meta (max-line-length - 4) notes]
				def/style: 'new-style-decl
			]

			sync-to-code: function [def][

				tree: file/cache/(def/file)/tree
				position: at tree def/token

				node: first position
				node/1: def/style
				node/3/content: format def

				debug [update-decl (def/name) (def/param)]
				stats/decl-updated: 1 + any [stats/decl-updated 0]
			]

			where: function [condition [block!] "DEF is bound"] [

				collect [
					foreach def list compose/only [
						if (to paren! condition) [keep/only def]
					]
				]
			]

		]

		file: context [

			cache: none

			declarations: function [name] [

				result: make block! []

				tree: attempt [cache/:name/tree]
				if not tree [return result]

				position: at tree 4

				forall position [

					pattern: first position

					if all [
						word: in text/decl-parsers pattern/1
						def: do get word position
					] [
						insert def reduce ['file name]
						append/only result def
					]
				]

				result	
			]

			list: func [/local ugly-tmp-var] [

				remove-each name ugly-tmp-var: read-below rebol.source.folder [
					not parse/all name [[%core/ | %os/] thru %.c]
				]

				sort ugly-tmp-var
			]

			process: func [file /local source tree] [

				debug [process-c (file)]

				if not cache [cache: make block! 200]

				source: read/string rebol.source.folder/:file
				tree: text/parse-source source

				either tree [
					stats/parsed: 1 + any [stats/parsed 0]
				] [
					log [not-parsed (file)]
					stats/not-parsed: 1 + any [stats/not-parsed 0]
					return none
				]

				debug [tokenised-c (file)]

				if not equal? source text/regenerate tree [
					fail [{Tree for} (mold file) {does not represent the source file.}]
				]

				debug [check-regenerated-c (file)]

				if not find cache file [append cache reduce [file none]]
				cache/(file): compose/only [
					source (source)
					tree (tree)
				]

				debug [cached (file)]
			]

			respecified?: func [file] [

				not equal? cache/(file)/source source-for file
			]

			source-for: func [file] [

				text/regenerate cache/(file)/tree
			]

			update: func [name /local old new folder long-lines] [

				old: cache/(name)/source
				new: source-for name

				if long-lines: lines-exceeding 127 new [
					log [line-length-over-127 (mold name) (long-lines)]
				]

				if not equal? old new [

					target: rebol.output.folder/:name

					if not exists? folder: first split-path target [
						make-dir/deep folder
					]

					write target new
					stats/files-written: 1 + any [stats/files-written 0]
					debug [wrote (:name)]

					cache/(name)/source: new
				]

				exit
			]

		]

		rebnatives: function [] [

			extract rebnative-index 2
		]

		rebnative?: function [def][

			if def/name = "REBNATIVE" [
				if not def/single-param [
					?? def
					fail! {Expected REBNATIVE to have single parameter.}
				]
				true
			]
		]

		index-decls: func [/local id] [

			rebnative-index: collect [

				foreach def decl/list [

					if rebnative? def [

						keep id: c-id-to-word def/param

						keep/only compose/only [
							c.id (def/param)
							def (def)
						]
					]
				]
			]

			sort/skip rebnative-index 2
			new-line/all/skip rebnative-index true 2
		]

		list: context [

			files: func [{Cached files.}] [

				extract file/cache 2]

			changed: func [{Files that have had their contents changed.}] [

				exclude files unchanged]

			unchanged: func [{Unchanged files.} /local ugly-tmp-var] [

				remove-each name ugly-tmp-var: files [file/respecified? name]
				ugly-tmp-var
			]
		]

		parse-decls: func [] [

			decl/list: make block! []

			foreach name file/list [
				debug [file-decls (name)]
				append decl/list file/declarations name
			]

			if empty? decl/list [fail! {No declarations found. Check declaration parsing.}]
		]

		parse-files: func [] [

			foreach name file/list [file/process name]
		]

		normalise-decls: func [] [

			foreach def decl/list [decl/normalise def]
		]

		process: func [] [

			reset
			timing [parse-files]
			timing [parse-decls]
			timing [normalise-decls]
			timing [index-decls]
			exit
		]

		reset: func [] [

			file/cache: none
			decl/list: none
			rebnative-index: none
		]

		text: context [

			decl-parsers: context [

				; TODO: Is there a simpler way to get info from tree while checking assumptions?

				assert-node: function [
					{Check node at child slot position.}
					condition [word! block!] {Check condition for NODE, POSITION.}
					position
				][

					if word? condition [condition: compose [(to lit-word! condition) = node/1]]

					if not attempt [
						node: position/1
						do bind bind/copy condition 'node 'position
					][
						?? position
						fail [{Node does not satisfy} (mold condition)]
					]

					node
				]

				new-style-decl: function [ref /structure] [

					; TODO: Refactor out common code with old-style-decl

					node: ref/1
					string: node/3/content

					apropos text/parser/grammar [

						tree: get-parse [parse/all string new-style-decl] [
							decl.words decl.args.single decl.args.multi c.id c.special
							comment.doubleslash comment.banner comment.multiline.intact
						]
					]

					using-tree-content tree

					if structure [return tree] ; Used for debugging.

					position: at tree 4

					if find [comment.doubleslash comment.banner] position/1/1 [
						intro-notes: position/1/3/content
						position: next position
					]

					if 'comment.multiline.intact = position/1/1 [
						pre-comment: position/1/3/content
						position: next position
					]

					decl.words: assert-node 'decl.words position
					childpos: at decl.words 4
					decl.words: collect [
						forall childpos [
							c.id: assert-node [find [c.special c.id] node/1] childpos
							keep c.id/3/content
						]
					]

					name: last decl.words
					clear back tail decl.words

					position: next position
					decl.args: position/1
					either single-param: equal? 'decl.args.single decl.args/1 [
						c.id: assert-node 'c.id at decl.args 4
						param: c.id/3/content
					][
						assert-node 'decl.args.multi position
						param: decl.args/3/content
					]

					position: next position
					if all [
						not tail? position
						position/1/1 = 'comment.notes
					][
						post-notes: position/1/3/content

						insert post-notes newline
						replace/all post-notes {^/**^-} {^/**  }
						remove post-notes
						decode-lines post-notes {**} {  }
						replace/all post-notes tab {    }

						trim/tail post-notes
						trim/auto post-notes

						position: next position
					]

					if all [
						not tail? position
						position/1/1 = 'comment.doubleslash
					][
						body-notes: position/1/3/content
						position: next position
					]

					compose/only [
						name (name)
						keywords (decl.words)
						single-param (single-param)
						param (param)
						intro-notes (intro-notes)
						pre-comment (pre-comment)
						post-notes (post-notes)
						body-notes (body-notes)
						style new-style-decl
						token (index-of ref)
					]

				]

				old-style-decl: function [ref /structure] [

					node: ref/1
					string: node/3/content

					apropos text/parser/grammar [

						tree: get-parse [parse/all string old-style-decl] [
							decl.words decl.args.single decl.args.multi c.id c.special
							comment.notes
						]
					]

					using-tree-content tree

					if structure [return tree] ; Used for debugging.

					position: at tree 4

					if 'comment.notes = position/1/1 [
						intro-notes: position/1/3/content
						position: next position
					]

					pre-comment: none

					decl.words: assert-node 'decl.words position
					childpos: at decl.words 4
					decl.words: collect [
						forall childpos [
							c.id: assert-node [find [c.special c.id] node/1] childpos
							keep c.id/3/content
						]
					]

					name: last decl.words
					clear back tail decl.words

					position: next position
					decl.args: position/1
					either single-param: equal? 'decl.args.single decl.args/1 [
						c.id: assert-node 'c.id at decl.args 4
						param: c.id/3/content
					][
						assert-node 'decl.args.multi position
						param: decl.args/3/content
					]

					position: next position
					if all [
						not tail? position
						position/1/1 = 'comment.notes
					][
						post-notes: position/1/3/content

						insert post-notes newline
						replace/all post-notes {^/**^-} {^/**  }
						remove post-notes
						decode-lines post-notes {**} {  }
						replace/all post-notes tab {    }

						trim/tail post-notes
						trim/auto post-notes

						position: next position
					]

					if all [
						not tail? position
						position/1/1 = 'comment.doubleslash
					][
						body-notes: position/1/3/content
						position: next position
					]

					compose/only [
						name (name)
						keywords (decl.words)
						single-param (single-param)
						param (param)
						intro-notes (intro-notes)
						pre-comment (pre-comment)
						post-notes (post-notes)
						body-notes (body-notes)
						style old-style-decl
						token (index-of ref)
					]
				]
			]

			parser: context [

				guard: pos: none

				charsets: context [

					id.nondigit: charset [#"_" #"a" - #"z" #"A" - #"Z"]
					id.digit: charset {0123456789}
					id.rest: union id.nondigit id.digit
				]

				grammar: context bind [

					;
					; Be aware that other parts of the program depend
					; on the structure of this grammar definition.
					;

					rule: [opt file-comment some pattern rest]
					file-comment: [comment.multiline.standard]
					pattern: [old-section | old-style-decl | new-style-decl | comment | to-next]
					old-section: [{/*} stars newline stars newline opt comment.notes stars {*/} newline]
					old-style-decl: [
						[comment.decorative | comment.multiline.standard]
						wsp decl
						[comment.decorative | comment.multiline.standard]
						any newline
						#"{" newline
						opt comment.doubleslash
					]
					new-style-decl: [
						[comment.doubleslash some comment.doubleslash | comment.banner]
						any newline
						opt comment.multiline.intact
						any newline
						decl
						any newline
						#"{" newline
						opt comment.doubleslash
					]
					comment: [comment.doubleslash | comment.multiline.other]
					to-next: [first-comment-marker newline]
					first-comment-marker: parsing-earliest [[to {^///}] [to {^//*}]]
					rest: [to end]

					decl: [decl.words #"(" decl.args #")" opt wsp newline]
					decl.words: [c.id any [wsp c.id] opt [wsp c.special c.id]]
					decl.args: [decl.args.single | decl.args.multi]
					decl.args.single: [c.id pos: #")" :pos]
					decl.args.multi: [to #")"]
					c.id: [id.nondigit any id.rest]
					c.special: [#"*"]

					comment.banner: [{/*} stars newline opt comment.notes stars {*/} newline]
					comment.decorative: [
						{/*} some [stars | wsp | newline] {*/}
						| {//} stars
					]
					comment.multiline.intact: [{/*} opt stars newline any comment.note.line opt stars {*/}]
					comment.multiline.standard: [{/*} opt stars newline opt comment.notes opt stars {*/}]
					comment.multiline.other: [{/*} some [newline | stars | comment.note.text] {*/}]

					comment.doubleslash: [some [{//} thru newline]]

					comment.notes: [some comment.note.line]
					comment.note.line: [[[{**} | {//}] comment.note.text | stars] newline]
					comment.note.text: [some [not-eoc skip]]
					; Modified cheaply to accept doubleslash comments.

					stars: [#"*" some #"*" opt [pos: #"/" (pos: back pos) :pos]]

					not-eoc: either system/version > 2.100.0 [; Rebol3
						[not [{*/} | stars | newline]]
					] [; Rebol2
						[(guard: [none]) [opt [[{*/} | stars | newline] (guard: [end skip])] guard]]
					]

					wsp: compose [some (charset { ^-})]

				] charsets
				; Processed using action injection.

			]

			parse-source: func [
				{Parse tree structure from the source.}
				string
				/local parsed result terms
			] [

				terms: bind [
					file-comment
					old-section
					old-style-decl
					new-style-decl
					comment
					to-next rest
				] parser/grammar

				result: get-parse [parsed: parse/all string parser/grammar/rule] terms
				if not parsed [return none]

				prettify-tree using-tree-content result
			]

			regenerate: function [
				{Generate source text from source.}
				block [block!] {As returned from parse-source.}
			] [
				children: at block 4
				either empty? children [block/3/content] [
					rejoin map-each node children [regenerate node]
				]
			]
		]
	]

	pretty-spec: func [block] [

		new-line/all block false
		new-line/all/skip block true 2
	]

	r-source: context [

		notes-to-edit: none

		native: context [

			cache: none

			names: func [] [

				if none? cache [fail! {No specifications loaded. Use /init.}]
				extract cache 2
			]

			processing: func [
				/local block errors name spec position cache-item file
			] [

				notes-to-edit: load notes-edit-list

				file: boot.natives.file
				debug [process-natives (file)]

				if not cache [cache: make block! 200]

				block: load file

				cache-item: func [] [
					name: to word! :name
					if not find cache name [append cache reduce [:name none]]
					cache/(:name): spec
				]

				if not parse block [
					some [position:
						set name set-word! 'native set spec block! (cache-item)
						| skip ; TODO: Review - Error will never happen with this.
					]
				] [
					fail [{File} mold file {has unexpected format at position.} (index-of position)]
				]

				sort/skip cache 2
				exit
			]

		]

		process: func [] [

			reset
			native/processing
		]

		reset: func [] [

			notes-to-edit: none
			native/cache: none
		]
	]

]
