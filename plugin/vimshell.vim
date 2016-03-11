function! s:Vimshell(command)
    if len(a:command)
        call s:RunInlineCommand(a:command)
    else
        :enew
        let b:isShell = 1
        autocmd TextChanged,TextChangedI * :call s:AddPromptToLine()

        nnore <silent> <buffer> <CR> :call RunLine(line('.'))<CR>
        nnore <silent> <buffer> <Up> :call CycleThroughHistory(1)<CR>
        nnore <silent> <buffer> <Down> :call CycleThroughHistory(-1)<CR>

        inore <silent> <buffer> <CR> :call RunLine(line('.'))<CR>
        inore <silent> <buffer> <Up> :call CycleThroughHistory(1)<CR>
        inore <silent> <buffer> <Down> :call CycleThroughHistory(-1)<CR>

        call s:AddPromptToLine()
    endif
endfunction

com! -complete=shellcmd -nargs=? Vimshell :call s:Vimshell('<args>')

function! s:MakePromt()
    return 'vim-shell>'
endfunction

function! s:AddPromptToLine()
    if exists('b:isShell') && b:isShell
        let line = getline('.')
        if line !~ s:MakePromt() 
            call s:SetLine(line)
        endif
    endif
endfunction


function! s:RunCommand(command)
    set shell=/bin/bash\ -i
    "execute ":$r ! " . a:command

    let resultOneline = system(a:command)
    let result = split(resultOneline, "\n")
    call append('.', result)
    normal G
    set shell=/bin/bash
endfunction

function! s:RunInlineCommand(command)
    set shell=/bin/bash\ -i
    execute ":r ! " . a:command
    normal o
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

function! s:GetCommandFromLineNumber(lineNumber)
    let commandLine = getline(a:lineNumber)
    if commandLine =~ s:MakePromt() 
        return s:Trim(split(commandLine, '>', 2)[1])
    else
        return s:Trim(commandLine)
    endif
endfunction

function! s:Trim(string)
    return substitute(a:string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! s:PrintCommand(lineNumber, command)
    call s:RunCommand(a:command)
    normal o
    call s:SetLine('')
endfunction


function! RunLine(lineNumber)
    let command = s:GetCommandFromLineNumber(a:lineNumber)
    if !len(command)
        normal o
        return
    endif

    call s:SetHistoryPosition(-1)
    call s:AddToHistory(command)
    call s:PrintCommand(a:lineNumber, command)
endfunction

let s:history = []
function! s:AddToHistory(line)
    call add(s:history, a:line)
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
    call s:SetLine(s:GetHistory(s:historyPosition))
endfunction

function! s:SetLine(line)
    call setline('.', s:MakePromt() . "  " . a:line)
    normal A
endfunction

function! s:GetHistory(number)
    if a:number < (len(s:history)) && a:number >= 0
        return s:history[(-1 - a:number)]
    else
        return ''
    endif
endfunction

