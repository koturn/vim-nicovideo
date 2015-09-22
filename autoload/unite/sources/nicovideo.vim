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

function! unite#sources#nicovideo#define() abort
  return s:source
endfunction


function! s:source.action_table.play.func(candidate) abort
  call nicovideo#watch(a:candidate.action__link)
endfunction

function! s:source.gather_candidates(args, context) abort
  let a:context.source.unite__cached_candidates = []
  let l:channels = len(a:args) == 0 ?
        \ nicovideo#get_channel_list() : nicovideo#get_channel_list(a:args)
  return empty(l:channels) ?
        \ [] : map(l:channels, '{"word": v:val.title, "action__link": v:val.link}')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
