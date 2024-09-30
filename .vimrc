"==============================
" General
"==============================

" should be at the start of .vimrc
set nocompatible

set encoding=utf-8
set fileencodings=utf-8
scriptencoding utf-8

filetype plugin on
filetype indent on

set ts=4
set sw=4
set expandtab
set background=dark
set wildmode=longest:full
set wildmenu
set textwidth=0
set wrapmargin=1
set hlsearch
set tw=800
set wrap
set cin
set guicursor=
set backspace=2
set mouse=i
set undofile
set undodir=~/.vim/undodir
set background=dark
set termguicolors
set colorcolumn=120

" cursor (these make rendering slow)
set cursorline
"set cursorcolumn

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
else
    set signcolumn=yes
endif

" reload changed files
set autoread
au CursorHold,CursorHoldI * checktime

" enable relative line numbers
set number relativenumber

" switch to absolute line numbers when tab is not on focus
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" fix copy-paste
set t_BE=

" improve performance
set ttyfast " ??
set lazyredraw

syntax enable

" disable preview window on autocomplete
set completeopt-=preview

" show trailing spaces in red
autocmd VimEnter * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd WinEnter * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd BufRead  * highlight ExtraWhitespace ctermbg=red guibg=red
autocmd Syntax   * syntax match ExtraWhitespace excludenl /\s\+$/ display containedin=ALL

" look for local .vimrc
set exrc
set secure

" share system clipboard
autocmd VimLeave * call system("xsel -ib", getreg("+"))
vnoremap Y "+y

" store swap files
set directory=~/.vim/swapfiles/

" edit json
let g:vim_json_conceal=0

" center searches
nmap gg ggzz
nmap  n nzz
nmap  N Nzz
set scrolloff=4

"==============================
" Navigation
"==============================

" window navigation
map <C-LEFT> <c-w><
map <C-RIGHT> <c-w>>
map <C-UP> <c-w>-
map <C-DOWN> <c-w>+
map <S-A-LEFT> <c-w><left>
map <S-A-RIGHT> <c-w><right>
map <S-A-UP> <c-w><up>
map <S-A-DOWN> <c-w><down>

" tab navigation like Firefox.
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabprev<CR>
nnoremap tk  :tabnext<CR>
"nnoremap tl  :tablast<CR>
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

" go to last active tab
if !exists('g:lasttab')
    let g:lasttab = 1
endif
nmap tl :exe "tabn ".g:lasttab<CR>
nmap t<Tab> :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

"==============================
" Language specific
"==============================

" custom C++ indentation
"set cino=j1,(0,ws,W8,N-s,g-0
autocmd BufEnter *.h   :setlocal cindent cino=j1,ws,W8,N-s,g-0
autocmd BufEnter *.cpp :setlocal cindent cino=j1,ws,W8,N-s,g-0

" YAML (not perfect)
autocmd FileType yml,yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=<:>

" OpenCL like C
au BufRead,BufNewFile *.cl set filetype=c

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    "autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"au Syntax cpp setlocal foldmethod=indent
"au Syntax cpp setlocal nofoldenable
"au Syntax cpp setlocal foldnestmax=20
"au Syntax cpp setlocal foldlevel=20

" syntax folding (NOTE: makes C++ autocompletion super slow!)
au Syntax typescript,typescriptreact setlocal foldmethod=syntax
au Syntax typescript,typescriptreact setlocal foldnestmax=2
au Syntax typescript,typescriptreact setlocal nofoldenable
au Syntax typescript,typescriptreact setlocal foldlevel=4

" remember folding for a file
augroup remember_folds
    autocmd!
    autocmd BufWinLeave .vimrc,*.h,*.cpp mkview
    autocmd BufWinEnter .vimrc,*.h,*.cpp silent! loadview
augroup END

au BufRead,BufNewFile *.log set syntax=messages
au BufRead,BufNewFile *.dump set syntax=python

au BufRead,BufNewFile *.metal set syntax=c

"==============================
" Plugins
"==============================

call plug#begin('~/.vim/plugged')

