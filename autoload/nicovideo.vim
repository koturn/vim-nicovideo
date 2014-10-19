" ============================================================================
" FILE: nicovideo.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Watch niconico video with vim. This plugin is simple mplayer frontend of
" Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim


let g:nicovideo#cache_dir = get(g:, 'nicovideo#cache_dir', expand('~/.cache/nicovideo'))
let g:nicovideo#cookie = get(g:, 'nicovideo#nicovideo', expand('~/.vim-nicovideo.cookie'))
let g:nicovideo#crt_file = get(g:, 'nicovideo#crt_file', '')
let g:nicovideo#curl = get(g:, 'nicovideo#curl', 'curl')
let g:nicovideo#mail_address = get(g:, 'nicovideo#mail_address', '')
let g:nicovideo#mplayer = get(g:, 'nicovideo#mplayer', 'mplayer')
let g:nicovideo#mplayer_option = get(g:, 'nicovideo#mplayer_option',
      \ has('win32') ? '-quiet -vo direct3d' : '-quiet')
let g:nicovideo#password = get(g:, 'nicovideo#password', '')
let g:nicovideo#verbose = get(g:, 'nicovideo#verbose', 0)

let s:V = vital#of('nicovideo')
let s:CACHE = s:V.import('System.Cache')
let s:JSON = s:V.import('Web.JSON')
let s:HTTP = s:V.import('Web.HTTP')
let s:XML = s:V.import('Web.XML')

let s:CACHE_FILENAME = 'cache' | lockvar s:CACHE_FILENAME
let s:LOGIN_URL = 'https://secure.nicovideo.jp/secure/login?site=niconico' | lockvar s:LOGIN_URL
let s:LOGOUT_URL = 'https://secure.nicovideo.jp/secure/logout' | lockvar s:LOGOUT_URL
let s:RSS_URL = 'http://www.nicovideo.jp/ranking/fav/daily/all?rss=2.0' | lockvar s:RSS_URL
let s:RSS_TAG_URL_FORMAT = 'http://www.nicovideo.jp/tag/%s?rss=2.0' | lockvar s:RSS_TAG_URL_FORMAT
let s:GETFLV_URL = 'http://flapi.nicovideo.jp/api/getflv/' | lockvar s:GETFLV_URL


function! nicovideo#watch(url)
  if !nicovideo#login(g:nicovideo#mail_address, g:nicovideo#password)
    return
  endif
  if a:url =~# '^http://www.nicovideo.jp/watch/'
    call s:play_video(a:url)
  else
    call s:play_video('http://www.nicovideo.jp/watch/' . a:url)
  endif
endfunction

function! nicovideo#login(mail_address, password)
  let g:nicovideo#mail_address = a:mail_address
  let g:nicovideo#password = a:password
  call vimproc#system(printf('%s -s -c %s -d "mail=%s" -d "password=%s" "%s" -3 -i %s',
        \ g:nicovideo#curl, g:nicovideo#cookie,
        \ a:mail_address, a:password, s:LOGIN_URL,
        \ g:nicovideo#crt_file ==# '' ? '' : '--cacert ' . g:nicovideo#crt_file))
  return 1
endfunction

function! nicovideo#logout()
  call vimproc#system(printf('%s -s -b %s "%s" -3 -i %s',
        \ g:nicovideo#curl, g:nicovideo#cookie, s:LOGOUT_URL,
        \ g:nicovideo#crt_file ==# '' ? '' : '--cacert ' . g:nicovideo#crt_file))
endfunction

