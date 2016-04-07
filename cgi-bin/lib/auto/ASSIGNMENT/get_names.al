# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub get_names {
    my ($self,$status) = @_;
    my @names = ($self->{'Name'});
    if ($self->get_status()) {
        ($status eq 'existing')? @names:();
    } else {
        ($status eq 'existing')? ():@names;
    }
}

1;
