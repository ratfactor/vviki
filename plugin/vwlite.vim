"
" Vwlite! A 'lite' wiki for Vim!
"

if exists('g:loaded_vwlite')
	finish
endif
let g:loaded_vwlite = 1


" Load defaults
if !exists('g:vwlite_root')
	let g:vwlite_root = "~/vwlite"
endif

if !exists('g:vwlite_ext')
	let g:vwlite_ext = ".adoc"
endif

let s:history = []

" Supported link styles:
"   http://example.com               - external
"   http://example.com[Example]      - external
"   link:http://example.com[Example] - external
"   link:page[My Page]               - internal
"   link:/page[My Page]              - internal absolute path
"   link:../page[My Page]            - internal relative path
function! VwlLink()
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
			let l:fname = g:vwlite_root."/".l:word.g:vwlite_ext
		else
			" Path relative to current page
			let l:fname = expand("%:p:h")."/".l:word.g:vwlite_ext
		endif
		execute "edit ".l:fname
	
	" Not a link yet - make it a link
	else
		execute "normal! ciWlink:".l:word."[".l:word."]\<ESC>"
	endif
endfunction

function! VwlBack()
	if len(s:history) < 1
		return
	endif

	let l:last = remove(s:history, -1)
	echom "last was: ".l:last
	execute "edit ".l:last
endfunction

function! VwlMap()
	" Set wiki pages to automatically save
	set autowriteall

	" Map ENTER key to create/follow links
	nnoremap <buffer> <CR> :call VwlLink()<CR>

	" Map BACKSPACE key to go back in history
	nnoremap <buffer> <BS> :call VwlBack()<CR>
endfunction

" This part belongs in <plugin>/ftdetect/vwlite.vim
let s:root = expand(g:vwlite_root)

augroup vwlite
	au!
	execute "au BufNewFile,BufRead ".s:root."/*.adoc call VwlMap()"
augroup END

