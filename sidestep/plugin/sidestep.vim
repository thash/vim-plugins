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

  if s:in_the_parentheses(getline('.'), pos[2])
    let match_list = matchlist(getline('.'), '\(.\{-}(\)\zs\S*,.*\ze\().*\)')
  else
    let match_list = matchlist(getline('.'), '\(.\{-}\)\zs\S*,.*')
  endif

  if len(match_list) == 0
    let nochange_left = ""
    let nochange_right = ""
    let elements = split(getline('.'), delimiter)
  else
    let nochange_left = match_list[1]
    let nochange_right = match_list[2]
    let elements = split(match_list[0], delimiter)
  endif

  if len(elements) == 1
    echo "Cannot replace 1 item."
    return 1
  end

  let current_index = s:whichpart(elements, pos[2] - len(nochange_left))

  if a:dist == 'r'
    let target_index = min([current_index + 1, len(elements) - 1])
    call s:check_range(target_index, current_index)
    let shift_chars  = len(elements[target_index]) + 1
  else
    let target_index = max([0, current_index - 1])
    call s:check_range(target_index, current_index)
    let shift_chars  = -(len(elements[target_index]) + 1)
  endif

  let tmp      = elements[current_index]
  let switched = elements
  let switched[current_index] = elements[target_index]
  let switched[target_index]  = tmp
  let switched2 = s:result_modifier(current_index, target_index, switched)

  let result_str = nochange_left . join(switched2, delimiter) . nochange_right
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


function! s:in_the_parentheses(str, col)
  " TODO: case when there're multiple parentheses.
  let index_s = match(getline('.'), '(.*)')
  let index_e = matchend(getline('.'), '(.*)')
  if index_s == -1
    return 0
  else
    if (index_s + 1) < a:col && a:col < index_e
      return 1
    else
      return 0
    end
    return 1
  endif
endfunction

function! s:result_modifier(current_index, target_index, switched)
  if a:current_index == 0 || (a:current_index == 1 && a:target_index == 0)
    let a:switched[0] = substitute(a:switched[0], "^ ", "", "")
    let a:switched[1] = substitute(a:switched[1], '^\zs\ze\S', " ", "")
    return a:switched
  else
    return a:switched
  endif
endfunction

nnoremap <silent> <Plug>SidestepLeft  :<C-U>call <SID>Sidestep('l')<CR>
nnoremap <silent> <Plug>SidestepRight :<C-U>call <SID>Sidestep('r')<CR>

if !exists("g:sidestep_no_mappings") || !g:sidestep_no_mappings
  nmap gh <Plug>SidestepLeft
  nmap gl <Plug>SidestepRight
endif

" ---------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo

