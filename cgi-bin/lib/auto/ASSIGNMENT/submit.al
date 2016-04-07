# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub submit {
   my $self = shift;

   # Store the query unless it has been graded
   if ($self->get_status() eq 'ungraded') {
       $self->write_assign_query();
   }
   else {
       ERROR::user_error($ERROR::GRADED);
   }

   # Attempt to grade any ungraded assigns for this student
   # $self->grade_ungraded();
}

1;
