REBOL [
	Title: "Rebol C Source"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
	Purpose: {Process Rebol C source.}
]

script-needs [
	https://raw.githubusercontent.com/codebybrett/grammars/master/C/c-lexicals.reb
	%line-encoded-blocks.reb
	%load-until-blank.reb
	%parse-kit.reb
	%read-below.reb
	%trees.reb
]

rebol-c-source: context [

	src-folder: none
	; Path to src/

	logfn: func [message] [print mold new-line/all compose/only message false]
	log: none

	grammar: context bind [

		rule: [some segment]

		segment: [
			function-section
			| line-comment
			| other-section
		]

		function-section: [
			opt intro-section
			function.decl
			function.body
		]

		to-function: [any [not-function-section segment]]
		not-function-section: parsing-unless function-section

		intro-section: [intro-comment any eol]
		intro-comment: [some [line-comment eol]]
		not-intro: parsing-unless intro-comment

		other-section: [some [not-intro c-pp-token]]

		function.decl: [
			function.words function.args [eol | opt wsp eol]
			is-lbrace
		]

		function.words: [function.id any [wsp function.id] opt [wsp function.star function.id]]
		function.args: [#"(" any [function.id | wsp | not-rparen punctuator] #")"]
		function.id: copy identifier
		function.star: #"*"

		function.body: [braced]

		braced: [
			is-lbrace skip
			some [
				not-rbrace [braced | c-pp-token]
			]
			#"}"
		]

		is-punctuator: parsing-when punctuator
		is-lbrace: parsing-when [is-punctuator #"{"]
		not-rbrace: parsing-unless [#"}"]
		not-rparen: parsing-unless [#")"]

	] c.lexical/grammar

	valid?: funct [{Return true if the text can be parsed by the grammar.} text] [

		parse/all/case text grammar/rule
	]

	parser: context [

		find-function: funct [{Finds function in text.} text] [

			parse/all/case text [
				grammar/to-function
				position:
			]

			if not tail? position [
				position
			]
		]

		;
		; Rebol needs to bootstrap using old versions prior to having definitionally
		; scoped returns implemented.  Hence don't assume passing a body with
		; RETURN in it will return from the *caller*.  It will just wind up returning
		; from *this loop wrapper* (in older Rebols) when the call is finished!
		;
		foreach-func-NO-RETURN: func [
			{Iterate function sections by creating an object for each row.}
			'record [word!] {Word set to function metadata for each function.}
			text [string!] {C source text.}
			body [block!] {Block to evaluate each time.}
			/local position intro spec result meta notes
		] [

			position: text

			set/any 'result while [text: find-function position] [

				if same? text position [
					do make error! reform [
						{Failed to parse function beyond position} index? position
					]
				]

				spec: parse-function-section/next text 'position

				if none? spec/decl [
					do make error! reform [{Could not parse function declaration at position} (index? text) {spec} (mold spec)]
				]

				if not position [
					do make error! reform [{Could not determine extent of function-section at position} index? text]
				]

				set record spec

				do body
			]

			get/any 'result
		]

		parse-decl: funct [
			{Load function declaration.}
			string [string!]
			/next {Set a variable with next position.}
			var [word!] "Variable updated with new block position"
		] [

			terms: bind [function.words function.args] grammar
			terminals: bind [function.id function.star] grammar

			tree: get-parse/terminal [
				parse/all/case string [grammar/function.decl position:]
			] terms terminals

			if empty? at tree 4 [return none] ; Not valid declaration.

			if next [set var position]

			using-tree-content tree

			words: map-each node at tree/4 4 [assert [find [function.id function.star] node/1] node/3/content]
			args: map-each node at tree/5 4 [assert [find [function.id function.star] node/1] node/3/content]

			reduce [words args]
		]

		parse-function-section: funct [
			{Load function section.}
			text
			/next {Set a variable with next position.}
			var [word!] "Variable updated with new block position"
		] [

			set [meta notes] parse-intro/next text 'position

			decl: parse-decl/next start: any [position text] 'position

			parse/all/case position [grammar/function.body eof:]
			if next [set var eof]

			spec: compose/only [
				proto (copy/part start position)
				decl (decl)
				meta (meta)
				notes (notes)
				position (index? text)
				length (subtract index? eof index? text)
			]
		]

		parse-intro: funct [
			{Load function introduction comment.}
			string
			/next {Set a variable with next position.}
			var [word!] "Variable updated with new block position"
		] [

			if none? string [return none]

			parse/all string [grammar/intro-section position: (prefix: {//})]

			if next [set var position]
			if position [

				lines: copy/part string position
				lines: attempt [decode-lines lines prefix {}]
				; The indent is subject to manual edits, don't trust it.

				if not lines [return none]

				result: load-until-blank lines
				if empty? result/2 [result/2: none]
				result
			]
		]
	]

	list: context [

		c-file: funct [{Retrieves a list of .c scripts (relative paths).}] [

			files: read-below src-folder
			remove-each file files [not parse/all file [thru %.c]]

			files
		]
	]

	scan: context [

		functions: funct [
			{Loads function specs from C source files.}
		] [

			result: make block! 400

			foreach file list/c-file [

				log [parse-natives (file)]

				parser/foreach-func-NO-RETURN spec read/string src-folder/:file [
					insert spec compose [file (file)]
					new-line/all/skip spec true 2
					insert/only position: tail result spec
					new-line position true
				]
			]

			result
		]

		natives: funct [
			{Loads native specs from C source files.}
		] [

			remove-each fn result: functions [
				not equal? "REBNATIVE" fn/decl/1/1
			]

			result
		]
	]
]
