" Version: 0.0.1
" Author: memerelics <takuya21hashimoto@gmail.com>
" License: This file is placed in the public domain.

if exists("g:loaded_sidestep")
  finish
endif
let g:loaded_sidestep = 1
let s:keepcpo           = &cpo
set cpo&vim

" Sidestep:
"   dist: ['r', 'l'] - right or left.
function! s:Sidestep(dist)
  if getline('.') == ""
    echo "blank line."
    return 1
  endif
  let pos = getpos('.')
  let delimiter = ','
  let elements = split(getline('.'), delimiter)

  if len(elements) == 1
    echo "Cannot replace 1 item."
    return 1
  end

  let current_index = s:whichpart(elements, pos[2])

  if a:dist == 'r'
    let target_index = min([current_index + 1, len(elements) - 1])
    call s:check_range(target_index, current_index)
    let shift_chars  = len(elements[target_index]) + 1
  else
    let target_index = max([0, current_index - 1])
    call s:check_range(target_index, current_index)
    let shift_chars  = -(len(elements[target_index]) + 1)
  endif

  " TODO: detect () and move elements in ()
  let nochange_left = ""
  let nochange_right = ""

"  echo "----------"
"  echo elements
"  echo "current_index: " . current_index
"  echo "target_index: " . target_index
"  echo "----------"

  let tmp      = elements[current_index]
  let switched = elements
  let switched[current_index] = elements[target_index]
  let switched[target_index]  = tmp
  let result_str = nochange_left . join(switched, delimiter) . nochange_right
  call setline(pos[1], result_str)
  call cursor(pos[1], pos[2] + shift_chars)
endfunction

function! s:whichpart(list, index)
  let sum = 0
  let item_index = 0
  for item in a:list
    let sum = sum + (len(item) + 1)
    if sum > a:index
      return item_index
    endif
    let item_index += 1
  endfor
endfunction

function! s:check_range(target_index, current_index)
  if a:target_index == a:current_index
    echo "you're on the edge."
    return 1
  end
endfunction

" TODO: how to extract this part by regular expression?
" [hoge, test, fuga]

" hoge, test, fuga
" def method hoge, test, fuga
" (test, fuga, hoge)

" \s*\zs\S*,.*\ze$

" foobar

nnoremap <silent> <Plug>SidestepLeft  :<C-U>call <SID>Sidestep('l')<CR>
nnoremap <silent> <Plug>SidestepRight :<C-U>call <SID>Sidestep('r')<CR>

if !exists("g:sidestep_no_mappings") || !g:sidestep_no_mappings
  nmap gh <Plug>SidestepLeft
  nmap gl <Plug>SidestepRight
endif

" ---------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo

