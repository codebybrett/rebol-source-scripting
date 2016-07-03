file headers change
=========================

A one-off format conversion project to modify the file heading comments
in Rebol C source files. 

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

Work in progress versions of the header conversion are held in a [temporary repo](https://github.com/codebybrett/temporary.201512-file-headers).

### Copyright statement modifications proposals - needing confirmation ###

Add a generic copyright notice to every header without checking if any changes
covered by it exist. The idea is to rely upon GitHub commits to identify contributors.

* A problem is that a company's copyright may not be adequately identified by the individual's username
and some people may have individual copyright or have assigned their copyright to a company.
Perhaps a simple solution to this would be for the copyright owner to be listed first on one line then
on a second line the contributor which in addition to the github username can include a
comment that identifies the contribution in some way or links to further information.
* A temporary wiki based [Credits file](https://github.com/codebybrett/temporary.201512-file-headers/wiki/Draft-CREDITS) has been set up for an example. Note in the example that @earl appears twice.

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

### Conversion done 20-Mar-2016 ###

Conversion was done using the Rebolsource version of R3 Alpha.

Conversion [Pull Request](https://github.com/metaeducation/ren-c/pull/248):

The script logs (source-tool.*.*) were written to Ren-C then subsequently deleted. Browse them [here](https://github.com/metaeducation/ren-c/tree/91f0cff531d3bc6b664d83cd5b812d72c0812e92):

* source-tool.analysis.r - Summary analysis of meta information used during development.
* source-tool.authors.r - Author information extracted from files during conversion.
* source-tool.headers.r - Results of file header parsing.
* source-tool.issues.txt - Conversion actions that required discussion.
* source-tool.log.txt - Conversion script log.
* source-tool.newmeta.txt - Meta information after key modifications.

Further discussion on this conversion is [here](https://github.com/codebybrett/rebol-source-scripting/issues/1).

Authorship information was removed and placed in Credits.md wiki on the temporary repo mentioned above for discussion with contributors. @hostilefork
will be moving that to Ren-C separately.

Acknowledgement
---------------

It was @hostilefork's idea to embedded Rebol loadable data into the C source file headers
at the same time as cleaning those headers up. 
