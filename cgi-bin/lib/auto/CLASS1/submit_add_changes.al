# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub submit_add_changes {
   my ($self,$query) = @_;

   my @adds = $query->param('assignments');
   foreach (@adds) {
       my ($sname,$type,$aname) = split(/\//);
       $aname = CGI::unescape($aname);
       my $stud = $self->get_member("",$sname);
       my $asn = ($type)->new($query,$self,$stud,$aname);
       $asn->get_new_form('student','submit');
   }
}

1;
