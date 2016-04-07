# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub ungrade {
   my ($self,$stud_names,$asn_names) = @_;

   (@{$stud_names} < 1) and 
       ERROR::user_error($ERROR::NOSTUDNAMES);   
   (@{$asn_names} < 1) and 
       ERROR::user_error($ERROR::NOASNNAMES);   

   # Get class names and set up dummy student object
   foreach $asn_name (@{$asn_names}) {
       foreach $stud_name (@{$stud_names}) {
           my $stud_obj = $self->get_member("",$stud_name);
           my $asn = $self->get_assignment("",$stud_obj,$asn_name);
           $asn->ungrade();
       }
   }
}

1;
