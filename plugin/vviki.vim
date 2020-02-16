"
" = VViki =
" AsciiDoc-flavored wiki plugin for Vim.
" Copyright (c) 2020 Dave Gauer
" MIT License
"

if exists('g:loaded_vviki')
	finish
endif
let g:loaded_vviki = 1


" Load defaults
if !exists('g:vviki_root')
	let g:vviki_root = "~/wiki"
endif

if !exists('g:vviki_ext')
	let g:vviki_ext = ".adoc"
endif

let s:history = []

" Supported link styles:
"   http://example.com               - external
"   http://example.com[Example]      - external
"   link:http://example.com[Example] - external
"   link:page[My Page]               - internal
"   link:/page[My Page]              - internal absolute path
"   link:../page[My Page]            - internal relative path
function! VVLink()
	let l:word = expand("<cWORD>")

	" External URL link - open in browser
	if l:word =~ '^\(link:\)\?https\?://'
		" Strip off (any) link: and description [text]
		let l:word = substitute(l:word, '\[.*$','','')
		let l:word = substitute(l:word, '^link:','','')
		echom "external web link: ".l:word
		call system('xdg-open '.shellescape(l:word).' &')
	
	" Internal link - follow it
	elseif l:word =~ '^link:'
		" Push current page onto history
		call add(s:history, expand("%:p"))

		" Strip off link: and description [text]
		let l:word = substitute(l:word, '\[.*$','','')
		let l:word = substitute(l:word, '^link:','','')

		if l:word =~ '^/'
			" Path absolute from wiki root
			let l:fname = g:vviki_root."/".l:word.g:vviki_ext
		else
			" Path relative to current page
			let l:fname = expand("%:p:h")."/".l:word.g:vviki_ext
		endif
		execute "edit ".l:fname
	
	" Not a link yet - make it a link
	else
		execute "normal! ciWlink:".l:word."[".l:word."]\<ESC>"
	endif
endfunction

function! VVBack()
	if len(s:history) < 1
		return
	endif

	let l:last = remove(s:history, -1)
	echom "last was: ".l:last
	execute "edit ".l:last
endfunction

function! VVMap()
	" Set wiki pages to automatically save
	set autowriteall

	" Map ENTER key to create/follow links
	nnoremap <buffer> <CR> :call VVLink()<CR>

	" Map BACKSPACE key to go back in history
	nnoremap <buffer> <BS> :call VVBack()<CR>
endfunction

" This part belongs in <plugin>/ftdetect/vviki.vim
let s:root = expand(g:vviki_root)

augroup vviki
	au!
	execute "au BufNewFile,BufRead ".s:root."/*.adoc call VVMap()"
augroup END

