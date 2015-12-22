file headers change
=========================

A one-off format conversion project to modify the file heading comments
in Rebol C source files. 

Currently a work in progress.

### Approach ###

The source file headers generally follow a strict format so parsing is
fairly straightword using REBOL's Parse dialect.

Developing a parser becomes a process of analysis of the header
variations and is going to be very accurate compared with eye balling
138 files. 

So first parse the file headers into a block representation to be used
to generate some experimental formats for discussion.

Run some checks over the representation to pick up omissions or
mistakes in the headers.

Generate the files without intentional modifications from the
representation which allows file comparison as a sanity check. There
will be differences but should not be a lot. 

Generate some proposed formats and discuss.

Once a new convention is agreed, apply the changes to the source files
and commit. 
### Acknowledgement ###

The idea to embedded Rebol loadable data into the C source file headers
at the same time as cleaning those headers up was initiated by @hostilefork. 
