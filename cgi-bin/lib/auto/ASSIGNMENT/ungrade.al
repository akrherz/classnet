# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub ungrade {
    my ($self) = @_;
    my $fname = "$self->{'Graded Dir'}/$self->{'Student File'}";
    if (-e $fname) {
        rename($fname,"$self->{'Ungraded Dir'}/$self->{'Student File'}");
    } 
}

1;
