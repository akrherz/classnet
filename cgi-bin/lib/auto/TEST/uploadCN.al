# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub uploadCN {
    my ($self,$hfile) = @_;
    my @blocks = split(/<\s*\/CN_BLOCK\s*>\s*/,$hfile);
    my $b = 0;
    foreach $block (@blocks) {
        my $header = '';
        $block =~ s/(<\s*CN_BLOCK[^>]*>)/eval { $header = $1; ''}/e;
        my %params = unpack_block_header($header);
        $b++;
        if (!defined %params) {
            $self->delete();
            $header =~ s/</&lt/;
            ERROR::user_error($ERROR::NOTDONE,"upload. Check block $b:<BR><B>$header</B>");
            exit(0);
        }
        ($b > 1) and $self->insert_block($b);
        my @questions = split(/<\s*CN_Q/,$block);
        $params{'btext'} = shift @questions;
        $self->write_block($b,%params);
        my $q = 0;
        foreach $quest (@questions) {
            my $header = '';
            $quest =~ s/([^>]*>)/eval { $header = $1; ''}/e;
            my %params = unpack_question_header("<CN_Q$header");
            $q++;
            if (!defined %params) {
                $self->delete();
                ERROR::user_error($ERROR::NOTDONE,"upload. Check block $b, question $q:<BR><B>&ltCN_Q $header</B>");
                exit(0);
            }
            ($q > 1) and $self->insert_question($b,$q,%params);
            my @text = split(/<\s*CN_FEEDBACK\s*>/,$quest);
            $params{'qtext'} = $text[0];
            (defined $text[1]) and $params{'feedback'} = $text[1];
            $self->write_question($b,$q,%params);
        }
    }
}

1;
