" Testing is manual for now, but aided by this simple script. Run like so:
"
"   1. Be in VViki project dir (e.g. cd ~/coolstuff/vviki/)
"   2. Run this script to start testing (vim -S test/test.vim)
"   3. Follow the instructions
"
" Note that this test script may mess up your current session. It can't
" be bargained with. It can't be reasoned with. It doesn't feel pity, or
" remorse, or fear.
"

nnoremap <f5> :call LoadTest()<cr>
nnoremap <right> :call NextTest()<cr>
nnoremap <left> :call PrevTest()<cr>

function! ReloadPlugin()
    " Reload plugin and reset settings to defaults
    unlet! g:loaded_vviki
    unlet! g:vviki_index
	unlet! g:vviki_ext
    unlet! g:vviki_conceal_links
    unlet! g:vviki_page_link_syntax
    unlet! g:vviki_visual_link_creation
    unlet! g:vviki_links_include_ext
    " Set wiki root directory for tests (relative to current dir)
    let g:vviki_root = getcwd()."/test"

    source plugin/vviki.vim
endfunction

function! LoadTest()
    call ReloadPlugin()

    let src_doc = expand("test/test_".s:current_test_num.".adoc")
    let test_script = expand("test/current_script.vim")
    let test_doc = expand("test/current_doc.adoc")

    if !filereadable(src_doc)
        echo "Test ".src_doc." not found. Perhaps we are all done?"
        return
    endif

    " Let's make a new script to execute for the current test
    silent execute "edit ".test_script
    " Clear file
    silent %delete
    " Read current script
    silent execute "read ".src_doc
    " Delete everything except the test script in the file
    silent execute "normal! /Test Script Start\<cr>"
    silent 0,delete
    silent execute "normal! /Test Script End\<cr>"
    silent ,$delete
    silent write
    silent source %

    " Let's make a new document to view for the current test
    silent execute "edit ".test_doc
    silent %delete
    silent execute "read ".src_doc
    silent write

    " Because the autocommands will not fire because we're re-using
    " the current test doc filename, we need to call the setup function
    " manually. Should be identical to opening a new file.
    call VVSetup()

    echo "Test ".s:current_test_num." loaded."
endfunction

function! NextTest()
    let s:current_test_num += 1
    call LoadTest()
endfunction

function! PrevTest()
    let s:current_test_num -= 1
    call LoadTest()
endfunction

" Create buffers in a split to display messages and wiki test pages.
let s:current_test_num = 1
call LoadTest()
