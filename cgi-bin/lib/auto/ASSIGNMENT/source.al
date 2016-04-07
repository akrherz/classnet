# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub source {
    my ($self) = @_;
    return $self->get_assign_header();
}

1;
