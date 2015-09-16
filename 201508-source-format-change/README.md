2015-source-format-change
=========================

A one-off format conversion project to modify Rebol C sources.

* Modify formating of function declarations from the original starred format
with intermingled function prototype to double slash function introduction
and cleanly separated function prototype.

* Function introduction comment to contain loadable Rebol block values
and separate free format notes.


### Notes ###

This grew out of an idea from @hostilefork and changed a bit as ideas changed.
It was written before I realised I could write a C source lexer (c-lexicals.reb)
which would have simplified the code considerably.

