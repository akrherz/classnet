# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub publish {
    my ($self) = @_;
    if ($self->{'Dev Root'} =~ /.develop/) {
        rename($self->{'Dev Root'},$self->{'Form Root'});
        $self->{'Dev Root'} = $self->{'Form Root'};
    }
}

1;
