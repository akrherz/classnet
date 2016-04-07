# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub regrade {
    my ($self) = @_;
    # make sure an assignment exists, then grade
    ($self->get_status()) and $self->grade(); 
}

1;
