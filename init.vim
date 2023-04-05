" 使用系统剪贴板
set clipboard=unnamedplus

" 防止包裹
set wrap

" 光标行
set cursorline

" 默认新窗口右和下
set splitright
set splitbelow

" 搜索
set ignorecase
set smartcase

" 使游标可见的插件使用假游标
hi Cursor gui=reverse

" 更改leader
let mapleader = " "
nmap <leader>wq :wq<CR>
nmap <leader>s :w<CR>

function s:forceLocalOptions()
    setlocal nowrap
    setlocal conceallevel=0
    setlocal hidden
    setlocal bufhidden=hide
    setlocal noautowrite
    setlocal nonumber
    setlocal norelativenumber
    setlocal list
    setlocal listchars=tab:??
    if exists('b:vscode_controlled') && b:vscode_controlled
        setlocal syntax=off
    endif
    setlocal nofoldenable
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nolazyredraw
endfunction

augroup VscodeForceOptions
    autocmd!
    autocmd BufEnter,FileType * call <SID>forceLocalOptions()
augroup END

" 插件加载
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

" 在可视模式下调用命令选择器的解决方案
xnoremap <silent> <C-P> :<C-u>call <SID>openVSCodeCommandsInVisualMode()<CR>

nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR> 
xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
" 向侧面开放定义
nnoremap <C-w>gd <Cmd>call VSCodeNotify('editor.action.revealDefinitionAside')<CR>
" 在可视模式下调用命令选择器的解决方案
xnoremap <C-P> <Cmd>call VSCodeNotifyVisual('workbench.action.quickOpen', 1)<CR>
xnoremap <C-S-P> <Cmd>call VSCodeNotifyVisual('workbench.action.showCommands', 1)<CR>
xnoremap <C-S-F> <Cmd>call VSCodeNotifyVisual('workbench.action.findInFiles', 0)<CR>
" 在文件搜索中搜索当前单词
nnoremap ? <Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>
" 切换标签
nnoremap H <Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>
nnoremap L <Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>

" 游标快速移动
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

" 将 C-/ 绑定到vscode注释，因为从vscode调用会由于多个游标而产生双重注释
xnoremap <expr> <C-/> <SID>vscodeCommentary()
nnoremap <expr> <C-/> <SID>vscodeCommentary() . '_'

function! s:vscodeGoToDefinition(str)
    if exists('b:vscode_controlled') && b:vscode_controlled
        call VSCodeNotify('editor.action.' . a:str)
    else
        " Allow to function in help files
        exe "normal! \<C-]>"
    endif
endfunction

" 多游标模式
function! s:vscodePrepareMultipleCursors(append, skipEmpty)
    let m = mode()
    if m ==# 'V' || m ==# "\<C-v>"
        let b:notifyMultipleCursors = 1
        let b:multipleCursorsVisualMode = m
        let b:multipleCursorsAppend = a:append
        let b:multipleCursorsSkipEmpty = a:skipEmpty
        " 我们需要开始插入，然后生成游标，否则它们会被销毁
        " 此处使用feedkeys()是因为:startinsert被延时了
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

" 多游标支持可视线/块模式
xnoremap ma <Cmd>call <SID>vscodePrepareMultipleCursors(1, 1)<CR>
xnoremap mi <Cmd>call <SID>vscodePrepareMultipleCursors(0, 1)<CR>
xnoremap mA <Cmd>call <SID>vscodePrepareMultipleCursors(1, 0)<CR>
xnoremap mI <Cmd>call <SID>vscodePrepareMultipleCursors(0, 0)<CR>

