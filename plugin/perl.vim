setlocal iskeyword+=:  " make tags with :: in them useful
 
if ! exists("s:defined_functions")
function s:init_tags()
    perl <<EOF
        use Perl::Tags;
        $naive_tagger = Perl::Tags::Naive->new( max_level=>2 );
            # only go one level down by default
EOF
endfunction
 
" let vim do the tempfile cleanup and protection
let s:tagsfile = tempname()
 
function s:do_tags(filename)
    perl <<EOF
        my $filename = VIM::Eval('a:filename');
 
        $naive_tagger->process(files => $filename, refresh=>1 );
 
        my $tagsfile=VIM::Eval('s:tagsfile');
        VIM::SetOption("tags+=$tagsfile");
 
        # of course, it may not even output, for example, if there's nothing new to process
        $naive_tagger->output( outfile => $tagsfile );
EOF
endfunction
 
call s:init_tags() " only the first time
 
let s:defined_functions = 1
endif
 
call s:do_tags(expand('%'))
 
augroup perltags
au!
autocmd BufRead,BufWritePost *.pm,*.pl call s:do_tags(expand('%'))
augroup END
