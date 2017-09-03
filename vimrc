"set term=builtin_ansi
syntax on
set tabstop=4
"set softtabstop=4
"set shiftwidth=4
"set smarttab
"set expandtab
set ruler

" vundle config below
set nocompatible               " be iMproved
filetype off                   " required!

"set rtp+=~/.vim/bundle/Vundle.vim/
"call vundle#rc()

" let Vundle manage Vundle
" required! 
"Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
"Bundle 'tpope/vim-fugitive'
"Bundle 'Lokaltog/vim-easymotion'
"Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
"Bundle 'tpope/vim-rails.git'
" vim-scripts repos
"Bundle 'L9'
"Bundle 'FuzzyFinder'
" non github repos
"Bundle 'git://git.wincent.com/command-t.git'
"Bundle 'maksimr/vim-jsbeautify'
"Bundle 'einars/js-beautify'

" Dave's vim-go config from the tutorial
call plug#begin()
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
call plug#end()

set autowrite

" go to next/prev error with Ctrl-n/m
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
" close quickfix with ,a
nnoremap <leader>a :cclose<CR>

" run and test with ,r ,t
autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>t  <Plug>(go-test)

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" GoCoverageToggle with ,c
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)

let mapleader = ","

filetype plugin indent on     " required!
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..
au BufWritePost *.go !gofmt -w -s %