function! s:split(...) abort
    let direction = a:1
    let file = exists('a:2') ? a:2 : ''
    call VSCodeCall(direction ==# 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
    if !empty(file)
        call VSCodeExtensionNotify('open-file', expand(file), 'all')
    endif
endfunction

" 窗口命令
function! s:splitNew(...)
    let file = a:2
    call s:split(a:1, empty(file) ? '__vscode_new__' : file)
endfunction

function! s:closeOtherEditors()
    call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
    call VSCodeNotify('workbench.action.closeOtherEditors')
endfunction

function! s:manageEditorHeight(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewHeight' : 'workbench.action.decreaseViewHeight')
    endfor
endfunction

function! s:manageEditorWidth(...)
    let count = a:1
    let to = a:2
    for i in range(1, count ? count : 1)
        call VSCodeNotify(to ==# 'increase' ? 'workbench.action.increaseViewWidth' : 'workbench.action.decreaseViewWidth')
    endfor
endfunction

command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
command! -bang Only if <q-bang> ==# '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif

AlterCommand sp[lit] Split
AlterCommand vs[plit] Vsplit
AlterCommand new New
AlterCommand vne[w] Vnew
AlterCommand on[ly] Only

" 缓存区管理
nnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>
xnoremap <C-w>n <Cmd>call <SID>splitNew('h', '__vscode_new__')<CR>

nnoremap <C-w>q <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <C-w>q <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <C-w>c <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
nnoremap <C-w><C-c> <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
xnoremap <C-w><C-c> <Cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>

" 窗口/分割管理
nnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
xnoremap <C-w>s <Cmd>call <SID>split('h')<CR>
nnoremap <C-w><C-s> <Cmd>call <SID>split('h')<CR>
xnoremap <C-w><C-s> <Cmd>call <SID>split('h')<CR>

nnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
xnoremap <C-w>v <Cmd>call <SID>split('v')<CR>
nnoremap <C-w><C-v> <Cmd>call <SID>split('v')<CR>
xnoremap <C-w><C-v> <Cmd>call <SID>split('v')<CR>

nnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
xnoremap <C-w>= <Cmd>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>
nnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>
xnoremap <C-w>_ <Cmd>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>

nnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
xnoremap <C-w>+ <Cmd>call <SID>manageEditorHeight(v:count, 'increase')<CR>
nnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
xnoremap <C-w>- <Cmd>call <SID>manageEditorHeight(v:count, 'decrease')<CR>
nnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count,  'increase')<CR>
xnoremap <C-w>> <Cmd>call <SID>manageEditorWidth(v:count,  'increase')<CR>
nnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count,  'decrease')<CR>
xnoremap <C-w>< <Cmd>call <SID>manageEditorWidth(v:count,  'decrease')<CR>

nnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
xnoremap <C-w>o <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
nnoremap <C-w><C-o> <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>
xnoremap <C-w><C-o> <Cmd>call VSCodeNotify('workbench.action.joinAllGroups')<CR>

" 窗口的导航
nnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
xnoremap <C-w>j <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
nnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
xnoremap <C-w>k <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
nnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
xnoremap <C-w>h <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
nnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
xnoremap <C-w>l <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>

nnoremap <C-w><Down> <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
xnoremap <C-w><Down> <Cmd>call VSCodeNotify('workbench.action.focusBelowGroup')<CR>
nnoremap <C-w><Up> <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
xnoremap <C-w><Up> <Cmd>call VSCodeNotify('workbench.action.focusAboveGroup')<CR>
nnoremap <C-w><Left> <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
xnoremap <C-w><Left> <Cmd>call VSCodeNotify('workbench.action.focusLeftGroup')<CR>
nnoremap <C-w><Right> <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>
xnoremap <C-w><Right> <Cmd>call VSCodeNotify('workbench.action.focusRightGroup')<CR>

nnoremap <C-w><C-j> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
xnoremap <C-w><C-j> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
nnoremap <C-w><C-i> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
xnoremap <C-w><C-i> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
nnoremap <C-w><C-h> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
xnoremap <C-w><C-h> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
nnoremap <C-w><C-l> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
xnoremap <C-w><C-l> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>

nnoremap <C-w><C-Down> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
xnoremap <C-w><C-Down> <Cmd>call VSCodeNotify('workbench.action.moveEditorToBelowGroup')<CR>
nnoremap <C-w><C-Up> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
xnoremap <C-w><C-Up> <Cmd>call VSCodeNotify('workbench.action.moveEditorToAboveGroup')<CR>
nnoremap <C-w><C-Left> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
xnoremap <C-w><C-Left> <Cmd>call VSCodeNotify('workbench.action.moveEditorToLeftGroup')<CR>
nnoremap <C-w><C-Right> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>
xnoremap <C-w><C-Right> <Cmd>call VSCodeNotify('workbench.action.moveEditorToRightGroup')<CR>

nnoremap <C-w><S-j> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
xnoremap <C-w><S-j> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
nnoremap <C-w><S-k> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
xnoremap <C-w><S-k> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
nnoremap <C-w><S-h> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
xnoremap <C-w><S-h> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
nnoremap <C-w><S-l> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>
xnoremap <C-w><S-l> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>

nnoremap <C-w><S-Down> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
xnoremap <C-w><S-Down> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupDown')<CR>
nnoremap <C-w><S-Up> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
xnoremap <C-w><S-Up> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupUp')<CR>
nnoremap <C-w><S-Left> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
xnoremap <C-w><S-Left> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupLeft')<CR>
nnoremap <C-w><S-Right> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>
xnoremap <C-w><S-Right> <Cmd>call VSCodeNotify('workbench.action.moveActiveEditorGroupRight')<CR>

nnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
xnoremap <C-w>w <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
nnoremap <C-w><C-w> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
xnoremap <C-w><C-w> <Cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>
nnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
xnoremap <C-w>W <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
nnoremap <C-w>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>
xnoremap <C-w>p <Cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>

nnoremap <C-w>t <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>
xnoremap <C-w>t <Cmd>call VSCodeNotify('workbench.action.focusFirstEditorGroup')<CR>
nnoremap <C-w>b <Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>
xnoremap <C-w>b <Cmd>call VSCodeNotify('workbench.action.focusLastEditorGroup')<CR>

" 文件命令
function! s:editOrNew(...)
    let file = a:1
    let bang = a:2

    if empty(file)
        if bang ==# '!'
            call VSCodeNotify('workbench.action.files.revert')
        else
            call VSCodeNotify('workbench.action.quickOpen')
        endif
    else
        " Last arg is to close previous file, e.g. e! ~/blah.txt will open blah.txt instead the current file
        call VSCodeExtensionNotify('open-file', expand(file), bang ==# '!' ? 1 : 0)
    endif
endfunction

function! s:saveAndClose() abort
    call VSCodeCall('workbench.action.files.save')
    call VSCodeNotify('workbench.action.closeActiveEditor')
endfunction

function! s:saveAllAndClose() abort
    call VSCodeCall('workbench.action.files.saveAll')
    call VSCodeNotify('workbench.action.closeAllEditors')
endfunction

" command! -bang -nargs=? Edit call VSCodeCall('workbench.action.quickOpen')
command! -complete=file -bang -nargs=? Edit call <SID>editOrNew(<q-args>, <q-bang>)
command! -bang -nargs=? Ex call <SID>editOrNew(<q-args>, <q-bang>)
command! -bang Enew call <SID>editOrNew('__vscode_new__', <q-bang>)
command! -bang Find call VSCodeNotify('workbench.action.quickOpen')

command! -complete=file -bang -nargs=? Write if <q-bang> ==# '!' | call VSCodeNotify('workbench.action.files.saveAs') | else | call VSCodeNotify('workbench.action.files.save') | endif
command! -bang Saveas call VSCodeNotify('workbench.action.files.saveAs')

command! -bang Wall call VSCodeNotify('workbench.action.files.saveAll')
command! -bang Quit if <q-bang> ==# '!' | call VSCodeNotify('workbench.action.revertAndCloseActiveEditor') | else | call VSCodeNotify('workbench.action.closeActiveEditor') | endif

command! -bang Wq call <SID>saveAndClose()
command! -bang Xit call <SID>saveAndClose()

command! -bang Qall call VSCodeNotify('workbench.action.closeAllEditors')

command! -bang Wqall call <SID>saveAllAndClose()
command! -bang Xall call <SID>saveAllAndClose()

AlterCommand e[dit] Edit
AlterCommand ex Ex
AlterCommand ene[w] Enew
AlterCommand fin[d] Find
AlterCommand w[rite] Write
AlterCommand sav[eas] Saveas
AlterCommand wa[ll] Wall
AlterCommand q[uit] Quit
AlterCommand wq Wq
AlterCommand x[it] Xit
AlterCommand qa[ll] Qall
AlterCommand wqa[ll] Wqall
AlterCommand xa[ll] Xall

nnoremap ZZ <Cmd>Wq<CR>
nnoremap ZQ <Cmd>Quit!<CR>