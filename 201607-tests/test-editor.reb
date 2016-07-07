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

    parse-tests: func [][

        content: to-string read source-file

        ; Fix misplaced call to parse-tests.r
        replace content {; datatypes/action.r

%parse-tests.r} {%parse-tests.r

; datatypes/action.r}

        ; Insert a file title for source analysis tests.
        insert find content ";;^/;; Source analysis tests." {; source/analysis.r^/^/}

        parse content core-test.parser/grammar/start
    ]

    write-tests: func [/local file-content outpath name file new-filepath][

        print "writing..."

        apropos core-test.parser [

            edit: func [][
                attempt [make-dir/deep join tests-folder folder]
                outpath: join folder file
                file-content: copy/part file-start file-end
                print [{Output: } mold outpath]
                write join tests-folder outpath file-content
                file-end: change/part file-start join mold outpath newline file-end
            ]

            emit-file: func [][

                filepath: load copy file-title
                assert [path? filepath]

                file: last filepath

                name: form file
                clear find/last name ".r"

                unset 'folder

                case [

                    find natives name [
                        file: join to file! name %.test
                        folder: %natives/
                        edit
                    ]

                    find [datatypes system source] first filepath [
                        file: join to file! name %.test
                        folder: dirize to file! first filepath
                        edit
                    ]

                    'functions = first filepath [
                        filepath: copy next filepath
                        file: to file! mold next filepath
                        append clear find/last file {.r} %.test
                        replace/all file {/} {.}
                        folder: dirize to file! first filepath
                        edit
                    ]
                ]

            ]
        ]

        get-natives
        parse-tests
      

        write output-file content
    ]

    get-natives: func [/local word][
        natives: collect [
            parse load natives-file [any [set word set-word! (keep form to word! word) | skip]]
        ]
    ]
]
