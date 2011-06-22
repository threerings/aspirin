" Vim plugin for navigating to and importing actionscript classes

if exists("g:loaded_aspirin")
    finish
endif
let g:loaded_aspirin = 1

python << EOF
import sys, vim
asdir = vim.eval('expand("<sfile>:h")')
if not asdir in sys.path:
    sys.path.append(asdir)
    import aspirin
else:
    reload(aspirin)
EOF

augroup aspirin
    autocmd!
    if exists("g:as_locations") && !exists("g:no_aspirin_autoimport")
        autocmd aspirin BufWritePre *.as call AspirinAutoImport()
    endif
augroup END

function! s:GetCursorWord()
    " get the current position, and then yank the word under the cursor into a register
    let s:startpos = getpos(".")
    normal wbyw
endfunction

function! AspirinRescan()
    python aspirin.scan()
endfunction

function! AspirinJump()
    call s:GetCursorWord()
    python aspirin.jump(vim.eval("getreg()").strip())
endfunction

function! AspirinAutoImport()
    call s:GetCursorWord()
    python aspirin.addimports()
endfunction

function! AspirinImport()
    call s:GetCursorWord()
    python aspirin.addimport(vim.eval("getreg()").strip())
endfunction

function! AspirinLastEx()
    python aspirin.send_ex_to_quickfix()
endfunction
