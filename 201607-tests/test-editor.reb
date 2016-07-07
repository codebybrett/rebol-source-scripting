REBOL []

script-needs [
    %apropos.reb
    %core-test.parser.reb
]

test-editor: context [

    source-file: %../../ren-c/tests/core-tests.r

    tests-folder: %../../ren-c.scratchpad/tests/
    output-file: join tests-folder/core-tests.r

    filepath: none
    outpath: none

    content: none
    new-core: none

    parse-tests: func [][

        content: read source-file

        replace content {; datatypes/action.r

%parse-tests.r} {%parse-tests.r

; datatypes/action.r}

        parse/all content core-test.parser/grammar/start
    ]

    write-tests: func [][

        print "writing..."

        apropos core-test.parser [

            emit-file: func [/local outpath][
                filepath: join %core/ to file! replace/all copy file-title {/} {.}
                outpath: join tests-folder filepath
                ?? outpath
                make-dir/deep first split-path outpath
                write outpath copy/part file-start file-end
                file-end: change/part file-start join mold filepath newline file-end
            ]
        ]

        parse-tests

        write output-file content
    ]
]
