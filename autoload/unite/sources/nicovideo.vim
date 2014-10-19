" ============================================================================
" FILE: nicovideo.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Unite source of nicovideo.vim
" unite.vim: https://github.com/Shougo/unite.vim
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let s:source = {
      \ 'name': 'nicovideo',
      \ 'description': 'candidates from nicovideo ranking',
      \ 'hooks': {},
      \ 'action_table': {
      \   'play': {
      \     'description': 'Play this nicovideo',
      \   }
      \ },
      \ 'default_action': 'play',
      \}

function! unite#sources#nicovideo#define()
  return s:source
endfunction


function! s:source.action_table.play.func(candidate)
  call nicovideo#watch(a:candidate.action__link)
endfunction

function! s:source.gather_candidates(args, context)
  if len(a:args) == 0
    let l:channels = nicovideo#get_channel_list()
  else
    let l:channels = []
    for l:arg in a:args
      call extend(l:channels, nicovideo#get_channel_list(l:arg))
    endfor
  endif
  let a:context.source.unite__cached_candidates = []
  if empty(l:channels)
    return []
  else
    return map(l:channels, '{"word": v:val.title, "action__link": v:val.link}')
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
