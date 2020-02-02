
if !exists('g:vimwiki_lite_root')
	let g:vimwiki_lite_root = "~/vwlite"
endif

if !exists('g:vimwiki_lite_ext')
	let g:vimwiki_lite_ext = ".adoc"
endif

let s:history = []


" Links
"   This http://example.com is a link.
"   This http://example.com[Example] is also.
"   This link:page[is also] a link.
"   This link:http://example.com[Example] is also.
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

		" TODO: get relative to the current page's dir, not the wiki root!
		let l:fname = fnamemodify(g:vimwiki_lite_root ."/".l:word.g:vimwiki_lite_ext, ":p") 
		execute "edit ".l:fname
	
	" Not a link yet - make it a link
	else
		execute "normal! ciWlink:".l:word."[".l:word."]\<ESC>"
	endif
endfunction

function! VwlBack()
	if len(s:history) < 1
		echom "hit beginning of history."
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
let s:root = expand(g:vimwiki_lite_root)

augroup vwlite
	au!
	execute "au BufNewFile,BufRead ".s:root."/*.adoc call VwlMap()"
augroup END

