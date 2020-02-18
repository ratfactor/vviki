" Copyright (c) 2020 Dave Gauer
" MIT License

if exists('g:loaded_vviki')
	finish
endif
let g:loaded_vviki = 1

" Initialize defaults
if !exists('g:vviki_root')
	let g:vviki_root = "~/wiki"
endif

if !exists('g:vviki_ext')
	let g:vviki_ext = ".adoc"
endif

" Navigation history for Backspace
let s:history = []

" Supported link styles:
function! VVEnter()
	" Get path from AsciiDoc link macro
	"   link:http://example.com[Example] - external
	"   link:page[My Page]               - internal
	"   link:/page[My Page]              - internal absolute path
	"   link:../page[My Page]            - internal relative path
    let l:linkpath = VVGetLink()
	if strlen(l:linkpath) > 0
		if l:linkpath =~ '^https\?://'
			call VVGoUrl(l:linkpath)
		else
			call VVGoPath(l:linkpath)
		endif
		return
	end

	" Did not match a link macro. Now there are three possibilities:
	"   1. We are on whitespace
	"   2. We are on a bare URL (http://...)
	"   3. We are on an unlinked word
	let l:word = expand("<cWORD>")

	if l:word == ''
		return
	endif

	if l:word =~ '^https\?://'
		call VVGoUrl(l:word)
		return
	endif

	" Not a link yet - make it a link!
	execute "normal! ciWlink:".l:word."[".l:word."]\<ESC>"
endfunction

function! VVGetLink()
	" Captures the <path> portion of 'link:<path>[description]'
    let l:linkrx = 'link:\([^[]\+\)\[[^]]\+\]'
    " Grab cursor pos and current line contents
    let l:cursor = col('.')
    let l:linestr = getline('.')

    " Loop through the wiki link matches on the line, see if our cursor
    " is inside one of them.  If so, return it.
    let l:linkstart=0
    let l:linkend=0
    while 1
        " Note: match() always functions as if pattern were in "magic" mode!
        let l:linkstart =   match(l:linestr, l:linkrx, l:linkend)
		let l:matched = matchlist(l:linestr, l:linkrx, l:linkend)
        let l:linkend =  matchend(l:linestr, l:linkrx, l:linkend)

        " No link found or we're already past the cursor; done looking
        if l:linkstart == -1 || l:linkstart > l:cursor
            return ""
        endif

        if l:linkstart <= l:cursor && l:cursor <= l:linkend
			return l:matched[1]
        endif
    endwhile
endfunction

function! VVGoPath(path)
	" Push current page onto history
	call add(s:history, expand("%:p"))

	if a:path =~ '^/'
		" Path absolute from wiki root
		let l:fname = g:vviki_root."/".a:path.g:vviki_ext
	else
		" Path relative to current page
		let l:fname = expand("%:p:h")."/".a:path.g:vviki_ext
	endif

	execute "edit ".l:fname
endfunction

function! VVGoUrl(url)
	call system('xdg-open '.shellescape(a:url).' &')
endfunction

function! VVBack()
	if len(s:history) < 1
		return
	endif

	let l:last = remove(s:history, -1)
	execute "edit ".l:last
endfunction

function! VVSetup()
	" Set wiki pages to automatically save
	set autowriteall

	" Map ENTER key to create/follow links
	nnoremap <buffer> <CR> :call VVEnter()<CR>

	" Map BACKSPACE key to go back in history
	nnoremap <buffer> <BS> :call VVBack()<CR>

	" Hide the heavy link AsciiDoc link syntax:
	"   link:<path>[<description>]
	" Level 2 hides the matched syntax.
	set conceallevel=2
	" Match 'link:<path>['
	call matchadd('Conceal', '\vlink:[^[]+\[')
	" Match the ending ']'
	call matchadd('Conceal', '\vlink:[^[]+\[[^]]+\zs\]')
endfunction

" Detect wiki page
" If a buffer has the right parent directory and extension,
" map VViki keyboard shortcuts, etc.
augroup vviki
	au!
	execute "au BufNewFile,BufRead,BufEnter,WinEnter ".g:vviki_root."/*".g:vviki_ext." call VVSetup()"
augroup END

