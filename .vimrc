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
autocmd BufEnter *.h   :setlocal cindent cino=j1,(0,ws,W8,N-s,g-0
autocmd BufEnter *.cpp :setlocal cindent cino=j1,(0,ws,W8,N-s,g-0

set ts=4
set sw=4
set et
set background=dark
set number
set wildmode=longest:full
set wildmenu
set textwidth=0
set wrapmargin=1
set hlsearch
"set tw=120
set wrap
set cin
"set spell
set guicursor=
set backspace=2

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

" fold options (makes vim very slow!)
"set foldmethod=syntax
"set foldnestmax=10
"set nofoldenable
"set foldlevel=20

" make vim very slow!
"set relativenumber

" OpenCL like C
au BufRead,BufNewFile *.cl set filetype=c

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    "autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}
Plug 'scrooloose/nerdtree'
Plug 'Yggdroot/indentLine'
Plug 'kien/rainbow_parentheses.vim'
Plug 'Valloric/YouCompleteMe', { 'do': 'python3 install.py --clangd-completer' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'tpope/vim-fugitive'
Plug 'derekwyatt/vim-fswitch'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'ruanyl/vim-gh-line'
Plug 'dracula/vim', { 'name': 'dracula' }
Plug 'justinmk/vim-sneak'
Plug 'RRethy/vim-illuminate'
Plug 'gauteh/vim-cppman'
Plug 'Shougo/echodoc.vim'
Plug 'puremourning/vimspector'
Plug 'rhysd/clever-f.vim'
Plug 'othree/html5.vim'

" fzf - has to be before plug#end() ?
set rtp+=~/.fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

call plug#end()

" echodoc
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'popup'

" gitgutter
let g:gitgutter_sign_allow_clobber = 1
let g:gitgutter_sign_priority = 5

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
au Syntax * RainbowParenthesesLoadBraces

" Open NERD Tree with Ctrl-n
map <C-n> :NERDTreeToggle<CR>
map <C-l> :NERDTreeFind<CR>
let g:NERDTreeDirArrows=0

" YCM plugin options
"let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
"let g:loaded_youcompleteme = 1
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list = 0
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

nnoremap <F5>           :YcmForceCompileAndDiagnostics<CR>
nnoremap <leader>gic    :rightbelow vertical YcmCompleter GoToInclude<CR>
nnoremap <leader>gdc    :rightbelow vertical YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gdf    :rightbelow vertical YcmCompleter GoToDefinition<CR>
nnoremap <leader>gip    :rightbelow vertical YcmCompleter GoToImprecise<CR>
nnoremap <leader>grf    :YcmCompleter GoToReferences<CR>
nnoremap ;d             :rightbelow vertical YcmCompleter GoToDefinition<CR>
nnoremap ;r             :YcmCompleter GoToReferences<CR>
nnoremap <leader>f      :YcmCompleter FixIt<CR>

" FzF
nnoremap <C-f> :GFiles<Cr>
nnoremap <C-p> :Ag<Cr>

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

" Tagbar
nmap <C-F8> :TagbarToggle<CR>

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
hi Normal guibg=NONE ctermbg=NONE
hi Pmenu guibg=#128060

" ycm errors highlight
"hi YcmErrorLine guibg=#3f0000

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" toggle transparent background
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

" gdb
":packadd termdebug
"
"let g:termdebug_popup = 0
"let g:termdebug_wide = 160
"let g:termdebug_useFloatingHover = 0
"
"nnoremap <F3> :Run<CR>
"nnoremap <F4> :Continue<CR>
"nnoremap <F5> :Step<CR>
"nnoremap <F6> :Over<CR>
"nnoremap <F7> :Finish<CR>
"nnoremap <F8> :Break<CR>
"nnoremap <F9> :Clear<CR>
"nnoremap <F10> :Stop<CR>

"vnoremap <K> :Evaluate<CR>

" gh-line
let g:gh_line_map = '<leader>gH'
let g:gh_line_blame_map = '<leader>gB'

" remove all trailing whitespaces
nnoremap <silent> <leader>rs :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

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

" clang-format
function! s:JbzClangFormat(first, last)
  let l:winview = winsaveview()
  execute a:first . "," . a:last . "!clang-format"
  call winrestview(l:winview)
endfunction
command! -range=% JbzClangFormat call <sid>JbzClangFormat (<line1>, <line2>)

" add watch statement from visual selection
:vnoremap <F7> y:VimspectorWatch <C-r><C-r>"

" Autoformatting with clang-format
au FileType c,cpp nnoremap <buffer><leader>lf :<C-u>JbzClangFormat<CR>
au FileType c,cpp vnoremap <buffer><leader>lf :JbzClangFormat<CR>

set encoding=utf-8
set fileencodings=utf-8
scriptencoding utf-8
set encoding=utf-8

" look for local .vimrc
set exrc
set secure

" vim-sneak
let g:sneak#s_next = 1

" cursor hover time
set updatetime=1000
map <leader>d <plug>(YCMHover)

" conflicts with the vim-illuminate plugin
autocmd FileType cpp :setlocal iskeyword-=:
autocmd FileType cpp :setlocal iskeyword-=>
autocmd FileType cpp :setlocal iskeyword-=<
autocmd FileType cpp :setlocal iskeyword-=!
autocmd FileType cpp :setlocal iskeyword-=[
autocmd FileType cpp :setlocal iskeyword-=]
autocmd FileType cpp :setlocal iskeyword-=*

" share system clipboard
autocmd VimLeave * call system("xsel -ib", getreg("+"))
vnoremap Y "+y

" store swap files
set directory=~/.vim/swapfiles//

" edit json
let g:vim_json_conceal=0
