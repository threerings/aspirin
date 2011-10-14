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

if !exists("g:aspirin_open")
    let g:aspirin_open= "open"
endif

function! AspirinRescan()
    python aspirin.scan()
endfunction

function! AspirinJump()
    python aspirin.jump(vim.eval('expand("<cword>")'))
endfunction

function! AspirinAutoImport()
    python aspirin.addimports()
endfunction

function! AspirinImport()
    python aspirin.addimport(vim.eval('expand("<cword>")'))
endfunction

function! AspirinLastEx()
    python aspirin.send_ex_to_quickfix()
endfunction
