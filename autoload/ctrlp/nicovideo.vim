" ============================================================================
" FILE: nicovideo.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" CtrlP extension of vim-nicovideo.
" CtrlP: https://github.com/ctrlpvim/ctrlp.vim
" }}}
" ============================================================================
if exists('g:loaded_ctrlp_nicovideo') && g:loaded_ctrlp_nicovideo
  finish
endif
let g:loaded_ctrlp_nicovideo = 1
let s:ctrlp_builtins = ctrlp#getvar('g:ctrlp_builtins')

let s:nicovideo_var = {
      \ 'init': 'ctrlp#nicovideo#init()',
      \ 'accept': 'ctrlp#nicovideo#accept',
      \ 'lname': 'nicovideo',
      \ 'sname': 'nicovideo',
      \ 'type': 'line',
      \ 'sort': 0,
      \ 'nolim': 1
      \}
if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  call add(g:ctrlp_ext_vars, s:nicovideo_var)
else
  let g:ctrlp_ext_vars = [s:nicovideo_var]
endif

let s:id = s:ctrlp_builtins + len(g:ctrlp_ext_vars)
unlet s:ctrlp_builtins
function! ctrlp#nicovideo#id() abort
  return s:id
endfunction

function! ctrlp#nicovideo#init() abort
  let s:channel_list = nicovideo#get_channel_list()
  return map(copy(s:channel_list), 'v:val.title')
endfunction

function! ctrlp#nicovideo#accept(mode, str) abort
  call ctrlp#exit()
  for channel in s:channel_list
    if channel.title ==# a:str
      call nicovideo#watch(channel.link)
      return
    endif
  endfor
endfunction