Plug 'RRethy/vim-illuminate'
Plug 'Shougo/echodoc.vim'
Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clangd-completer --ts-completer' }
Plug 'airblade/vim-gitgutter'
Plug 'derekwyatt/vim-fswitch'
Plug 'fladson/vim-kitty'
Plug 'gauteh/vim-cppman'
"Plug 'ilyachur/cmake4vim'
Plug 'ggerganov/cmake4vim'
Plug 'junegunn/vim-easy-align'
Plug 'luochen1990/rainbow'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'preservim/nerdcommenter'
Plug 'puremourning/vimspector'
Plug 'rhysd/clever-f.vim'
Plug 'ruanyl/vim-gh-line'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'elzr/vim-json'
"Plug 'Konfekt/FastFold'
"Plug 'mg979/vim-visual-multi'
Plug 'TabbyML/vim-tabby'

" colorthemes
Plug 'dracula/vim', { 'name': 'dracula' }
Plug 'morhetz/gruvbox'
Plug 'NLKNguyen/papercolor-theme'

" zig
Plug 'ziglang/zig.vim'

" html/javascript/typescript/react
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'

if has('nvim')
    Plug 'github/copilot.vim'
    "Plug 'ggandor/leap.nvim'
    Plug 'ggandor/lightspeed.nvim'
else
    Plug 'justinmk/vim-sneak'
endif

" fzf - has to be before plug#end() ?
set rtp+=~/.fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

call plug#end()

" echodoc (neovim not supported)
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'popup'

" gitgutter
if !has('nvim')
let g:gitgutter_enabled = 0
endif
let g:gitgutter_sign_allow_clobber = 1
let g:gitgutter_sign_priority = 5

" rainbow
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

" Open NERD Tree with Ctrl-n
map <C-n> :NERDTreeToggle<CR>
map <C-l> :NERDTreeFind<CR>
let g:NERDTreeDirArrows=0

" YCM plugin options
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"let g:loaded_youcompleteme = 1
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list = 1
let g:ycm_max_diagnostics_to_display = 16
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_auto_trigger = 1
let g:ycm_auto_hover = ''
let g:ycm_goto_buffer_command = 'split-or-existing-window'
"let g:ycm_cache_omnifunc = 0
"let g:ycm_autoclose_preview_window_after_insert = 1
"let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_clangd_uses_ycmd_caching = 1
"let g:ycm_clangd_binary_path = exepath("clangd")
let g:ycm_clangd_args=['--header-insertion=never']

" Experimental
let g:ycm_enable_semantic_highlighting=1
let g:ycm_enable_inlay_hints=1

nnoremap <F5>        :YcmForceCompileAndDiagnostics<CR>
nnoremap <leader>gic :rightbelow vertical YcmCompleter GoToInclude<CR>
nnoremap <leader>gdc :rightbelow vertical YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gdf :rightbelow vertical YcmCompleter GoToDefinition<CR>
nnoremap <leader>gip :rightbelow vertical YcmCompleter GoToImprecise<CR>
nnoremap <leader>grr :rightbelow vertical YcmCompleter RefactorRename
nnoremap <leader>grf :YcmCompleter GoToReferences<CR>
nnoremap ;d          :rightbelow vertical YcmCompleter GoToDefinition<CR>
nnoremap ;r          :YcmCompleter GoToReferences<CR>
nnoremap <leader>f   :YcmCompleter FixIt<CR>

" cursor hover time
set updatetime=1000
if has('nvim')
    nnoremap <leader>d :YcmCompleter GetType<CR>
    nnoremap <leader>D :YcmCompleter GetDoc<CR>
else
    nmap <leader>d <plug>(YCMHover)
endif

" FzF - fuzzy searching
nnoremap <C-f> :GFiles<Cr>
nnoremap <C-i> :Ag<Cr>
nnoremap <C-p> :Ag2<Cr>

nnoremap <silent> <C-k> :call SearchWordWithAg()<CR>
vnoremap <silent> <C-k> :call SearchVisualSelectionWithAg()<CR>
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

command! -bang -nargs=* Ag2 call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" vim-fugitive
" Fix broken syntax highlight in gitcommit files
" (https://github.com/tpope/vim-git/issues/12)
let g:fugitive_git_executable = 'LANG=en_US.UTF-8 git'

nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Git blame<CR>
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
        echo 'Not a git repository:' expand('%:p')
    endif
