"
" simple_comments.vim - Simple script for commenting and uncommenting lines
"
" Author:  Anders Thøgersen <anders [at] bladre.dk>
" Version: 1.2
" Date:    31-Dec-2010
"
" $Id$
"
" See simple_comments.txt for more info
"
" GetLatestVimScripts: 2654 1 :AutoInstall: simple_comments.vba.gz
"
" TODO
"       let g:simple_comments_CommentsInSameColumn
"       Do Something when the filetype changes

if exists('loaded_simple_comments') || &cp
    finish
endif

if v:version < 700
    echoerr "simple_comments: this plugin requires vim >= 7."
    finish
endif

let loaded_simple_comments = 1

let s:savedCpo = &cpoptions
set cpoptions&vim

" Initialization
fun! s:AddVar(var, val)
    if ! exists(a:var)
        exe 'let '. a:var ." = '". a:val ."'"
    endif
endfun

call s:AddVar('g:simple_comments_Comment', '<M-x>')
call s:AddVar('g:simple_comments_Remove',  '<M-z>')
call s:AddVar('g:simple_comments_LeftPlaceHolder',  '[>')
call s:AddVar('g:simple_comments_RightPlaceHolder', '<]')

if ! exists('g:simple_comments_SyntaxDictionary')
    let g:simple_comments_SyntaxDictionary = {}
endif

exe 'nmap <silent> '. g:simple_comments_Comment .' :call <SID>CommentRememberCursor("C")<CR>'
exe 'nmap <silent> '. g:simple_comments_Remove  .' :call <SID>CommentRememberCursor("D")<CR>'

exe 'imap <silent> '. g:simple_comments_Comment .' <C-o>:call <SID>AddComment()<CR>'
exe 'imap <silent> '. g:simple_comments_Remove  .' <C-o>:call <SID>DelComment()<CR>'

exe 'vmap <silent> '. g:simple_comments_Comment .' :call <SID>CommentRememberCursor("C")<CR>'
exe 'vmap <silent> '. g:simple_comments_Remove  .' :call <SID>CommentRememberCursor("D")<CR>'

" Clean up 
delfunction s:AddVar
unlet g:simple_comments_Remove
unlet g:simple_comments_Comment

fun! s:SetCommentVars(comstr, name)
    exe "let b:simple_comments_".a:name."left       = substitute('".a:comstr."', '\\(.*\\)%s.*', '\\1', '')"
    exe "let b:simple_comments_".a:name."right      = substitute('".a:comstr."', '.*%s\\(.*\\)', '\\1', 'g')"
    exe "let b:simple_comments_".a:name."left_del   = substitute(b:simple_comments_".a:name."left, '\\s\\+', '', 'g')"
    exe "let b:simple_comments_".a:name."right_del  = substitute(b:simple_comments_".a:name."right, '\\s\\+', '', 'g')"
endfun

fun! s:SetSynComments()
    let name = s:GetAltName()
    exe "let b:simple_comments_left = b:simple_comments_".name .'left' 
    exe "let b:simple_comments_right = b:simple_comments_".name .'right' 
    exe "let b:simple_comments_left_del = b:simple_comments_".name .'left_del' 
    exe "let b:simple_comments_right_del = b:simple_comments_".name .'right_del' 
endfun

fun! s:SetAllCommentVars()
    if &commentstring == ''
        setlocal commentstring=/*\ %s\ */
    endif
    call s:SetCommentVars(&commentstring, '')
    " Do we use a syntax comment?
    if has_key(g:simple_comments_SyntaxDictionary, &filetype)
        let com = g:simple_comments_SyntaxDictionary[&filetype]
        for key in keys(com)
            call s:SetCommentVars(com[key], key)
        endfor
        call s:SetSynComments()
    endif
endfun

fun! s:GetAltName()
    let mycol  = col(".")
    let myline = line(".")
    normal ^
    call search('\S', 'c', line("."))
    let ign = &ignorecase
    set noignorecase
    let name = substitute(synIDattr(synID(myline, col("."), 0), "name"), '^\([a-z]*\).*$', '\1', '')
    exe 'let &ignorecase = '. ign
    call cursor(myline, mycol)
    return name
endfun

fun! s:AddComment()
    let g:sc = "AddComment"
    let line  = getline(".")
    if line =~ '^\s*$'
        return
    endif
    if &filetype == ''
        echo "simple_comments: The filetype is empty, don't know what to do."
        return
    endif
    if has_key(g:simple_comments_SyntaxDictionary, &filetype)
        call s:SetSynComments()
    endif

    " Toggle previous comment
    if b:simple_comments_right != '' && stridx(line, b:simple_comments_left_del) != -1
        exe ':silent! s/^\(\s*\)'.escape(b:simple_comments_left_del,'[].\\/*').'\s*/\1'.g:simple_comments_LeftPlaceHolder.'/'
    endif
    if b:simple_comments_right != '' && stridx(line, b:simple_comments_right) != -1
        exe ':silent! s/\s*'.escape(b:simple_comments_right_del,'[].\\/*').'\s*$/'.g:simple_comments_RightPlaceHolder.'/'
    endif
    " Add commentstring
    exe ':silent! s/^\(\s*\)/\1'.escape(b:simple_comments_left, '[].\\/*').'/'
    if b:simple_comments_right != ''
        exe ':silent! s/\s*$/'.escape(b:simple_comments_right,'[].\\/*').'/'
    endif
endfun

fun! s:DelComment()
    let line  = getline(".")
    if has_key(g:simple_comments_SyntaxDictionary, &filetype)
        call s:SetSynComments()
    endif
    if &filetype == ''
        echo "simple_comments: The filetype is empty, don't know what to do."
        return
    endif
    " Delete comments
    if stridx(line, b:simple_comments_left_del) != -1
        exe ':silent! s/^\(\s*\)'.escape(b:simple_comments_left_del,'[].\\/*').'\s*/\1/'
    endif
    if b:simple_comments_right != '' && stridx(line, b:simple_comments_right_del) != -1
        exe ':silent! s/'.escape(b:simple_comments_right_del,'[].\\/*').'\s*$//'
    endif
    " Re-insert old comments
    if stridx(line, g:simple_comments_LeftPlaceHolder) != -1
        exe ':silent! s/^\(\s*\)'.escape(g:simple_comments_LeftPlaceHolder,'[').'/\1'.escape(b:simple_comments_left,'[].\\/*').'/'
    endif
    if stridx(line, g:simple_comments_RightPlaceHolder) != -1
        exe ':silent! s/'.escape(g:simple_comments_RightPlaceHolder,']').'\s*$/'.escape(b:simple_comments_right,'[].\\/*').'/'
    endif
endfun

fun! s:CommentRememberCursor(action) range
    let saveCursor = getpos(".")
    " Insertion and deletion of comments is done backwards to set the right
    " comments according to g:simple_comments_SyntaxDictionary 
    if a:action == 'D'
        let l:count = a:lastline
        while l:count >= a:firstline
            exe ':'. string(l:count) .'call s:DelComment()'
            let l:count -= 1
        endwhile
    elseif a:action == 'C'
        let l:count = a:lastline
        while l:count >= a:firstline
            exe ':'. string(l:count) .'call s:AddComment()'
            let l:count -= 1
        endwhile
    endif
    call setpos('.', saveCursor)
endfun

command! -nargs=0 SimpleComments :call s:SetAllCommentVars()

augroup COMMENTS
    autocmd!
    autocmd BufWinEnter * :call s:SetAllCommentVars()
augroup END

let &cpoptions = s:savedCpo

