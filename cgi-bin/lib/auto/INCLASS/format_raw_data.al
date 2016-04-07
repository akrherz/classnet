# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub format_raw_data {
    my ($self,$sname) = @_;
    my $body = "$sname";
    my $name = $self->{'Name'};
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $pr = $self->{'PR'};
        $body .= "\t$pr";
    }
    $body .= "\n";
}

1;
