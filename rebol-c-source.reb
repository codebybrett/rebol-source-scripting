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
]

rebol-c-source: context [

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
			[identifier any [wsp identifier] opt [wsp #"*" identifier]]
			#"(" thru #")" [eol | opt wsp eol]
			is-lbrace
		]

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

	function: context [

		find: funct [{Finds function in text.} text] [

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
		foreach-NO-RETURN: func [
			{Iterate function sections by creating an object for each row.}
			'record [word!] {Word set to an object for each function.}
			text [string!] {C source text.}
			body [block!] {Block to evaluate each time.}
			/local position intro spec result meta notes
		] [

			position: text

			set/any 'result while [text: function/find position] [

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

				set [meta notes] function/intro text

				spec: compose/only [
					meta: (meta)
					notes: (notes)
				]

				set record make object! spec

				do body
			]

			get/any 'result
		]

		intro: funct [{Load function introduction comment.} string] [

			if none? string [return none]

			parse/all string [
				copy lines some [{//} [newline | #" " thru newline]]
				(prefix: {//})
			]

			if lines [

				lines: decode-lines lines prefix {}
				trim/auto lines
				; Indent subject to manual edits, don't trust it.

				result: load-until-blank lines
				if empty? result/2 [result/2: none]
				result
			]
		]
	]
]
