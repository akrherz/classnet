# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

sub write {
    my ($self,%params) = @_;
    my $hdr = (ref($self))->pack_assign_header(%params);
    $self->put_assign_header($hdr);
}

1;
