set encoding=utf-8
set nocp
filetype plugin on

" Improve performance
"let g:loaded_matchparen=1
"set nolist
"set nonumber
"set ttyfast
set lazyredraw

syntax enable

" Custom C++ indentation
"set cino=g0,N-s,i4
"autocmd BufEnter *.h :setlocal cindent cino=j1,(0,ws,Ws
"autocmd BufEnter *.cpp :setlocal cindent cino=j1,(0,ws,Ws
set cino=j1,(0,ws,W8,N-s,g-0
autocmd BufEnter *.h :setlocal cindent cino=j1,(0,ws,W8,N-s,g-0
autocmd BufEnter *.cpp :setlocal cindent cino=j1,(0,ws,W8,N-s,g-0

set ts=4
set sw=4
set et
set background=dark
set number
map <F2> i <%   %><LEFT><LEFT><LEFT><LEFT>
map <F3> i <%=   %><LEFT><LEFT><LEFT><LEFT>
set wildmode=longest:full
set wildmenu
set textwidth=0
set wrapmargin=1
set hlsearch
"set tw=120
set wrap
set cin
"set spell

" fix copy-paste
set t_BE=

" disable preview window on autocomplete
set completeopt-=preview

"map <C-LEFT> :tabp<CR>
"map <C-RIGHT> :tabn<CR>
map <C-PageUp> :tabp<CR>
map <C-PageDown> :tabn<CR>
map <C-LEFT> <c-w><
map <C-RIGHT> <c-w>>
map <C-UP> <c-w>-
map <C-DOWN> <c-w>+
map <A-LEFT> <c-w><left>
map <A-RIGHT> <c-w><right>
map <A-UP> <c-w><up>
map <A-DOWN> <c-w><down>

" Tab navigation like Firefox.
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabprev<CR>
nnoremap tk  :tabnext<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tm  :tabm<Space>
nnoremap tn  :tabnew<CR>
nnoremap td  :tabclose<CR>
nnoremap tc  :tab split<CR>
nnoremap t1  :tabnext 1<CR>
nnoremap t2  :tabnext 2<CR>
nnoremap t3  :tabnext 3<CR>
nnoremap t4  :tabnext 4<CR>
nnoremap t5  :tabnext 5<CR>
nnoremap t6  :tabnext 6<CR>
nnoremap t7  :tabnext 7<CR>
nnoremap t8  :tabnext 8<CR>
nnoremap t9  :tabnext 9<CR>

" fold options
set foldmethod=syntax
set foldnestmax=10
set nofoldenable
set foldlevel=20

" OpenCL like C
au BufRead,BufNewFile *.cl set filetype=c

" Vundle plugin manager
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
" " let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
Plugin 'Yggdroot/indentLine'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'rdnetto/YCM-Generator'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'petRUShka/vim-opencl'
Plugin 'majutsushi/tagbar'
Plugin 'airblade/vim-gitgutter'
Plugin 'pangloss/vim-javascript'
Plugin 'leafgarland/typescript-vim'
Plugin 'tpope/vim-fugitive'
Plugin 'ericcurtin/CurtineIncSw.vim'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'Shougo/echodoc.vim'
Plugin 'dracula/vim', { 'name': 'dracula' }

if has('nvim')
  Plugin 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plugin 'Shougo/deoplete.nvim'
  Plugin 'roxma/nvim-yarp'
  Plugin 'roxma/vim-hug-neovim-rpc'
endif

" LSP for neovim
Plugin 'autozimu/LanguageClient-neovim', {
\ 'branch': 'next',
\ 'do': 'bash install.sh',
\ }

" fzf
set rtp+=~/.fzf
Plugin 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plugin 'junegunn/fzf.vim'

" " All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Configure LSP plugin
let g:LanguageClient_autoStart = 1
let g:LanguageClient_loadSettings = 1
"let g:LanguageClient_settingsPath = '/home/user/.vim/settings.json'
set completefunc=LanguageClient#complete
set formatexpr=LanguageClient_textDocument_rangeFormatting()
let g:LanguageClient_serverStderr = '/tmp/clangd.stderr'
let g:LanguageClient_rootMarkers = {
\ 'cpp': ['compile_commands.json', 'build'],
\ }

" Support for more languages may be added here.
"\ 'cpp': ['cquery', '--language-server', '--log-file=/tmp/cq.log'],
"\ 'c': ['cquery', '--language-server', '--log-file=/tmp/cq.log'],
let g:LanguageClient_serverCommands = {
\ 'cpp': ['clangd', '-background-index',],
\ 'c': ['clangd'],
\ }
"let g:LanguageClient_trace = 'verbose'
"let g:LanguageClient_setLoggingLevel = 'DEBUG'

" Rainbow parentheses plugin
let g:rbpt_colorpairs = [
 \ ['brown',        'RoyalBlue3'],
 \ ['Lightblue',    'SeaGreen3'],
 \ ['lightgray',    'DarkOrchid3'],
 \ ['lightgreen',   'firebrick3'],
 \ ['lightcyan',    'RoyalBlue3'],
 \ ['lightred',     'SeaGreen3'],
 \ ['lightmagenta', 'DarkOrchid3'],
 \ ['lightgreen',   'firebrick3'],
 \ ['lightcyan',    'RoyalBlue3'],
 \ ['lightred',     'SeaGreen3'],
 \ ['lightmagenta', 'DarkOrchid3'],
 \ ['Lightblue',    'firebrick3'],
 \ ['lightgreen',   'RoyalBlue3'],
 \ ['lightcyan',    'SeaGreen3'],
 \ ['lightred',     'DarkOrchid3'],
 \ ['red',          'firebrick3'],
 \ ]

let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
" This breaks folding
"au Syntax * RainbowParenthesesLoadBraces

" Open NERD Tree with Ctrl-n
map <C-n> :NERDTreeToggle<CR>
map <C-l> :NERDTreeFind<CR>
let g:NERDTreeDirArrows=0

set backspace=2

" YCM plugin options
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"let g:loaded_youcompleteme = 1
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_max_diagnostics_to_display = 200
let g:ycm_clangd_uses_ycmd_caching = 0
let g:ycm_clangd_binary_path = exepath("clangd")
let g:ycm_clangd_args=['--header-insertion=never']

nnoremap <F5>           :YcmForceCompileAndDiagnostics<CR>
nnoremap <leader>gic    :vsplit<CR><c-w><right>:YcmCompleter GoToInclude<CR>
nnoremap <leader>gdc    :vsplit<CR><c-w><right>:YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gdf    :vsplit<CR><c-w><right>:YcmCompleter GoToDefinition<CR>
nnoremap <leader>gip    :vsplit<CR><c-w><right>:YcmCompleter GoToImprecise<CR>
nnoremap <leader>f      :YcmCompleter FixIt<CR>
nnoremap <F9>           :YcmCompleter FixIt<CR>

" FzF
nnoremap <C-f> :Files<Cr>
nnoremap <C-p> :Ag<Cr>

nnoremap <silent> K :call SearchWordWithAg()<CR>
vnoremap <silent> K :call SearchVisualSelectionWithAg()<CR>
nnoremap <silent> <leader>gl :Commits<CR>
nnoremap <silent> <leader>ga :BCommits<CR>
nnoremap <silent> <leader>ft :Filetypes<CR>

function! SearchWordWithAg()
    execute 'Ag' expand('<cword>')
endfunction

function! SearchVisualSelectionWithAg() range
    let old_reg = getreg('"')
    let old_regtype = getregtype('"')
    let old_clipboard = &clipboard
    set clipboard&
    normal! ""gvy
    let selection = getreg('"')
    call setreg('"', old_reg, old_regtype)
    let &clipboard = old_clipboard
    execute 'Ag' selection
endfunction

command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Fugitive
" Fix broken syntax highlight in gitcommit files
" (https://github.com/tpope/vim-git/issues/12)
let g:fugitive_git_executable = 'LANG=en_US.UTF-8 git'

nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>ge :Gedit<CR>
nnoremap <silent> <leader>gE :Gedit<space>
nnoremap <silent> <leader>gr :Gread<CR>
nnoremap <silent> <leader>gR :Gread<space>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gW :Gwrite!<CR>
nnoremap <silent> <leader>gq :Gwq<CR>
nnoremap <silent> <leader>gQ :Gwq!<CR>
nnoremap <silent> <leader>gL :Glog<CR>

function! ReviewLastCommit()
    if exists('b:git_dir')
        Gtabedit HEAD^{}
        nnoremap <buffer> <silent> q :<C-U>bdelete<CR>
    else
        echo 'No git a git repository:' expand('%:p')
    endif
endfunction
nnoremap <silent> <leader>g` :call ReviewLastCommit()<CR>

augroup fugitiveSettings
    autocmd!
    autocmd FileType gitcommit setlocal nolist
    autocmd BufReadPost fugitive://* setlocal bufhidden=delete
augroup END

" StatusLine
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
set laststatus=2

"highlight link sensibleWhitespaceError Error
"autocmd Syntax * syntax match sensibleWhitespaceError excludenl /\s\+\%#\@<!$\| \+\ze\t/ display containedin=ALL

" Shortcuts for LSP
nnoremap <silent> ;h :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> ;d :vsplit<CR><c-w><right>:call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> ;r :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> ;s :call LanguageClient_textDocument_documentSymbol()<CR>
nnoremap <silent> ;R :call LanguageClient#textDocument_rename()<CR>

"nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
"nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
"nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
"nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
"nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
"nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
"nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
"nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
"nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
"nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>

" Tagbar
nmap <F8> :TagbarToggle<CR>

set relativenumber
set guicursor=

autocmd VimEnter * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd WinEnter * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufRead * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax * syntax match ExtraWhitespace excludenl /\s\+$/ display containedin=ALL

highlight YcmErrorSection ctermfg=15 ctermbg=1

set undofile
set undodir=~/.vim/undodir

"let g:python_host_prog = '/usr/bin/python'
"let g:python3_host_prog = '/usr/bin/python3'

" Reload changed files
set autoread
au CursorHold,CursorHoldI * checktime

" Switch between .h* and .c* files
map <C-o> :call CurtineIncSw()<CR>

" toggle quick fix window with compile errors \`
function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

nmap <silent> <leader>l :call ToggleList("Location List", 'l')<CR>
nmap <silent> <leader>e :call ToggleList("Quickfix List", 'c')<CR>

command -bang -nargs=? QFix call QFixToggle(<bang>0)
function! QFixToggle(forced)
  if exists("g:qfix_win") && a:forced == 0
    cclose
    unlet g:qfix_win
  else
    copen 10
    let g:qfix_win = bufnr("$")
  endif
endfunction

nmap <silent> <F7> :QFix<CR>
autocmd FileType qf nnoremap <buffer> <Enter> <C-W><Enter><C-W>T

" colorscheme
try
    colorscheme dracula
    hi Comment cterm=bold
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
endtry
set background=dark
set termguicolors
set colorcolumn=160

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" echodoc
set cmdheight=2
"set noshowmode
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'

" deoplete
let g:deoplete#enable_at_startup = 1

" toggle transparent background
let t:is_transparent = 0
function! Toggle_transparent_background()
    if t:is_transparent == 1
        hi Normal guibg=#282A36 ctermbg=236
        let t:is_transparent = 0
    else
        hi Normal guibg=NONE ctermbg=NONE
        let t:is_transparent = 1
    endif
endfunction
nnoremap <C-x><C-t> :call Toggle_transparent_background()<CR>
