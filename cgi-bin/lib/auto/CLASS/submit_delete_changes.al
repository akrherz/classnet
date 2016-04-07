# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub submit_delete_changes {
   my ($self,$query) = @_;

   my @deletions = $query->param('assignments');
   foreach (@deletions) {
       my ($sname,$type,$aname) = split(/\//);
       $aname = CGI::unescape($aname);
       my $stud = $self->get_member("",$sname);
       my $asn = ($type)->new($query,$self,$stud,$aname);
       if ($asn->get_status() eq 'graded') {
           unlink "$asn->{'Graded Dir'}/$asn->{'Student File'}";
       } else {
           unlink "$asn->{'Ungraded Dir'}/$asn->{'Student File'}";
       }
   }
}

1;
