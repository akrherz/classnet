# NOTE: Derived from lib/EVAL.pm.  Changes made here will be lost.
package EVAL;

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = "\n***NEW RANDOM EVAL***\n";
    my $name = $self->{'Name'};
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $answers = $self->{'Stud Answers'};
        my $nb = $self->block_count();
        for ($i=1;$i <= $nb; $i++) {
            my $key = "$i.1";
            if (defined $answers->{$key}{'ANS'}) {
                $ans = $answers->{$key}{'ANS'};
                $body .= "\n$ans";
            } else {
                my $j = 1;
                $body .= "\n";
                while (defined $answers->{"$key.$j"}{'ANS'}) {
                    $ans = $answers->{"$key.$j"}{'ANS'};
                    $body .= "|$ans";
                    $j++;
                }
            }
        }
    }
    $body .= "\n";
}

1;

1;
