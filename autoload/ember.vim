if exists('g:autoloaded_ember') || &cp
  finish
endif
let g:autoloaded_ember = 1

" Utility Functions {{{1

let s:app_prototype = {}
let s:file_prototype = {}
let s:buffer_prototype = {}
let s:readable_prototype = {}

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

function! s:app_path(...) dict
  return join([self.root]+a:000,'/')
endfunction

call s:add_methods('app',['path'])

function! s:buffer_getvar(varname) dict abort
  return getbufvar(self.number(),a:varname)
endfunction

function! s:buffer_setvar(varname, val) dict abort
  return setbufvar(self.number(),a:varname,a:val)
endfunction

call s:add_methods('buffer',['getvar','setvar'])
" }}}1
" Public Interface {{{1

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

function! ember#buffer(...)
  return extend(extend({'#': bufnr(a:0 ? a:1 : '%')},s:buffer_prototype,'keep'),s:readable_prototype,'keep')
endfunction

function! s:buffer_app() dict abort
  if self.getvar('ember_root') != ''
    return ember#app(self.getvar('ember_root'))
  else
    throw 'Not in an Ember app'
  endif
endfunction

function! s:file_path() dict abort
  return self.app().path(self._name)
endfunction

function! s:buffer_number() dict abort
  return self['#']
endfunction

function! s:buffer_path() dict abort
  return s:gsub(fnamemodify(bufname(self.number()),':p'),'\\ @!','/')
endfunction

call s:add_methods('file',['path'])
call s:add_methods('buffer',['app','number','path'])
" }}}1
" Commands {{{1
" }}}1
" Script Wrappers {{{1

function! s:BufScriptWrappers()
  command! -buffer -bang -bar -nargs=* -complete=customlist,s:Complete_generate  Egenerate     :execute ember#app().generator_command(<bang>0,'generate',<f-args>)
  command! -buffer -bar -nargs=*       -complete=customlist,s:Complete_generate  Edestroy      :execute ember#app().generator_command(1,'destroy',<f-args>)
endfunction

function! s:app_generators() dict abort
  return ['acceptance-test', 'adapter', 'adapter-test', 'addon', 'app', 'blueprint', 'component', 'component-test', 'controller', 'controller-test', 'helper', 'helper-test', 'http-mock', 'http-proxy', 'in-repo-addon', 'initializer', 'initializer-test', 'lib', 'mixin', 'mixin-test', 'model', 'resource', 'route', 'route-test', 'serializer', 'serializer-test', 'server', 'service', 'service-test', 'template', 'test-helper', 'transform', 'transform-test', 'util', 'util-test', 'view', 'view-test']
endfunction

let s:efm_generate =
      \'%-G%.%#version:%.%#,' .
      \'%-G%.%#help`%.%#,' .
      \'%-G%.%#Overwrite%.%#,' .
      \'%\S%\+ %m %f,' .
      \'%m %f, ' .
      \ '%-G%.%#'

function! s:app_generator_command(bang,...) dict
  let cmd = join(map(copy(a:000),'s:rquote(v:val)'),' ')
  let old_makeprg = &l:makeprg
  let old_errorformat = &l:errorformat
  try
    let &l:makeprg = 'ember '.cmd
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

call s:add_methods('app', ['path', 'generators', 'generator_command'])

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
" }}}1
" Projection Commands {{{1

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
" }}}1
" Detection {{{1

function! s:SetBasePath() abort
  let self = ember#buffer()
  if self.app().path() =~ '://'
    return
  endif
endfunction

function! ember#buffer_setup() abort
  if !exists('b:ember_root')
    return ''
  endif
  let self = ember#buffer()
  call s:BufScriptWrappers()
  call s:SetBasePath()
  let ft = self.getvar('&filetype')
  if ft =~# '^javascript'
    if exists("g:loaded_surround")
      call self.setvar('surround_36', "${\r}")            " $
      call self.setvar('surround_103', "this.get('\r')")  " g
      call self.setvar('surround_115', "this.set('\r')")  " t
      call self.setvar('surround_97', "this.attr('\r')")  " a
    endif
  endif
  if ft =~# 'handlebars'
    if exists("g:loaded_surround")
      call self.setvar('surround_123', "{{\r}}")          " {
    endif
  endif
endfunction
" }}}1
" Initialization {{{1

if !exists('s:apps')
  let s:apps = {}
endif
" }}}1
" vim:set sw=2 sts=2:
