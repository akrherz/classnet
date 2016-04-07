# NOTE: Derived from lib/INSTRUCTOR.pm.  Changes made here will be lost.
package INSTRUCTOR;

#########################################

sub exists {

   my $self = shift;
   my $fname = "$self->{'Root Dir'}/admin/members/instructors/" . $self->{'Username'};
   (-e $fname);

}

1;
