REBOL []

script-needs [
    %apropos.reb
    %core-test.parser.reb
]

test-editor: context [

    source-file: %../../ren-c/tests/core-tests.r

    tests-folder: %../../ren-c.scratchpad/tests/
    output-file: join tests-folder %core-tests.r

    filepath: none
    outpath: none

    content: none
    new-core: none

    parse-tests: func [][

        content: read source-file

        ; Fix misplaced call to parse-tests.r
        replace content {; datatypes/action.r

%parse-tests.r} {%parse-tests.r

; datatypes/action.r}

        ; Insert a file title for source analysis tests.
        insert find content ";;^/;; Source analysis tests." {; source/analysis.r^/^/}

        parse/all content core-test.parser/grammar/start
    ]

    write-tests: func [/local file-content][

        print "writing..."

        apropos core-test.parser [

            emit-file: func [/local outpath][

                filepath: to file! replace/all copy file-title {/} {.}
                outpath: join tests-folder filepath
                ?? outpath

                folder: first split-path outpath
                if not equal? %./ folder [make-dir/deep folder]

                file-content: copy/part file-start file-end
                
                write outpath file-content
                file-end: change/part file-start join mold filepath newline file-end
            ]
        ]

        parse-tests

        write output-file content
    ]
]
