"AUTHOR:   Greg Sexton <gregsexton@gmail.com>
"WEBSITE:  http://www.gregsexton.org/portfolio/gitv/
"LICENSE:  Same terms as Vim itself (see :help license).
"NOTES:    Much of the credit for gitv goes to Tim Pope and the fugitive plugin
"          where this plugin either uses functionality directly or was inspired heavily.

if exists("g:loaded_gitv") || v:version < 700
  finish
endif
let g:loaded_gitv = 1

let s:savecpo = &cpo
set cpo&vim

"configurable options:
"g:Gitv_CommitStep     - int
"g:Gitv_OpenHorizontal - [0,1,'AUTO']
"g:Gitv_GitExecutable  - string

if !exists("g:Gitv_CommitStep")
    let g:Gitv_CommitStep = &lines
endif

if !exists('g:Gitv_GitExecutable')
  let g:Gitv_GitExecutable = 'git'
endif

"this counts up each time gitv is opened to ensure a unique file name
let g:Gitv_InstanceCounter = 0

command! -nargs=* -bang Gitv call s:OpenGitv(shellescape(<q-args>), <bang>0)
cabbrev gitv Gitv

"Public API:"{{{
fu! Gitv_OpenGitCommand(command, windowCmd, ...) "{{{
    "returns 1 if command succeeded with output
    "optional arg is a flag, if present runs command verbatim

    "this function is not limited to script scope as is useful for running other commands.
    "e.g call Gitv_OpenGitCommand("diff --no-color", 'vnew') is useful for getting an overall git diff.

    if !a:0     "no extra args
        "switches to the buffer repository before running the command and switches back after.
        let dir = fugitive#buffer().repo().dir()
        if dir == ''
            echom "No git repository could be found."
            return 0
        endif
        let workingDir = fnamemodify(dir,':h')

        let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd ' : 'cd '
        let bufferDir = getcwd()
        try
            execute cd.'`=workingDir`'
            let finalCmd = g:Gitv_GitExecutable.' --git-dir="' .dir. '" ' . a:command
            let result = system(finalCmd)
        finally
            execute cd.'`=bufferDir`'
        endtry
    else
        let result = system(a:command)
    endif

    if !exists('result') || result == ""
        echom "No output."
        return 0
    else
        if a:windowCmd == ''
            silent setlocal modifiable
            silent setlocal noreadonly
            1,$ d
        else
            let goBackTo = winnr()
            try
                if exists('workingDir') && exists('cd')
                    execute cd.'`=workingDir`'
                endif
                exec a:windowCmd
                let newWindow = winnr()
            finally
                exec goBackTo . 'wincmd w'
                if exists('bufferDir') && exists('cd')
                    execute cd.'`=bufferDir`'
                endif
                if exists('newWindow')
                    exec newWindow . 'wincmd w'
                endif
            endtry
        endif
        if !(&modifiable)
            return 0
        endif
        if !a:0
            let b:Git_Command = finalCmd
        else
            let b:Git_Command = a:command
        endif
        silent setlocal ft=git
        silent setlocal buftype=nofile
        silent setlocal nobuflisted
        silent setlocal noswapfile
        silent setlocal bufhidden=wipe
        silent setlocal nonumber
        silent setlocal nowrap
        silent setlocal fdm=syntax
        silent setlocal foldlevel=0
        nmap <buffer> <silent> q :q!<CR>
        nmap <buffer> <silent> u :if exists('b:Git_Command')<bar>call Gitv_OpenGitCommand(b:Git_Command, '', 1)<bar>endif<cr>
        call append(0, split(result, '\n')) "system converts eols to \n regardless of os.
        silent setlocal nomodifiable
        silent setlocal readonly
        1
        return 1
    endif
endf "}}} }}}
"Open And Update Gitv:"{{{
fu! s:OpenGitv(extraArgs, fileMode) "{{{
    let sanatizedArgs = a:extraArgs == "''" ? '' : a:extraArgs
    let g:Gitv_InstanceCounter += 1
    if !s:IsCompatible() "this outputs specific errors
        return
    endif
    try
        if a:fileMode
            call s:OpenFileMode(sanatizedArgs)
        else
            call s:OpenBrowserMode(sanatizedArgs)
        endif
    catch /not a git repository/
        echom 'Not a git repository.'
        return
    endtry
endf "}}}
fu! s:IsCompatible()
    if !exists('g:loaded_fugitive')
        echoerr "gitv requires the fugitive plugin to be installed."
    endif
    return exists('g:loaded_fugitive')
endfu
fu! s:OpenBrowserMode(extraArgs) "{{{
    "this throws an exception if not a git repo which is caught immediately
    let fubuffer = fugitive#buffer()
    silent Gtabedit HEAD

    if s:IsHorizontal()
        let direction = 'new gitv'.'-'.g:Gitv_InstanceCounter
    else
        let direction = 'vnew gitv'.'-'.g:Gitv_InstanceCounter
    endif
    if !s:LoadGitv(direction, 0, g:Gitv_CommitStep, a:extraArgs, '')
        return 0
    endif
    call s:SetupBufferCommands(0)
    "open the first commit
    silent call s:OpenGitvCommit("Gedit")
endf "}}}
fu! s:OpenFileMode(extraArgs) "{{{
    let relPath = fugitive#buffer().path()
    pclose!
    if !s:LoadGitv(&previewheight . "new gitv".'-'.g:Gitv_InstanceCounter, 0, g:Gitv_CommitStep, a:extraArgs, relPath)
        return 0
    endif
    set previewwindow
    set winfixheight
    let b:Gitv_FileMode = 1
    let b:Gitv_FileModeRelPath = relPath
    call s:SetupBufferCommands(1)
endf "}}}
fu! s:LoadGitv(direction, reload, commitCount, extraArgs, filePath) "{{{
    if a:reload
        let jumpTo = line('.') "this is for repositioning the cursor after reload
    endif

    if !s:ConstructAndExecuteCmd(a:direction, a:reload, a:commitCount, a:extraArgs, a:filePath)
        return 0
    endif
    call s:SetupBuffer(a:commitCount, a:extraArgs, a:filePath)
    exec exists('jumpTo') ? jumpTo : '1'
    call s:SetupMappings() "redefines some of the mappings made by Gitv_OpenGitCommand
    call s:ResizeWindow(a:filePath!='')

    echom "Loaded up to " . a:commitCount . " commits."
    return 1
endf "}}}
fu! s:ConstructAndExecuteCmd(direction, reload, commitCount, extraArgs, filePath) "{{{
    if a:reload "run the same command again with any extra args
        if exists('b:Git_Command')
            "substitute in the potentially new commit count taking account of a potential filePath
            let newcmd = b:Git_Command
            if a:filePath != ''
                let newcmd = substitute(newcmd, " -- " . a:filePath . "$", "", "")
            endif
            let newcmd = substitute(newcmd, " -\\d\\+$", " -" . a:commitCount, "")
            if a:filePath != ''
                let newcmd .= ' -- ' . a:filePath
            endif
            silent let res = Gitv_OpenGitCommand(newcmd, a:direction, 1)
            return res
        endif
    else
        let cmd  = "log " . a:extraArgs 
        let cmd .= " --no-color --decorate=full --pretty=format:\"%d %s__SEP__%ar__SEP__%an__SEP__[%h]\" --graph -" 
        let cmd .= a:commitCount
        if a:filePath != ''
            let cmd .= ' -- ' . a:filePath
        endif
        silent let res = Gitv_OpenGitCommand(cmd, a:direction)
        return res
    endif
    return 0
endf "}}}
fu! s:SetupBuffer(commitCount, extraArgs, filePath) "{{{
    silent set filetype=gitv
    let b:Gitv_CommitCount = a:commitCount
    let b:Gitv_ExtraArgs   = a:extraArgs
    silent setlocal modifiable
    silent setlocal noreadonly
    silent %s/refs\/tags\//t:/ge
    silent %s/refs\/remotes\//r:/ge
    silent %s/refs\/heads\///ge
    "silent 1,$Tabularize /__SEP__/
    "silent %s/__SEP__//ge
    silent %call s:Align("__SEP__")
    silent %s/\s\+$//e
    call append(line('$'), '-- Load More --')
    if a:filePath != ''
        call append(0, '-- ['.a:filePath.'] --')
    endif
    silent setlocal nomodifiable
    silent setlocal readonly
    silent setlocal cursorline
endf "}}}
fu! s:SetupMappings() "{{{
    "operations
    nmap <buffer> <silent> <cr> :call <SID>OpenGitvCommit("Gedit")<cr>
    nmap <buffer> <silent> o :call <SID>OpenGitvCommit("Gsplit")<cr>
    nmap <buffer> <silent> O :call <SID>OpenGitvCommit("Gtabedit")<cr>
    nmap <buffer> <silent> s :call <SID>OpenGitvCommit("Gvsplit")<cr>

    nmap <buffer> <silent> q :call <SID>CloseGitv()<cr>
    nmap <buffer> <silent> u :call <SID>LoadGitv('', 1, b:Gitv_CommitCount, b:Gitv_ExtraArgs, <SID>GetRelativeFilePath())<cr>
    nmap <buffer> <silent> co :call <SID>CheckOutGitvCommit()<cr>

    nmap <buffer> <silent> D :call <SID>DiffGitvCommit()<cr>
    vmap <buffer> <silent> D :call <SID>DiffGitvCommit()<cr>

    nmap <buffer> <silent> S :call <SID>StatGitvCommit()<cr>
    vmap <buffer> <silent> S :call <SID>StatGitvCommit()<cr>

    "movement
    nmap <buffer> <silent> x :call <SID>JumpToBranch(0)<cr>
    nmap <buffer> <silent> X :call <SID>JumpToBranch(1)<cr>
    nmap <buffer> <silent> r :call <SID>JumpToRef(0)<cr>
    nmap <buffer> <silent> R :call <SID>JumpToRef(1)<cr>
    nmap <buffer> <silent> P :call <SID>JumpToHead()<cr>
endf "}}}
fu! s:SetupBufferCommands(fileMode) "{{{
    if a:fileMode || s:IsHorizontal()
        silent command! -buffer -nargs=* -complete=customlist,s:fugitive_GitComplete Git wincmd j|Git <args>|wincmd k|normal u
    else
        silent command! -buffer -nargs=* -complete=customlist,s:fugitive_GitComplete Git wincmd l|Git <args>|wincmd h|normal u
    endif
endfu "}}}
fu! s:ResizeWindow(fileMode) "{{{
    if a:fileMode "window height determined by &previewheight
        return
    endif
    if !s:IsHorizontal()
        "size window based on longest line
        let longest = max(map(range(1, line('$')), "virtcol([v:val, '$'])"))
        if longest > &columns/2
            "potentially auto change to horizontal
            if s:AutoHorizontal()
                "switching to horizontal
                let b:Gitv_AutoHorizontal=1
                wincmd K
                call s:ResizeWindow(a:fileMode)
                return
            else
                let longest = &columns/2
            endif
        endif
        exec "vertical resize " . longest
    else
        "size window based on num lines
        call s:ResizeHorizontal()
    endif
endf "}}} }}}
"Utilities:"{{{
fu! s:GetGitvSha(lineNumber) "{{{
    let l = getline(a:lineNumber)
    let sha = matchstr(l, "\\[\\zs[0-9a-f]\\{7}\\ze\\]$")
    return sha
endf "}}}
fu! s:GetGitvRefs() "{{{
    let l = getline('.')
    let refstr = matchstr(l, "^\\(\\(|\\|\\/\\|\\\\\\|\\*\\)\\s\\?\\)*\\s\\+(\\zs.\\{-}\\ze)")
    let refs = split(refstr, ', ')
    return refs
endf "}}}
fu! s:MoveIntoPreviewAndExecute(cmd) "{{{
    let horiz = s:IsHorizontal()
    let filem = s:IsFileMode()
    if !filem
        if horiz
            wincmd j
        else
            wincmd l
        endif
    endif
    exec a:cmd
    if !filem
        if horiz
            wincmd k
        else
            wincmd h
        endif
    endif
endfu "}}}
fu! s:IsHorizontal() "{{{
    "NOTE: this can only tell you if horizontal while cursor in browser window
    let horizGlobal = exists('g:Gitv_OpenHorizontal') && g:Gitv_OpenHorizontal == 1
    let horizBuffer = exists('b:Gitv_AutoHorizontal') && b:Gitv_AutoHorizontal == 1
    return horizGlobal || horizBuffer
endf "}}}
fu! s:AutoHorizontal() "{{{
    return exists('g:Gitv_OpenHorizontal') && g:Gitv_OpenHorizontal ==? 'auto'
endf "}}}
fu! s:IsFileMode() "{{{
    return exists('b:Gitv_FileMode') && b:Gitv_FileMode == 1
endf "}}}
fu! s:ResizeHorizontal() "{{{
    let lines = line('$')
    if lines > (&lines/2)-2
        let lines = (&lines/2)-2
    endif
    exec "resize " . lines
endf "}}}
fu! s:GetRelativeFilePath() "{{{
    return exists('b:Gitv_FileModeRelPath') ? b:Gitv_FileModeRelPath : ''
endf "}}}
fu! s:OpenRelativeFilePath(sha, geditForm) "{{{
    let relPath = s:GetRelativeFilePath()
    if relPath == ''
        return
    endif
    wincmd j
    exec a:geditForm . " " . a:sha . ":" . relPath
endf "}}} }}}
"Mapped Functions:"{{{
"Operations: "{{{
fu! s:OpenGitvCommit(geditForm) "{{{
    if getline('.') == "-- Load More --"
        call s:LoadGitv('', 1, b:Gitv_CommitCount+g:Gitv_CommitStep, b:Gitv_ExtraArgs, s:GetRelativeFilePath())
        return
    endif
    if s:IsFileMode() && getline('.') =~ "^-- \\[.*\\] --$"
        "open working copy of file
        let fp = s:GetRelativeFilePath()
        wincmd j
        let form = a:geditForm[1:] "strip off the leading 'G'
        exec form . " " . fugitive#buffer().repo().tree() . "/" . fp
        return
    endif
    let sha = s:GetGitvSha(line('.'))
    if sha == ""
        return
    endif
    if s:IsFileMode()
        call s:OpenRelativeFilePath(sha, a:geditForm)
        wincmd k
    else
        call s:MoveIntoPreviewAndExecute(a:geditForm . " " . sha)
    endif
endf "}}}
fu! s:CheckOutGitvCommit() "{{{
    let allrefs = s:GetGitvRefs()
    let sha = s:GetGitvSha(line('.'))
    if sha == ""
        return
    endif
    "remove remotes
    let refs   = filter(allrefs, 'match(v:val, "^r:")==-1')
    let refs  += [sha]
    let refstr = join(refs, "\n")
    let choice = confirm("Checkout commit:", refstr . "\nCancel")
    if choice == 0
        return
    endif
    let choice = get(refs, choice-1, "")
    if choice == ""
        return
    endif
    let choice = substitute(choice, "^t:", "", "")
    if s:IsFileMode()
        let relPath = s:GetRelativeFilePath()
        let choice .= " -- " . relPath
    endif
    exec "Git checkout " . choice
endf "}}}
fu! s:CloseGitv() "{{{
    if s:IsFileMode()
        q
    else
        tabc
    endif
endf "}}}
fu! s:DiffGitvCommit() range "{{{
    if !s:IsFileMode()
        echom "Diffing is not possible in browser mode."
        return
    endif
    let shafirst = s:GetGitvSha(a:firstline)
    let shalast  = s:GetGitvSha(a:lastline)
    if shafirst == "" || shalast == ""
        return
    endif
    if a:firstline != a:lastline
        call s:OpenRelativeFilePath(shafirst, "Gedit")
    else
        wincmd j
    endif
    exec "Gdiff " . shalast
endf "}}} 
fu! s:StatGitvCommit() range "{{{
    let shafirst = s:GetGitvSha(a:firstline)
    let shalast  = s:GetGitvSha(a:lastline)
    if shafirst == "" || shalast == ""
        return
    endif
    let cmd  = 'diff '.shafirst
    if shafirst != shalast
        let cmd .= ' '.shalast
    endif
    let cmd .= ' --stat'
    let cmd = "call s:SetupStatBuffer('".cmd."')"
    call s:MoveIntoPreviewAndExecute(cmd)
endf "}}}
fu! s:SetupStatBuffer(cmd) "{{{
    silent let res = Gitv_OpenGitCommand(a:cmd, s:IsFileMode()?'vnew':'')
    if res
        silent set filetype=gitv
    endif
endfu "}}} }}}
"Movement: "{{{
fu! s:JumpToBranch(backward) "{{{
    if a:backward
        silent! ?|/\||\\?-1
    else
        silent! /|\\\||\//+1
    endif
endf "}}}
fu! s:JumpToRef(backward) "{{{
    if a:backward
        silent! ?^\(\(|\|\/\|\\\|\*\)\s\=\)\+\s\+\zs(
    else
        silent! /^\(\(|\|\/\|\\\|\*\)\s\?\)\+\s\+\zs(/
    endif
endf "}}}
fu! s:JumpToHead() "{{{
    silent! /^\(\(|\|\/\|\\\|\*\)\s\?\)\+\s\+\zs(HEAD/
endf "}}}
"}}} }}}
"Alignment Functions: "{{{
fu! s:Align(seperator) range "{{{
    let lines = getline(a:firstline, a:lastline)
    call map(lines, 'split(v:val, a:seperator)')

    let newlines = copy(lines)
    call filter(newlines, 'len(v:val)>1')
    let maxLens = s:MaxLengths(newlines)

    "TODO: this could probably be nicer:
    let cnt = a:firstline
    for tokens in lines
        if len(tokens)>1
            let newline = []
            for i in range(len(tokens))
                let token = tokens[i]
                call add(newline, token . repeat(' ', maxLens[i]-strlen(token)+1))
            endfor
            call setline(cnt, join(newline))
        endif
        let cnt += 1
    endfor
endfu "}}}
fu! s:MaxLengths(colls) "{{{
    "precondition: coll is a list of lists of strings -- should be rectangular
    "returns a list of maximum string lengths
    let lengths = []
    for x in a:colls
        for y in range(len(x))
            let length = strlen(x[y])
            if length > get(lengths, y, 0)
                if len(lengths)-1 < y
                    call add(lengths, length)
                else
                    let lengths[y] = length
                endif
            endif
        endfor
    endfor
    return lengths
endfu "}}} }}}
"Fugitive Functions: "{{{
"These functions are lifted directly from fugitive and modified only to work with gitv.
function! s:fugitive_sub(str,pat,rep) abort "{{{
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction "}}}
function! s:fugitive_GitComplete(A,L,P) abort "{{{
  if !exists('s:exec_path')
    let s:exec_path = s:fugitive_sub(system(g:fugitive_git_executable.' --exec-path'),'\n$','')
  endif
  let cmds = map(split(glob(s:exec_path.'/git-*'),"\n"),'s:fugitive_sub(v:val[strlen(s:exec_path)+5 : -1],"\\.exe$","")')
  if a:L =~ ' [[:alnum:]-]\+ '
    return fugitive#buffer().repo().superglob(a:A)
  elseif a:A == ''
    return cmds
  else
    return filter(cmds,'v:val[0 : strlen(a:A)-1] ==# a:A')
  endif
endfunction "}}} }}}

let &cpo = s:savecpo
unlet s:savecpo

 " vim:fdm=marker
