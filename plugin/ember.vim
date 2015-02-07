if exists('g:loaded_ember') || &cp || v:version < 700
  finish
endif
let g:loaded_ember = 1

function! EmberDetect(...) abort
  if exists('b:ember_root')
    return 1
  endif
  let fn = fnamemodify(a:0 ? a:1 : expand('%'), ':p')
  if !isdirectory(fn)
    let fn = fnamemodify(fn, ':h')
  endif
  let file = findfile('.ember-cli', escape(fn, ', ').';')
  if !empty(file)
    let b:ember_root = fnamemodify(file, ':p:h')
    return 1
  endif
endfunction

if !exists('g:did_load_ftplugin')
  filetype plugin on
endif
if !exists('g:loaded_projectionist')
  runtime! plugin/projectionist.vim
endif

augroup emberPluginDetect
  autocmd!
  autocmd BufEnter * if exists("b:ember_root")|silent doau User BufEnterEmber|endif
  autocmd BufLeave * if exists("b:ember_root")|silent doau User BufLeaveEmber|endif

  autocmd BufNewFile,BufReadPost *
        \ if EmberDetect(expand("<afile>:p")) && empty(&filetype) |
        \   call ember#buffer_setup() |
        \ endif
  autocmd VimEnter *
        \ if empty(expand("<amatch>")) && EmberDetect(getcwd()) |
        \   call ember#buffer_setup() |
        \   silent doau User BufEnterEmber |
        \ endif
  autocmd FileType netrw
        \ if EmberDetect() |
        \   silent doau User BufEnterEmber |
        \ endif
  autocmd FileType * if EmberDetect() | call ember#buffer_setup() | endif

  autocmd User ProjectionistDetect
        \ if EmberDetect(get(g:, 'projectionist_file', '')) |
        \   call projectionist#append(b:ember_root, s:projections) |
        \ endif
augroup END

let s:projections =
\{
\  "app/adapters/*.js": {
\    "command": "adapter",
\    "alternate": "tests/unit/adapters/{}-test.js"
\  },
\  "app/app.js": { "command": "app" },
\  "Brocfile.js": { "command": "brocfile" },
\  "app/components/*.js": {
\    "command": "component",
\    "alternate": "tests/unit/components/{}-test.js"
\  },
\  "app/controllers/*.js": {
\    "command": "controller",
\    "alternate": "tests/unit/controllers/{}-test.js"
\  },
\  "app/helpers/*.js": {
\    "command": "helper",
\    "alternate": "tests/unit/helpers/{}-test.js"
\  },
\  "app/index.html": { "command": "index" },
\  "app/initializers/*.js": { "command": "initializer" },
\  "app/models/*.js": {
\    "command": "model",
\    "alternate": "tests/unit/models/{}-test.js"
\  },
\  "app/mixins/*.js": {
\    "command": "mixin",
\    "alternate": "tests/unit/mixins/{}-test.js"
\  },
\  "app/routes/*.js": {
\    "command": "route",
\    "alternate": "tests/unit/routes/{}-test.js"
\  },
\  "app/router.js": { "command": "router"},
\  "app/serializers/*.js": {
\    "command": "serializer",
\    "alternate": "tests/unit/serializers/{}-test.js"
\  },
\  "app/services/*.js": {
\    "command": "service",
\    "alternate": "tests/unit/services/{}-test.js"
\  },
\  "app/templates/*.hbs": {
\    "command": "template",
\  },
\  "app/transforms/*.js": {
\    "command": "transform",
\    "alternate": "tests/unit/transforms/{}-test.js"
\  },
\  "config/environment.js": { "command": "environment" },
\  "app/styles/*.scss": { "command": "style" },
\  "bower.json": { "command": "bower" },
\  "package.json": { "command": "package" },
\  "README.md": { "command": "readme" }
\}
