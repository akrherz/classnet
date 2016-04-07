# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub edit {
    my ($self) = @_;
    $editor = $self->{'Editor Type'}->new($self);
    $editor->open();
}

1;
