# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub exists {
   my $self = shift;
   (-e $self->{'Root Dir'});
}

1;
