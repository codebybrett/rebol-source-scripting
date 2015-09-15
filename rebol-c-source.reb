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
			intro-comment
			any eol
			function.decl
			function.body
		]

		to-function: [any [not-function-section segment]]
		not-function-section: parsing-unless function-section

		intro-comment: [some [line-comment eol]]
		not-intro: parsing-unless intro-comment

		other-section: [some [not-intro preprocessing-token]]

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
				not-rbrace [braced | preprocessing-token]
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
			'record [word!] {Word set to an object for each function.}
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

				position: none
				parse/all/case text [grammar/function-section position:]

				if not position [
					do make error! reform [{Could not determine extent of function-section at position} index? text]
				]

				set [meta notes] parse-intro/next text 'position

				decl: parse-decl position

				spec: compose/only [
					meta: (meta)
					notes: (notes)
					decl: (decl)
				]

				set record make object! spec

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
			terminals: bind [function.id] grammar
			tree: get-parse/terminal [parse/all/case string [grammar/function.decl position:]] terms terminals

			if next [set var position]

			using-tree-content tree

			words: map-each node at tree/4 4 [assert [node/1 = 'function.id] node/3/content]
			args: map-each node at tree/5 4 [assert [node/1 = 'function.id] node/3/content]

			reduce [words args]
		]

		parse-intro: funct [
			{Load function introduction comment.}
			string
			/next {Set a variable with next position.}
			var [word!] "Variable updated with new block position"
		] [

			if none? string [return none]

			parse/all string [
				some [{//} [newline | #" " thru newline]]
				any newline
				position: (prefix: {//})
			]

			if next [set var position]
			if position [

				lines: copy/part string position
				lines: decode-lines lines prefix {}
				trim/auto lines
				; Indent subject to manual edits, don't trust it.

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

	natives: funct [
		{Loads native specs from C source files.}
		/only {Return natives as individual blocks.}
	] [

		result: make block! 400

		foreach file list/c-file [

			log [parse-natives (file)]

			parser/foreach-func-NO-RETURN x read/string src-folder/:file [
				if attempt [x/meta/2 = 'native] [
					either only [
						insert/only position: tail result compose/only [
							file (file)
							spec (x/meta)
						]
					] [
						insert position: tail result x/meta
					]
					new-line position true
				]
			]
		]

		result
	]
]
