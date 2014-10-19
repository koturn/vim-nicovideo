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

let s:nicovideo_var = {
      \ 'init':   'ctrlp#nicovideo#init()',
      \ 'accept': 'ctrlp#nicovideo#accept',
      \ 'lname':  'nicovideo',
      \ 'sname':  'nicovideo',
      \ 'type':   'line',
      \ 'sort':   0
      \}
if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:nicovideo_var)
else
  let g:ctrlp_ext_vars = [s:nicovideo_var]
endif


function! ctrlp#nicovideo#init()
  let s:channel_list = nicovideo#get_channel_list()
  return map(copy(s:channel_list), 'v:val.title')
endfunction

function! ctrlp#nicovideo#accept(mode, str)
  call ctrlp#exit()
  for l:channel in s:channel_list
    if l:channel.title ==# a:str
      call nicovideo#watch(l:channel.link)
      return
    endif
  endfor
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#nicovideo#id()
  return s:id
endfunction
