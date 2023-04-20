let s:BIN = fnamemodify(resolve(expand("<sfile>:p")), ":h")

if (!exists('g:perl_tags#tags_file'))
  let g:perl_tags#tags_file = tempname()
endif

function! perl_tags#do_tags(filename) " perform tagging
  if (get(g:, 'perl_tags#enabled', 1))
    if !exists("g:perl_tags#initialized")
perl <<PERL_INIT
    use strict; use warnings;
    our $tagger;

    my $bin = VIM::Eval('s:BIN');
    require "$bin/../perllib/perl-tags/bin/require-perl-tags-packed" or die "Couldn't find Perl::Tags";

    my $max_level = VIM::Eval('get(g:, "perl_tags#max_level", 4)');

    my $ppi = VIM::Eval('get(g:, "perl_tags#use_ppi", 0)');
    my %args = ( max_level => $max_level );

    $tagger = Perl::Tags::Hybrid->new(
        %args,
        taggers => [
            Perl::Tags::Naive::Moose->new( %args ),
            $ppi ? Perl::Tags::PPI->new( %args ) : (),
        ],
    );
PERL_INIT
      let g:perl_tags#initialized = 1
    endif
perl <<PERL_DO_TAGS
    my $filename = VIM::Eval('a:filename');

    our $tagger;
    $tagger->process(files => $filename, refresh=>1 );

    my $tagsfile=VIM::Eval('get(g:, "perl_tags#tags_file", tempname())');
    VIM::SetOption("tags+=$tagsfile");

    # of course, it may not even output, for example, if there's nothing new to process
    $tagger->output( outfile => $tagsfile );
PERL_DO_TAGS
endif
endfunction

function! perl_tags#show_tags()
perl <<EOF
    our $tagger;
    VIM::Msg($tagger);
EOF
endfunction

function! perl_tags#enable()
  let g:perl_tags#enabled = 1
  call perl_tags#do_tags(expand('%'))
endfunction

function! perl_tags#disable()
  let g:perl_tags#enabled = 0
endfunction

command! PerlTagsEnable call perl_tags#enable()
command! PerlTagsDisable call perl_tags#disable()

" perform initial tagging if enabled
call perl_tags#do_tags(expand('%'))
