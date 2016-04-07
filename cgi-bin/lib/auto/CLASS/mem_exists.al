# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub mem_exists {

   my ($self, $disk_uname) = @_;

   # Enrolled student?
   my $fname = "$self->{'Root Dir'}/admin/members/students/$disk_uname";
   if (-e $fname) {
       return 'student';
   }

   # Requesting student?
   $fname = "$self->{'Root Dir'}/admin/members/requests/$disk_uname";
   return 'requests' if (-e $fname);

   # Instructor?
   $fname = "$self->{'Root Dir'}/admin/members/instructors/$disk_uname";
   (-e $fname) ? 'instructor' : "";
}

1;
