" ============================================================================
" FILE: nicovideo.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Watch niconico video with vim. This plugin is simple mplayer frontend of
" Vim.
" }}}
" ============================================================================
if exists('g:loaded_nicovideo')
  finish
endif
let g:loaded_nicovideo = 1
let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=1 NicoVideo call nicovideo#watch(<f-args>)
command! -bar -nargs=0 NicoVideoUpdateRanking call nicovideo#update_ranking(<f-args>)
command! -bar -nargs=* NicoVideoLogin call nicovideo#login(<f-args>)
command! -bar -nargs=0 NicoVideoLogout call nicovideo#logout()

command! CtrlPNicovideo call ctrlp#init(ctrlp#nicovideo#id())


let &cpo = s:save_cpo
unlet s:save_cpo
