# NOTE: Derived from lib/INSTRUCTOR.pm.  Changes made here will be lost.
package INSTRUCTOR;

#########################################

sub delete_member {
   my ($self, $cls, $mem_name) = @_;

   #Cannot delete owner
   my $member = $cls->get_member(0,$mem_name);

   return "" if $member->{'Priv'} eq 'owner';

   if ($member->{'Member Type'} =~ m/student/) {
       unlink "$cls->{'Root Dir'}/admin/members/students/$member->{'Disk Username'}";
       my $assign_dir = "$cls->{'Root Dir'}/students/$member->{'Disk Username'}";
       system("rm -f -r $assign_dir");
   }
   else { 
       unlink "$cls->{'Root Dir'}/admin/members/instructors/$member->{'Disk Username'}";
   } 

   $cls->remove_from_mem_list($member->{'Member Type'}, $mem_name);
   return $mem_name;
      
}

1;
