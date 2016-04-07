# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub delete_key {
    my ($self) = @_;
    if (-e $self->{'Key Path'}) {
        unlink $self->{'Key Path'};
    }
}

1;
