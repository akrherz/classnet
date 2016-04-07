# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub submit_edit_changes {
   my ($self,$query) = @_;

   #my $stud_name = $query->param('Student Username');
   #my $asn_name = $query->param('Assignment Name');
   #!($stud_name and $asn_name) and
   #    ERROR::system_error('CLASS','submit_edit_changes','',
   #    	   "Finding student ($stud_name) and asn name ($asn_name) in query");
   #my $stud = $self->get_member("",$stud_name);
   #my $asn = $self->get_assignment("",$stud,$asn_name);
   #$asn->submit_edit_changes($query);
}

1;
