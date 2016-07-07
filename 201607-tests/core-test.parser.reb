REBOL []

script-needs [
    %parse-kit.reb
]

core-test.parser: context [

    position: none
    header: none
    file-title: none
    file-start: none
    file-end: none

    emit-file: none

    charsets: context [

        file-ch: charset [#"a" - #"z" #"0" - #"9"]
        wsp-ch: charset { ^-}
    ]

    grammar: context bind [

        wsp: [some wsp-ch]

        file-word: [some file-ch]
        file-spec: [file-word any [#"/" file-word] {.r}]
        file-line: [#";" wsp copy file-title file-spec opt wsp newline]

        not-file-line: parsing-unless [file-line]
        non-file-line: [not-file-line to newline]

        file-header: [thru {limitations under the License} thru {****^/}]

        section: [non-file-line any [newline non-file-line] any newline]

        file-section: [
            file-line
            opt section
        ]

        other-section: [section]

        start: [
            position: copy header file-header
            position: opt other-section
            some [
                position:
                file-start: file-section file-end: (emit-file) :file-end
                | other-section
            ]
        ]

    ] charsets

]
