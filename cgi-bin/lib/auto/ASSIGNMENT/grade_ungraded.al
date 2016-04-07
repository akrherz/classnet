# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub grade_ungraded {
   my ($self) = @_;

   # default is to grade if it is ungraded
   if ($self->get_status() eq 'ungraded') {
       $self->grade();
   }
}

1;
