REBOL [
	title: {Notes edit list}.
	purpose: {Make some automated edits to notes on native functions.}
	comment: {Checksum is of the old note, checksum must match before edit is applied.}
]

[
    quit [checksum #{33F343B6AAD8E11ECFC2FED252FA20B230C87782} new {^/While QUIT is implemented via a THROWN() value that bubbles up
through the stack, it may not ultimately use the WORD! of QUIT
as its /NAME when more specific values are allowed as names.
}] 
    stack [checksum #{1DDEEC89DA618603FD7DCB9DF86323A199A2BD51} new "^/"] 
    checksum [checksum #{34B85CDF1060856550D281BF610DFECAF6C6E832} new "^/"] 
    difference [checksum #{340C2AD88AFBFA4C99B1D5393646BC0AE8B0A2B7} new "^/Set functions share this argument pattern.^/"] 
    for-each [checksum #{9CFF9B883D9F9A9BDB096B4232A2D40FEB288B35} new "^/"] 
    remove-each [checksum #{C2A93F237065C7F87648925B7F6C40A2A346FD39} new "^/"] 
    map-each [checksum #{C2A93F237065C7F87648925B7F6C40A2A346FD39} new "^/"] 
    every [checksum #{C2A93F237065C7F87648925B7F6C40A2A346FD39} new "^/"] 
    form [checksum #{7481D6A1E969AEC480E3632200A07A6E9DD6E755} new "^/"] 
    mold [checksum #{7481D6A1E969AEC480E3632200A07A6E9DD6E755} new "^/"] 
    now [checksum #{7E1A253329D5BAEB7A568563D6E563E99E76BCF4} new {^/Return the current date and time with timezone adjustment.
}] 
    call [checksum #{856A3786AC5754591CD5999B1CFB93F3C055DFBD} new "^/"] 
    bind [checksum #{C6945C90DC64CA09AA8BEE848C63CF79EB5565C0} new "^/"] 
    collect-words [checksum #{79E33F49CD22B9F35817FDB3BCCB926523FA678B} new "^/"] 
    resolve [checksum #{745652813DD29C8F36A2BC6B749A3F8A4089B6DD} new "^/"] 
    set [checksum #{13466E4F2CCC4124520E5C705EBC2C9327D5E0F0} new "^/"] 
    apply [checksum #{102D77D8D8138E7B28398567C5B706CFCC7AA1E3} new "^/"] 
    break [checksum #{ABF6BF24AE0A11D6ECA726A7346F46976900717D} new {^/While BREAK is implemented via a THROWN() value that bubbles up
through the stack, it may not ultimately use the WORD! of BREAK
as its /NAME.
}] 
    case [checksum #{03D5DC4A2DF77918B00BDDBA805E968A951AAC51} new "^/"] 
    catch [checksum #{7E2D07E99AD8338B8FD4088E3BA9B535DC61280B} new {^/There's a refinement for catching quits, and CATCH/ANY will not
alone catch it (you have to CATCH/ANY/QUIT).  The use of the
WORD! QUIT is pending review, and when full label values are
available it will likely be changed to at least get the native
(e.g. equal to THROW with /NAME :QUIT instead of /NAME 'QUIT)
}] 
    compose [checksum #{BA36D51896C112196075B6D435811395471A6F36} new {^/!!! Should 'compose quote (a (1 + 2) b)' give back '(a 3 b)' ?
!!! What about 'compose quote a/(1 + 2)/b' ?
}] 
    exit [checksum #{213665D1A56BA181ADEBA2D1B666C443BDBCA588} new {^/While EXIT is implemented via a THROWN() value that bubbles up
through the stack, it may not ultimately use the WORD! of EXIT
as its /NAME.
}] 
    switch [checksum #{D957717CB3E89BFBA0B608A7BF86DD4E70C97B27} new "^/"] 
    trap [checksum #{C034823694061E74EBF78909A627BAAD5EF5C24C} new "^/"] 
    load-extension [checksum #{B5B9FF415FDA5D8015DD31F449B1D33FB4CD8CCA} new {^/Low level extension loader:

1. Opens the DLL for the extension
2. Calls its Info() command to get its definition header (REBOL)
3. Inits an extension structure (dll, Call() function)
4. Creates a extension object and returns it
5. REBOL code then uses that object to define the extension module
   including commands, functions, data, exports, etc.

Each extension is defined as DLL with:

init() - init anything needed
quit() - cleanup anything needed
call() - dispatch a native
}]
]