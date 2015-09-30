REBOL [
	Title: "Rebol Source Conventions"
	Version: 1.0.0
	Rights: {
		Copyright 2015 Brett Handley
	}
	License: {
		Licensed under the Apache License, Version 2.0
		See: http://www.apache.org/licenses/LICENSE-2.0
	}
	Author: "Brett Handley"
]

script-needs [
	%load-until-blank.reb
]

decode-function-meta: funct [
	{Return [meta notes] from intro text.}
	lines
] [

	result: load-until-blank lines
	if none? result [return none]

	if attempt [
		if empty? result/2 [result/2: none]
		parse result/1 [
			set-word! word!
			opt [
				position: string!
				opt ['- (remove next position)]
				(
					spec: copy position
					insert/only clear position spec
				)
			]
		]
	] [
		result
	]
]

c-id-to-word: func [
	{Translate C identifier to Rebol word.}
	identifier
	/local id
] [

	id: select [
		{_add_add} ++
	] identifier

	if not id [
		id: copy identifier
		replace/all id #"_" #"-"
		if #"q" = last id [change back tail id #"?"]
		id: to word! id
	]

	id
]


