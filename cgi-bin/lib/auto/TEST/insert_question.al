# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub insert_question {
    my ($self,$b,$q) = @_;
    $dir = $self->{'Dev Root'};
    $nq = $self->question_count($b);
    if ($q < 1 || $q > ($nq + 1)) {
        return;
    }
    for ($old = $nq; $old >= $q; $old--) {
        $new = $old + 1;
        rename("$dir/$b/$old","$dir/$b/$new");
    }
    open(QUEST,">$dir/$b/$q") or
        ERROR::system_error('TEST','insert_question','open',"$dir/$b/$q");
    print QUEST "<CN_Q>\n";
    close QUEST;
}

1;
