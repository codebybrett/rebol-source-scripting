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

	files: context [

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

		foreach file files/list [update file]
	]

	source-text: context [

		{Source text.}

		grammar: context [
		]

		parse: func [
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
	]

	update: func [
		{Rewrite the header and save the changes.}
		file [file!]
	] [

		old-text: read join source.folder file
		source: source-text/parse old-text
		edit source
		new-text: source-text/render source

		if not equal? old-text new-text [
			write join target.folder file new-text
			log [updated (file)]
		]
	]
]
