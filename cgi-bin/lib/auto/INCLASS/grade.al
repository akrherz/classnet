# NOTE: Derived from lib/INCLASS.pm.  Changes made here will be lost.
package INCLASS;

sub grade {

   my $self = shift;

   my $fname = "$self->{'Ungraded Dir'}/$self->{'Student File'}"; 
   if (-e $fname) {
       rename($fname,"$self->{'Graded Dir'}/$self->{'Student File'}");
   }
}

1;
