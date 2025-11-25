# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub write_question {
    my ($self,$b,$q,%params) = @_;
    my $hdr = TEST->pack_question_header(%params);
    my $qtext = $params{'qtext'};
    my $feedback = $params{'feedback'};
    my $txt = $feedback? join("\n<CN_FEEDBACK>\n",$qtext,$feedback):$qtext;
    my $fname = "$self->{'Dev Root'}/$b/$q";
    open(QUEST,">$fname") or
        &system_error('TEST','write_question','open',$fname);
    print QUEST "$hdr\n";
    print QUEST $txt;
    close(QUEST);
}

1;
