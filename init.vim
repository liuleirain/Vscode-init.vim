set clipboard=unnamedplus
" 行号
" set relativenumber=true
" set number=true
" 防止包裹
" set wrap=false
" 光标行
" set cursorline=true

" 默认新窗口右和下
" set splitright=true
" set splitbelow=true

" 搜索
set ignorecase
set smartcase

let mapleader = " "
nmap <leader>wq :wq<CR>
nmap <leader>s :w<CR>
if exists('g:vscode')
    " VSCode extension
else
    " ordinary Neovim
endif

function! s:openVSCodeCommandsInVisualMode()
    normal! gv
    let visualmode = visualmode()
    if visualmode == "V"
        let startLine = line("v")
        let endLine = line(".")
        " 最后一个参数 1 表示操作后仍处于选择模式，0 则表示操作后退出选择模式
        call VSCodeNotifyRange("workbench.action.showCommands", startLine, endLine, 1)
    else
        let startPos = getpos("v")
        let endPos = getpos(".")
        call VSCodeNotifyRangePos("workbench.action.showCommands", startPos[1], endPos[1], startPos[2], endPos[2], 1)
    endif
endfunction

" workaround for calling command picker in visual mode
xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>

nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>

nnoremap <C-w>gd <Cmd>call VSCodeNotify('editor.action.revealDefinitionAside')<CR>
nnoremap ? <Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>

" 单行移动
nnoremap K <Cmd>call VSCodeNotify('editor.action.moveLinesUpAction')<CR>
nnoremap J <Cmd>call VSCodeNotify('editor.action.moveLinesDownAction')<CR>

function s:reveal(direction, resetCursor)
    call VSCodeExtensionNotify('reveal', a:direction, a:resetCursor)
endfunction

nnoremap z<CR> <Cmd>call <SID>reveal('top', 1)<CR>
xnoremap z<CR> <Cmd>call <SID>reveal('top', 1)<CR>
nnoremap zt <Cmd>call <SID>reveal('top', 0)<CR>
xnoremap zt <Cmd>call <SID>reveal('top', 0)<CR>
nnoremap z. <Cmd>call <SID>reveal('center', 1)<CR>
xnoremap z. <Cmd>call <SID>reveal('center', 1)<CR>
nnoremap zz <Cmd>call <SID>reveal('center', 0)<CR>
xnoremap zz <Cmd>call <SID>reveal('center', 0)<CR>
nnoremap z- <Cmd>call <SID>reveal('bottom', 1)<CR>
xnoremap z- <Cmd>call <SID>reveal('bottom', 1)<CR>
nnoremap zb <Cmd>call <SID>reveal('bottom', 0)<CR>
xnoremap zb <Cmd>call <SID>reveal('bottom', 0)<CR>


function! s:vscodePrepareMultipleCursors(append, skipEmpty)
    let m = mode()
    if m ==# 'V' || m ==# "\<C-v>"
        let b:notifyMultipleCursors = 1
        let b:multipleCursorsVisualMode = m
        let b:multipleCursorsAppend = a:append
        let b:multipleCursorsSkipEmpty = a:skipEmpty
        " We need to start insert, then spawn cursors otherwise they'll be destroyed
        " using feedkeys() here because :startinsert is being delayed
        call feedkeys("\<Esc>i", 'n')
    endif
endfunction

function! s:vscodeNotifyMultipleCursors()
    if exists('b:notifyMultipleCursors') && b:notifyMultipleCursors
        let b:notifyMultipleCursors = 0
        call VSCodeExtensionNotify('visual-edit', b:multipleCursorsAppend, b:multipleCursorsVisualMode, line("'<"), line("'>"), col("'>"), b:multipleCursorsSkipEmpty)
    endif
endfunction

augroup MultipleCursors
    autocmd!
    autocmd InsertEnter * call <SID>vscodeNotifyMultipleCursors()
augroup END

" Multiple cursors support for visual line/block modes
xnoremap ma <Cmd>call <SID>vscodePrepareMultipleCursors(1, 1)<CR>
xnoremap mi <Cmd>call <SID>vscodePrepareMultipleCursors(0, 1)<CR>
xnoremap mA <Cmd>call <SID>vscodePrepareMultipleCursors(1, 0)<CR>
xnoremap mI <Cmd>call <SID>vscodePrepareMultipleCursors(0, 0)<CR>