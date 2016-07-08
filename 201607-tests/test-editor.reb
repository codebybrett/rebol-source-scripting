REBOL []

script-needs [
    %apropos.reb
    %core-test.parser.reb
]

test-editor: context [

    source-file: %../../ren-c/tests/core-tests.r
    natives-file: %../../ren-c/src/boot/tmp-natives.r

    tests-folder: %../../ren-c.scratchpad/201607-tests/
    output-file: join tests-folder %core-tests.r

    filepath: _
    outpath: _

    content: _
    new-core: _

    natives: _

    mapping: _

    parse-tests: func [][

        content: to-string read source-file

        ; Fix misplaced call to parse-tests.r
        replace content {; datatypes/action.r

%parse-tests.r} {%parse-tests.r

; datatypes/action.r}

        ; Fix typo.
        replace content {; functions/onvert/to-hex.r} {; functions/convert/to-hex.r}

        ; Insert a file title for source analysis tests.
        insert find content ";;^/;; Source analysis tests." {; source/analysis.r^/^/}

        parse content core-test.parser/grammar/start
    ]

    write-tests: func [
        /local file-content outpath name file new-filepath pos
        edit use-category use-subcategory edit-file
    ][

        print "writing..."

        apropos core-test.parser [

            edit: func [][
                attempt [make-dir/deep join tests-folder folder]
                outpath: join folder file
                file-content: copy/part file-start file-end

                print [{Output: } mold outpath]
                write join tests-folder outpath file-content
                
                file-ref: join %core/ outpath
                file-end: change/part file-start join mold file-ref newline file-end

                either pos: find/only mapping file-ref [
                    if not block? pos/2 [
                        change/only next pos reduce [pos/2] 
                    ]
                    append/only pos/2 filepath
                ][
                    append mapping reduce [file-ref filepath]
                ]
            ]

            use-category: func [][
                file: join to file! name %.test.reb
                folder: dirize to file! first filepath
            ]

            use-subcategory: func [][
                new-filepath: copy next filepath
                file: to file! mold next new-filepath
                append clear find/last file {.r} %.test.reb
                replace/all file {/} {.}
                folder: dirize to file! first new-filepath
            ]

            emit-file: func [][

                filepath: load copy file-title
                assert [path? filepath]

                file: last filepath

                name: form file
                clear find/last name ".r"

                unset 'folder

                case [

                    find [datatypes system source] first filepath [
                        use-category
                        edit
                    ]

                    all [
                        find natives name
                        not equal? 'datatypes first filepath
                    ] [
                        use-subcategory
                        edit
                    ]

                    'functions = first filepath [
                        use-subcategory
                        edit
                    ]
                ]

            ]
        ]

        mapping: copy []
        get-natives
        parse-tests

        remove-each [file path] file-clash: copy mapping [not block? path]
        if not empty? file-clash [
            print "File clashes:"
            print mold new-line/all/skip file-clash true 2
        ]

        write output-file content
    ]

    get-natives: func [/local word][
        natives: collect [
            parse load natives-file [any [set word set-word! (keep form to word! word) | skip]]
        ]
    ]
]
