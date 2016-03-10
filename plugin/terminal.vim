
function! s:Terminal(command)
    if len(a:command)
        call s:RunInlineCommand(a:command)
    else
        :enew
        "et nowrite
        nnore <silent> <buffer> <CR> :call RunLine(line('.'))<CR>
        nnore <silent> <buffer> <Up> :call CycleThroughHistory(1)<CR>
        nnore <silent> <buffer> <Down> :call CycleThroughHistory(-1)<CR>
    endif
endfunction

com! -complete=shellcmd -nargs=? Terminal :call s:Terminal('<args>')

function! s:RunCommand(command)
    set shell=/bin/bash\ -i
    execute ":$r ! " . a:command
    set shell=/bin/bash
endfunction

function! s:RunInlineCommand(command)
    set shell=/bin/bash\ -i
    execute ":r ! " . a:command
    set shell=/bin/bash
endfunction

function! s:MakeDivider(count)
    let divider = ''
    for i in range(a:count)
        let divider = divider . '-'
    endfor
    return divider
endfunction

function! s:PrintDivider(lineNumber)
    execute "normal o" . s:MakeDivider(winwidth(0) - len(a:lineNumber) - 3)
endfunction

function! s:PrintCommand(lineNumber)
    call s:PrintDivider(a:lineNumber)
    call s:RunCommand(getline(a:lineNumber))
    call s:PrintDivider(a:lineNumber)
    normal o
    normal o
endfunction


function! RunLine(lineNumber)
    let command = getline(a:lineNumber)
    if !len(command)
        return
    endif

    call s:SetHistoryPosition(-1)
    call s:AddToHistory(a:lineNumber)
    call s:PrintCommand(a:lineNumber)

endfunction

let s:history = []
function! s:AddToHistory(lineNumber)
    call add(s:history, a:lineNumber)
endfunction

let s:historyPosition = 0

function! s:SetHistoryPosition(value)
    let s:historyPosition = a:value
endfunction

function! s:IncrementHistoryPosition(amount)
    let s:historyPosition = s:historyPosition + a:amount

    if a:amount > 0
        if s:historyPosition >= len(s:history)
            call s:SetHistoryPosition(0)
        endif
    else
        if s:historyPosition < 0
            call s:SetHistoryPosition(len(s:history) - 1)
        endif
    endif
endfunction

function! CycleThroughHistory(direction)
    call s:IncrementHistoryPosition(a:direction)
    call setline('.', s:GetHistory(s:historyPosition))
endfunction

function! s:GetHistory(number)
    if a:number < (len(s:history)) && a:number >= 0
        return getline(s:history[(-1 - a:number)])
    else
        return ''
    endif
endfunction

