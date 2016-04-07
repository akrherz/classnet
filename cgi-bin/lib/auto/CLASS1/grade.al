# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub grade {
   my ($self,$stud_names,$asn_names) = @_;

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   # Get class names and set up dummy student object
   my @snames = @{$stud_names};
   my $stud_name = shift @snames;
   my $stud_obj = $self->get_member("",$stud_name);
   unshift(@snames,$stud_name);

   foreach $asn_name (@{$asn_names}) {
       my $asn = $self->get_assignment("",$stud_obj,$asn_name);
       foreach $stud_name (@snames) {
       	   my $stud_disk_name = CN_UTILS::get_disk_name($stud_name);
       	   !$asn and
       	       $asn = $self->get_assignment("",$stud,$asn_name);

       	   # Set up directories under assignment and grade
       	   $asn->{'Ungraded Dir'} = "$self->{'Root Dir'}/students/$stud_disk_name/ungraded";
       	   $asn->{'Graded Dir'} = "$self->{'Root Dir'}/students/$stud_disk_name/graded";
       	   $asn->regrade();
       }
       undef $asn;
   }
}

1;
