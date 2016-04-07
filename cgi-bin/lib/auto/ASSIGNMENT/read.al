# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub read {
    my ($self) = @_;
    my $header = $self->get_assign_header();
    return (ref($self))->unpack_assign_header($header); }

#########################################

1;
