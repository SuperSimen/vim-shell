function! s:Vimshell(command)
    if len(a:command)
        call s:RunInlineCommand(a:command)
    else
        call s:SetupNewShell()
    endif
endfunction

function! s:SetupNewShell()
    :enew
    let b:isShell = 1
    autocmd TextChanged,TextChangedI * :call s:AddPromptToLine()

    nnore <silent> <buffer> <CR> :call RunLine(line('.'), 0)<CR>
    nnore <silent> <buffer> <Up> :call CycleThroughHistory(1)<CR>
    nnore <silent> <buffer> <Down> :call CycleThroughHistory(-1)<CR>

    inore <silent> <buffer> <CR> :call RunLine(line('.'), 1)<CR>
    inore <silent> <buffer> <Up> :call CycleThroughHistory(1)<CR>
    inore <silent> <buffer> <Down> :call CycleThroughHistory(-1)<CR>

    call s:AddPromptToLine()
endfunction

com! -complete=shellcmd -nargs=? Vimshell :call s:Vimshell('<args>')

function! s:BasePrompt()
    return 'vim-shell'
endfunction

function! s:MakePrompt()
    return "[" . s:BasePrompt() . " " . fnamemodify(getcwd(), ':~') . ']'
endfunction

function! s:AddPromptToLine()
    if exists('b:isShell') && b:isShell
        let line = getline('.')
        let prevLineNumber = prevnonblank('.')
        let prevLine = getline(prevLineNumber)

        if line !~ s:BasePrompt() && (prevLine =~ s:BasePrompt() || prevLineNumber == 0)
            call s:SetLine(line)
        endif
    endif
endfunction


let s:override = ['cd']

function! s:Runcd(splitCommand)
    try
        let command = ":lcd " . join(a:splitCommand[1:-1])
        execute command
        return []
    catch
        return [v:exception]
    endtry
endfunction

function! s:RunCommand(command)

    let splitCommand = split(a:command)
    if index(s:override, splitCommand[0]) != -1
        let result = s:RunOverride(splitCommand)
    else
        set shell=/bin/bash\ -i
        let resultOneline = system(a:command)
        let result = split(resultOneline, "\n")
        set shell=/bin/bash
    endif

    if len(result) > 0
        call append('$', result)
        normal G
    endif

endfunction

function! s:RunOverride(splitCommand)
    if index(s:override, a:splitCommand[0]) != -1
        return function('s:Run' . a:splitCommand[0])(a:splitCommand)
    endif
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
    if commandLine =~ s:BasePrompt() 
        return s:Trim(split(commandLine, ']', 2)[1])
    else
        return ''
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


function! RunLine(lineNumber, isInsertMode)
    let command = s:GetCommandFromLineNumber(a:lineNumber)
    if !len(command)
        if a:isInsertMode
            execute "normal! i"
        else
            execute "normal! "
        endif
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
    if len(a:line) > 0
        let completeLine = s:MakePrompt() . " " . a:line
    else
        let completeLine = s:MakePrompt() . "  "
    endif
    call setline('.', completeLine)
    normal A
endfunction

function! s:GetHistory(number)
    if a:number < (len(s:history)) && a:number >= 0
        return s:history[(-1 - a:number)]
    else
        return ''
    endif
endfunction

