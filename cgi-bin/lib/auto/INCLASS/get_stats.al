# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub get_stats {
    my ($self,$stats,$tot) = @_;
    if ($self->get_status() eq 'graded') {
        $self->read_test();
        my $pr = $self->{'PR'};
        if (defined $tot->{$pr}) {
            $tot->{$pr}++;
        } else {
            $tot->{$pr} = 1;
        }
    }
}

1;
