2015-source-format-change
=========================

[Update: This conversion was run on 19 Nov 2015 against Ren/C ("REBOL C Source format conversion").]

A one-off format conversion project to modify Rebol C sources.

* Modify formating of function declarations from the original starred format
with intermingled function prototype to double slash function introduction
and cleanly separated function prototype.

* Function introduction comment to contain loadable Rebol block values
and separate free format notes.

* I do not expect to modify these scripts once the conversion is committed.

### Running the source format conversion ###

Assumes the parent repo shares a folder with the Ren-c repo. If not, modify config.reb.

Using Rebol 2 or Rebol 3:

    do %rebol-source-scripting/lib/env.reb
    do %rebol-source-scripting/201508-source-format-change/source-tool.run.reb

### Running the tab conversion ###

Assumes the parent repo shares a folder with the Ren-c repo. If not, modify config.reb.

Using Rebol 2 or Rebol 3:

    do %rebol-source-scripting/lib/env.reb
    do %rebol-source-scripting/201508-source-format-change/tab-conversion.run.reb

### Notes ###

This grew out of an idea from @hostilefork and changed a bit as ideas changed.
It was written before I realised I could write a C source lexer (c-lexicals.reb)
which would have simplified the code considerably.

