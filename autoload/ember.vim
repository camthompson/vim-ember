if exists('g:autoloaded_ember') || &cp
  finish
endif
let g:autoloaded_ember = 1

function! ember#buffer_setup() abort
  if !exists('b:ember_root')
    return ''
  endif
  call s:BufScriptWrappers()
endfunction

let s:app_prototype = {}

if !exists('s:apps')
  let s:apps = {}
endif

function! s:add_methods(namespace, method_names)
  for name in a:method_names
    let s:{a:namespace}_prototype[name] = s:function('s:'.a:namespace.'_'.name)
  endfor
endfunction

function! s:function(name)
    return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

function! s:gsub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:rquote(str)
  if a:str =~ '^[A-Za-z0-9_/.:-]\+$'
    return a:str
  elseif &shell =~? 'cmd'
    return '"'.s:gsub(s:gsub(a:str, '"', '""'), '\%', '"%"').'"'
  else
    return shellescape(a:str)
  endif
endfunction

function! s:BufScriptWrappers()
  command! -buffer -bang -bar -nargs=* Egenerate :execute ember#app().generator_command(<bang>0,'generate',<f-args>)
endfunction

function! ember#app(...) abort
  let root = a:0 ? a:1 : get(b:, 'ember_root', '')
  if !empty(root)
    if !has_key(s:apps, root) && filereadable(root . '/.ember-cli')
      let s:apps[root] = deepcopy(s:app_prototype)
      let s:apps[root].root = root
      let s:apps[root]._root = root
    endif
    return get(s:apps, root, {})
  endif
  return {}
endfunction

function! s:app_generator_command(bang,...) dict
  let cmd = join(map(copy(a:000),'s:rquote(v:val)'),' ')
  let old_makeprg = &l:makeprg
  let old_errorformat = &l:errorformat
  try
    let &l:makeprg = 'ember '.l:cmd
    let &l:errorformat = s:efm_generate
    noautocmd make!
  finally
    let &l:errorformat = old_errorformat
    let &l:makeprg = old_makeprg
  endtry
  if a:bang || empty(getqflist())
    return ''
  else
    return 'cfirst'
  endif
endfunction

function! s:color_efm(pre, before, after)
   return a:pre . '%\S%\+  %#' . a:before . "\e[0m  %#" . a:after . ',' .
         \ a:pre . '%\s %#'.a:before.'  %#'.a:after . ','
endfunction

let s:efm_generate =
      \ s:color_efm('%-G', 'version', '') .
      \ s:color_efm('%-G', 'requires a blueprint', '') .
      \ s:color_efm('%-G', 'installing', '%f') .
      \ s:color_efm('%-G', 'create', ' ') .
      \ s:color_efm('%-G', 'identical', ' ') .
      \ s:color_efm('', '%m', ' %f') .
      \ s:color_efm('', '%m', '%f') .
      \ '%-G%.%#'

call s:add_methods('app', ['generator_command'])
