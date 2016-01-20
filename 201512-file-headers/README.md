file headers change
=========================

A one-off format conversion project to modify the file heading comments
in Rebol C source files. 

Currently a work in progress.


Approach
--------

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

Conversion Notes
----------------

[See the work in progress versions of the header conversion.](https://github.com/codebybrett/temporary.201512-file-headers)

### Copyright statement modifications proposals - needing confirmation ###

Add a generic copyright notice to every header without checking if any changes
covered by it exist. The idea is to rely upon GitHub commits to identify contributors.

A problem is that a company's copyright may not be adequately identified by the individual's username
and some people may have individual copyright or have assigned their copyright to a company.
Perhaps a simple solution to this would be for the copyright owner to be listed first on one line then
on a second line the contributor which in addition to the github username can include a
comment that identifies the contribution in some way or links to further information.
As an example (note @earl appears twice):

    Andreas Bolka
    @earl ; Keeper of rebol keys.
    
    Atronix Engineering, Inc ; [Zoe, built with Rebol.](http://www.atronixengineering.com/zoe/)
    @zsx Shixin Zeng

    Brett Handley
    @codebybrett ; Long time Rebol user now contributing to Rebol using Rebol.

    Brian Dickens
    @hostilefork ; ["Not actually *hostile* (just a bit irate.)"](http://www.hostilefork.com/)

    [Rebol Technologies](rebol.com) ; Released source 12/12/2012.
    @carls Carl Sassenrath ; Creator of REBOL.

    Saphirion AG ; [See our Saphir Rebol work](http://development.saphirion.com/rebol/)
    @earl Andreas Bolka
    @ladislav Ladislav Mecir
    ...
    
    etc...

Remove copyright notices for Rebol Technologies from the following files because
it appears that Atronix Engineering originally created the file:

* %src/core/p-signal.c
* %src/os/linux/dev-signal.c

Remove copyright notices for Saphirion AG from the following files on the basis
that the effect of the notice is covered by the new generic contributor notice and that
the contributions are documented by GitHub commits:

* %src/os/linux/dev-signal.c
* %src/os/windows/dev-clipboard.c
* %src/os/windows/host-lib.c

### Metadata key modifications ###

Prior to conversion metadata was not parsed and not always consistent.

The conversion parses existing files and records the exisiting metadata in source-tool.headers.r

The following changes are made by the conversion to metadata, note that move-key-to-notes inserts the associated value string at the beginning of Notes:

    replace meta 'Title 'Summary
    replace meta 'Module 'File
    replace meta 'Note 'Caution

    move-key-to-notes 'Compile-note
    move-key-to-notes 'Flags
    move-key-to-notes 'Usage
    move-key-to-notes 'Design-comments
    move-key-to-notes 'Warning
    move-key-to-notes 'Description
    move-key-to-notes 'See
    move-key-to-notes 'Purpose
    move-key-to-notes 'Special-note
    move-key-to-notes 'Caution

### Other Issues ###

* A licence condition of the Jpeg library source is that the Readme file be distributed. I do not know what version of Jpeg source Rebol uses so I don't know what readme to use.


Acknowledgement
---------------

It was @hostilefork's idea to embedded Rebol loadable data into the C source file headers
at the same time as cleaning those headers up. 
