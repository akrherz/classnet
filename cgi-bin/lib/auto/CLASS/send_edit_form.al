# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub send_edit_form {
   my ($self,$query,$asn_name,$stu) = @_;
   my @snames = @{$stu};
   my $nstu = @snames;
   if ($nstu < 1) {
      ERROR::print_error_header('Edit?');
      print "Please select at least one student.";
      CN_UTILS::print_cn_footer();
      exit(0);
   }
   my $mem = $self->get_member('',$snames[0]);
   my $asn = $self->get_assignment('',$mem,$asn_name);
   $asn->send_edit_form($query,\@snames);
}

1;
