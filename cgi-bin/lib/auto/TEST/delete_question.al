# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub delete_question {
    my ($self,$b,$q) = @_;
    $nq = $self->question_count($b);
    if ($nq == 1) {
        ERROR::system_error('TEST','delete_question','delete last question',"$dir/$b/1");
    }
    my $cls = $self->{'Class'};
    my $clip = "$cls->{'Root Dir'}/assignments/.develop/.clipq";
    $dir = $self->{'Dev Root'};
    rename ("$dir/$b/$q",$clip) or
        ERROR::system_error('TEST','delete_question','rename',"$dir/$b/$q");
    for ($old = $q + 1; $old <= $nq; $old++) {
        $new = $old - 1;
        rename("$dir/$b/$old","$dir/$b/$new") or
            ERROR::system_error('TEST','delete_question','rename',"$dir/$b/$old");
    }
}

1;
