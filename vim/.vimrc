" ==========================================
" 1. AUTO-BOOTSTRAP VIM-PLUG
" ==========================================
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ==========================================
" 2. PLUGINS
" ==========================================
call plug#begin('~/.vim/plugged')
Plug 'ghifarit53/tokyonight-vim'
Plug 'itchyny/lightline.vim'
" OSC52 Support for Remote SSH
Plug 'ojroques/vim-oscyank' 
call plug#end()

" ==========================================
" 3. APPEARANCE & THEME
" ==========================================
set nocompatible
syntax on
filetype plugin indent on

" Theme
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1
colorscheme tokyonight

" Lightline
let g:lightline = { 'colorscheme': 'tokyonight' }
set laststatus=2

" UI Settings
set number
set cursorline
set ruler
set scrolloff=10
set noerrorbells
set visualbell
set mouse=a

" ==========================================
" 4. INDENTATION & BEHAVIOR
" ==========================================
set shiftwidth=2
set tabstop=2
set expandtab
set autoindent
set backspace=indent,eol,start

set history=1000
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" ==========================================
" 5. CROSS-PLATFORM CLIPBOARD
" ==========================================
" Set Clipboard to System Default
set clipboard^=unnamedplus

if has("macunix")
  " MacOS
  let g:clipboard = {
        \   'name': 'macOS-clipboard',
        \   'copy': {
        \      '+': 'pbcopy',
        \      '*': 'pbcopy',
        \    },
        \   'paste': {
        \      '+': 'pbpaste',
        \      '*': 'pbpaste',
        \   },
        \ }
elseif has("unix")
  " Linux
  if !empty($WAYLAND_DISPLAY)
    " Arch Linux (Caelestia/Wayland)
    let g:clipboard = {
          \   'name': 'wl-clipboard',
          \   'copy': {
          \      '+': 'wl-copy',
          \      '*': 'wl-copy',
          \    },
          \   'paste': {
          \      '+': 'wl-paste',
          \      '*': 'wl-paste',
          \   },
          \ }
  elseif !empty($SSH_TTY)
    " Remote Server (SSH) -> Use OSC52 Plugin
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.reg is '+' | call OSCYank(v:event.reg) | endif
    let g:oscyank_term = 'default' 
  endif
endif

" ==========================================
" 6. MAPPINGS
" ==========================================

" Clipboard Mappings
vnoremap <C-c> "+y
nnoremap <C-v> "+p
inoremap <C-v> <C-r><C-o>+ 

