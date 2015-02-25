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

function! s:sub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:startswith(string,prefix)
  return strpart(a:string, 0, strlen(a:prefix)) ==# a:prefix
endfunction

function! s:endswith(string,suffix)
  return strpart(a:string, len(a:string) - len(a:suffix), len(a:suffix)) ==# a:suffix
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
  command! -buffer -bang -bar -nargs=* -complete=customlist,s:Complete_generate Egenerate :execute ember#app().generator_command(<bang>0,'generate',<f-args>)
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

function! s:Complete_script(ArgLead,CmdLine,P)
  let cmd = s:sub(a:CmdLine,'^\u\w*\s+','')
  if cmd =~# '^\%(generate\|destroy\)\s\+'.a:ArgLead.'$'
    return s:completion_filter(ember#app().generators(),a:ArgLead)
  else
    return ''
  endif
endfunction

function! s:CustomComplete(A,L,P,cmd)
  let L = "Rscript ".a:cmd." ".s:sub(a:L,'^\h\w*\s+','')
  let P = a:P - strlen(a:L) + strlen(L)
  return s:Complete_script(a:A,L,P)
endfunction

function! s:Complete_generate(A,L,P)
  return s:CustomComplete(a:A,a:L,a:P,"generate")
endfunction

function! s:app_generators() dict abort
  return ['acceptance-test', 'adapter', 'adapter-test', 'addon', 'app', 'blueprint', 'component', 'component-test', 'controller', 'controller-test', 'helper', 'helper-test', 'http-mock', 'http-proxy', 'in-repo-addon', 'initializer', 'initializer-test', 'lib', 'mixin', 'mixin-test', 'model', 'resource', 'route', 'route-test', 'serializer', 'serializer-test', 'server', 'service', 'service-test', 'template', 'test-helper', 'transform', 'transform-test', 'util', 'util-test', 'view', 'view-test']
endfunction

function! s:completion_filter(results, A, ...) abort
  let results = sort(type(a:results) == type("") ? split(a:results,"\n") : copy(a:results))
  call filter(results,'v:val !~# "\\~$"')
  if a:A =~# '\*'
    let regex = s:gsub(a:A,'\*','.*')
    return filter(copy(results),'v:val =~# "^".regex')
  endif
  let filtered = filter(copy(results),'s:startswith(v:val,a:A)')
  if !empty(filtered) | return filtered | endif
  let prefix = s:sub(a:A,'(.*[/]|^)','&_')
  let filtered = filter(copy(results),"s:startswith(v:val,prefix)")
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'[^/]','[&].*')
  let filtered = filter(copy(results),'v:val =~# "^".regex')
  if !empty(filtered) | return filtered | endif
  let regex = s:gsub(a:A,'.','[&].*')
  let filtered = filter(copy(results),'v:val =~# regex')
  return filtered
endfunction

call s:add_methods('app', ['generators', 'generator_command'])