function! nicovideo#update_ranking()
  let l:infos = s:parse_rss(s:RSS_URL)
  let l:write_list = [s:JSON.encode({'nicovideo': l:infos})]
  call s:CACHE.writefile(g:nicovideo#cache_dir, s:CACHE_FILENAME, l:write_list)
  return l:infos 
endfunction

function! nicovideo#get_channel_list(...)
  let l:tag = get(a:, 1, '')
  if l:tag !=# ''
    let l:tag = s:HTTP.encodeURI(iconv(l:tag, &encoding, 'utf-8'))
    return s:parse_rss(printf(s:RSS_TAG_URL_FORMAT, l:tag))
  elseif s:CACHE.filereadable(g:nicovideo#cache_dir, s:CACHE_FILENAME)
    return s:JSON.decode(s:CACHE.readfile(g:nicovideo#cache_dir, s:CACHE_FILENAME)[0]).nicovideo
  else
    return nicovideo#update_ranking()
  endif
endfunction


function! s:play_video(url)
  if !s:has_vimproc()
    echoerr 'Please install vimproc.vim'
    return
  endif
  call vimproc#system(printf('%s -s -b %s -c %s %s -i',
        \ g:nicovideo#curl, g:nicovideo#cookie, g:nicovideo#cookie, a:url))
  let l:file_url = s:get_file_url(a:url)
  if l:file_url == -1 | return | endif
  call vimproc#system_bg(printf('curl -b %s %s', g:nicovideo#cookie, l:file_url)
        \ . ' | ' . g:nicovideo#mplayer . ' ' .g:nicovideo#mplayer_option . ' -')
endfunction

function! s:get_file_url(url)
  let l:filename = split(a:url, '/')[-1]
  let l:suffix = l:filename[0 : 1] ==# 'nm' ? '?as3=1' : ''
  let l:res = vimproc#system(printf('%s -s -b %s "%s%s%s" %s',
        \ g:nicovideo#curl, g:nicovideo#cookie, s:GETFLV_URL, l:filename, l:suffix,
        \ g:nicovideo#crt_file ==# '' ? '' : '--cacert ' . g:nicovideo#crt_file))
  let l:url_list = filter(split(s:HTTP.decodeURI(l:res), '&'), 'v:val =~# "^url="')
  if empty(l:url_list)
    echoerr 'Failed to get file URL'
    echoerr '  (Check certificate file is valid)'
    return -1
  endif
  return substitute(l:url_list[0], '^url=', '', '')
endfunction

function! s:parse_rss(url)
  let l:start_time = reltime()
  let l:time = reltime()
  let l:response = s:HTTP.request({'url': a:url, 'client': ['curl']})
  if l:response.status != 200
    echoerr 'Connection error:' '[' . l:response.status . ']' l:response.statusText
    return
  endif
  if g:nicovideo#verbose
    echomsg '[HTTP request]:' reltimestr(reltime(l:time)) 's'
  endif

  let l:time = reltime()
  let l:dom = s:XML.parse(l:response.content)
  if g:nicovideo#verbose
    echomsg '[parse XML]:   ' reltimestr(reltime(l:time)) 's'
  endif

  let l:time = reltime()
  let l:infos = s:parse_dom(l:dom)
  if g:nicovideo#verbose
    echomsg '[parse DOM]:   ' reltimestr(reltime(l:time)) 's'
    echomsg '[total]:       ' reltimestr(reltime(l:start_time)) 's'
  endif
  return l:infos 
endfunction

function! s:parse_dom(dom)
  let l:infos = []
  let l:items = a:dom.childNode('channel').childNodes('item')
  for l:c1 in l:items
    let l:info = {}
    for l:c2 in l:c1.child
      if type(l:c2) == 4
        if l:c2.name ==# 'title'
          let l:info.title = l:c2.value()
        elseif l:c2.name ==# 'link'
          let l:info.link = l:c2.value()
        elseif l:c2.name ==# 'pubDate'
          let l:info.pubDate = l:c2.value()
        endif
      endif
      unlet l:c2
    endfor
    if len(l:info) == 3
      call add(l:infos, l:info)
    endif
  endfor
  return l:infos
endfunction

function! s:has_vimproc()
  if !exists('s:exists_vimproc')
    try
      call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
