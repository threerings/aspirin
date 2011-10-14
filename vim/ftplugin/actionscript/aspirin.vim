" Add mappings, unless the user didn't want this.
if !exists("b:did_aspirinplugin")
    let b:did_aspirinplugin = 1
	if !hasmapto('<Plug>AspirinJump')
        map <buffer> <unique> <LocalLeader>j <Plug>AspirinJump
    endif
    noremap <buffer> <silent> <unique> <Plug>AspirinJump :call AspirinJump()<CR>

    if !hasmapto('<Plug>AspirinOpenClass')
        map <buffer> <unique> <LocalLeader>o <Plug>AspirinOpenClass
    endif
    noremap <buffer> <silent> <unique> <Plug>AspirinOpenClass :call AspirinOpenClass()<CR>

   	if !hasmapto('<Plug>AspirinImport')
        map <buffer> <unique> <LocalLeader>i <Plug>AspirinImport
    endif
    noremap <buffer> <silent> <unique> <Plug>AspirinImport :call AspirinImport()<CR>

    if !hasmapto('<Plug>AspirinLastEx')
        map <buffer> <unique> <LocalLeader>x <Plug>AspirinLastEx
    endif
    noremap <buffer> <silent> <unique> <Plug>AspirinLastEx :call AspirinLastEx()<CR>
endif
