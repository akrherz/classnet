# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub question_count {
    my ($self,$b) = @_;
    opendir(QUEST,"$self->{'Dev Root'}/$b") or
       	ERROR::system_error('TEST','question_count','opendir',"$self->{'Dev Root'}/$b");
    my $q = grep(/^\d+$/,readdir(QUEST));
    close QUEST;
    return $q;
}

1;
