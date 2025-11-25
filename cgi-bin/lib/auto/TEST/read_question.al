# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub read_question {
    my ($self,$b,$q,$no_unpack) = @_;
    my (%params, @qdata);
    my $fname = "$self->{'Dev Root'}/$b/$q";

    # Set input record separator and read the file
    $/ = "\n";
    open(QUEST,"<$fname") or
        ERROR::system_error('TEST','read_question','open',$fname);
    @qdata = <QUEST>;
    close(QUEST);
    if ($no_unpack) { 
       $params{'cn_q'} = shift @qdata;
    }
    else {
       my $header = shift @qdata;
       %params = TEST::unpack_question_header($header);
       (%params) or
           ERROR::system_error('TEST','read_question','unpack_question_header',
                               "$fname:$header");
    }

    # Pull out html and any feedback
    $qdata = join('',@qdata);
    my ($html, $feedback) = split(/<CN_FEEDBACK>\n?/i,$qdata);
    $params{'qtext'} = $html;
    $feedback and $params{'feedback'} = $feedback; 
    return %params;
}

1;
