# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub delete {
    my ($self) = @_;
    system "rm -rf $self->{'Dev Root'}";
    #delete student assignments?
}

1;
