if exists('g:autoloaded_ember') || &cp
  finish
endif
let g:autoloaded_ember = 1

function! ember#buffer_setup() abort
  if !exists('b:ember_root')
    return ''
  endif
endfunction
