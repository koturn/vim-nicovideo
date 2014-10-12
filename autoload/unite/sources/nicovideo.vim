" ============================================================================
" FILE: nicovideo.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Unite source of nicovideo.vim
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

function! s:source.async_gather_candidates(args, context)
  let l:channels = nicovideo#get_channel_list()
  let a:context.source.unite__cached_candidates = []
  return map(l:channels, '{
        \ "word": v:val.title,
        \ "action__link": v:val.link,
        \}')
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