endfunction
nnoremap <silent> <leader>g` :call ReviewLastCommit()<CR>

augroup fugitiveSettings
    autocmd!
    autocmd FileType gitcommit setlocal nolist
    autocmd BufReadPost fugitive://* setlocal bufhidden=delete
augroup END

nmap <silent> <leader>gg tt<CR>tm0<CR>:G<CR><C-w><DOWN>:q<CR>

" StatusLine
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
set laststatus=2

" gh-line
let g:gh_line_map = '<leader>gH'
let g:gh_line_blame_map = '<leader>gB'

" vim-fswitch
au BufEnter *.h  let b:fswitchdst = "c,cpp,cc,m"
au BufEnter *.cc let b:fswitchdst = "h,hpp"

nnoremap <silent> <C-o> :FSHere<cr>
nnoremap <silent> <localleader>oh :FSSplitLeft<cr>
nnoremap <silent> <localleader>oj :FSSplitBelow<cr>
nnoremap <silent> <localleader>ok :FSSplitAbove<cr>
nnoremap <silent> <localleader>ol :FSSplitRight<cr>

" vimspector
let g:vimspector_enable_mappings = 'HUMAN'
" add watch statement from visual selection
vnoremap <F7> y:VimspectorWatch <C-r><C-r>"
" for normal mode - the word under the cursor
nmap <F7> <Plug>VimspectorBalloonEval
" for visual mode, the visually selected text
xmap <F7> <Plug>VimspectorBalloonEval

" vim-sneak
let g:sneak#s_next = 1

" conflicts with the vim-illuminate plugin
autocmd FileType c,cpp :setlocal iskeyword-=:
autocmd FileType c,cpp :setlocal iskeyword-=>
autocmd FileType c,cpp :setlocal iskeyword-=<
autocmd FileType c,cpp :setlocal iskeyword-=!
autocmd FileType c,cpp :setlocal iskeyword-=[
autocmd FileType c,cpp :setlocal iskeyword-=]
autocmd FileType c,cpp :setlocal iskeyword-=*
autocmd FileType c,cpp :setlocal iskeyword-==

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

xmap ga=       mxgaip=`x
xmap ga(       mxgaip<Down><C-x>(<Enter>`x
xmap ga<Space> mxgaip<Space>`x
xmap gad       ga<Space>ga=

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

nmap ga=       mxgaip=`x
nmap ga(       mxgaip<Down><C-x>(<Enter>`x
nmap ga<Space> mxgaip<Space>`x
nmap gad       ga<Space>ga=

let g:easy_align_delimiters = {
\ 'd': {
\      'pattern': ' \ze\S\+\s*[;=]',
\      'left_margin': 0,
\      'right_margin': 0
\   }
\ }

" nerdcommenter
let g:NERDDefaultAlign = 'left'

" copilot
highlight CopilotSuggestion guifg=#00aaaa ctermfg=8

" cmake4vim
let g:make_arguments = '-j$(($(getconf _NPROCESSORS_ONLN) - 2))'
let g:cmake_build_dir = 'build-debug/'
let g:cmake_build_executor = 'dispatch'

nmap <silent> <leader>r :CMakeRunFromBuildDir <C-R>=g:cmake_run_last_args<CR><CR>
nmap          <leader>R :CMakeRunFromBuildDir <C-R>=g:cmake_run_last_args<CR><RIGHT>
nmap <silent> <leader>b :CMakeBuild<CR>
nmap <silent> <leader>B :FZFCMakeSelectTarget<CR>

" vim-disaptch
nmap <silent> <leader>k :AbortDispatch<CR><leader>e

" fastfold
"nmap zuz <Plug>(FastFoldUpdate)
"let g:fastfold_savehook = 1
"let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C']
"let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
"
"autocmd FileType c,cpp setlocal foldmethod=syntax
"autocmd FileType c,cpp setlocal nofoldenable
"autocmd FileType c,cpp setlocal foldnestmax=20
"autocmd FileType c,cpp setlocal foldlevel=20

"==============================
" Extra shortcuts
"==============================

"
" toggle quick fix window with compile errors
"
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

"
" toggle transparent background
"
let g:is_transparent = 1
function! Toggle_transparent_background()
    if g:is_transparent == 1
        hi Normal guibg=#282A36 ctermbg=236
        let g:is_transparent = 0
    else
        hi Normal guibg=NONE ctermbg=NONE
        let g:is_transparent = 1
    endif
endfunction
nnoremap <C-x><C-t> :call Toggle_transparent_background()<CR>

"
" remove all trailing whitespaces
"
nnoremap <silent> <leader>rs :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

"
" autoformatting with clang-format
"
function! s:JbzClangFormat(first, last)
  let l:winview = winsaveview()
  execute a:first . "," . a:last . "!clang-format"
  call winrestview(l:winview)
endfunction
command! -range=% JbzClangFormat call <sid>JbzClangFormat (<line1>, <line2>)

au FileType c,cpp nnoremap <buffer><leader>lf :<C-u>JbzClangFormat<CR>
au FileType c,cpp vnoremap <buffer><leader>lf :JbzClangFormat<CR>

" colortheme
try
    " dracula theme
    colorscheme dracula
    ""hi Pmenu guibg=#128060

    " gruvbox theme
    "let g:gruvbox_contrast_dark = 'hard'
    "colorscheme gruvbox

    " PaperColor
    "colorscheme PaperColor

    hi Comment cterm=bold
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
endtry

" background
"hi Normal guibg=#0F1114 ctermbg=NONE
"hi Normal guibg=#282A31 ctermbg=NONE
hi Normal guibg=#191A20 ctermbg=NONE

highlight YcmErrorSign    gui=bold cterm=bold ctermbg=lightred ctermfg=white guibg=#FF0000 guifg=#FFFFFF
"highlight YcmErrorLine                        ctermbg=lightred               guibg=#660000
"highlight YcmErrorSection                     ctermbg=lightred               guibg=#660000

highlight YcmWarningSign    gui=bold cterm=bold ctermbg=cyan ctermfg=black guibg=#00FFFF guifg=#000000
"highlight YcmWarningLine                        ctermbg=cyan               guibg=#006666
"highlight YcmWarningSection                     ctermbg=cyan               guibg=#006666

" YCM inlay hint gray
hi YCMInlayHint guifg=#888888 ctermfg=8

if &term =~ '256color'
    " Disable Background Color Erase (BCE) so that color schemes
    " work properly when Vim is used inside tmux and GNU screen.
    set t_ut=
endif

" vim illuminate (after colortheme)
let g:Illuminate_delay = 500
highlight IlluminatedWordText gui=bold,underline cterm=bold,underline guibg=#404030
highlight IlluminatedWord     gui=bold,underline cterm=bold,underline guibg=#404030
highlight CursorLine          guibg=#202020

" write file using Ctrl-S
nnoremap <C-s> :w<CR>

" whisper.nvim
" TODO: refactor this into a function
inoremap <C-G>  <C-O>:!whisper.nvim<CR><C-O>:let @a = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR><C-R>a
nnoremap <C-G>       :!whisper.nvim<CR>:let @a = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR>"ap
vnoremap <C-G> c<C-O>:!whisper.nvim<CR><C-O>:let @a = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR><C-R>a

vnoremap <C-T> <ESC>:!whisper.nvim<CR>:let @y = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR>:set formatoptions-=cro<CR>`<kmajmck:r ~/bin/ggprompt-begin.txt<CR>`>mdo<ESC>:.-1r ~/bin/ggprompt-end.txt<CR>jjA<ESC>"yp<CR>mb`ajV`ckzf`bo
nnoremap <C-Y> `ajV`djjjjd

if 1
    " Github copilot
    let g:copilot_enabled = v:true

    let g:tabby_keybinding_accept = '<C-Tab>'
    let g:tabby_keybinding_trigger_or_dismiss = '<C-\>'
else
    " local copilot
    let g:copilot_enabled = v:false
    let g:copilot_no_tab_map = v:true

    imap <silent><script><expr> <C-Tab> copilot#Accept("\<CR>")
endif

imap <D-]> <Plug>(copilot-accept-word)

" Tabby
let g:tabby_trigger_mode = 'manual'

" load Lua config
if has('nvim')
    if filereadable(expand('~/.config/nvim/lua/init.lua'))
        lua require('init')
    endif
endif
