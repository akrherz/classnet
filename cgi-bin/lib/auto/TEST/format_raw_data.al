# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = "$sname";
    my $name = $self->{'Name'};
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $answers = $self->{'Stud Answers'};
        my $nb = $self->block_count();
        for ($i=1;$i <= $nb; $i++) {
            my $key = "$i.1";
            if (defined $answers->{$key}{'ANS'}) {
                $ans = $answers->{$key}{'ANS'};
                $body .= "\t$ans";
            } else {
                my $j = 1;
                $body .= "\t";
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
