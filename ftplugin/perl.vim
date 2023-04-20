setlocal iskeyword+=:  " make tags with :: in them useful

" this should probably be added to ftplugin/perl to add the autocommand to that buffer?
augroup perltags
  au!
  autocmd BufRead,BufWritePost *.pm,*.pl,*.t call perl_tags#do_tags(expand('%'))
augroup END

" perform initial tagging if enabled
call perl_tags#do_tags(expand('%'))
