# NOTE: Derived from lib/MEMBER.pm.  Changes made here will be lost.
package MEMBER;

#########################################

sub change_info_file {

   my ($self, $query) = @_;

   # Verify passwords in the form -- if needed
   $newpwd = $query->param('New Password'); 
   if ($newpwd) {
      if ($newpwd ne $query->param('Verify New Password')) {
       	 &ERROR::user_error($ERROR::PWDVERIFY);
      }
      if ($newpwd ne $self->{'Password'}) {
         $self->{'Password'} = $newpwd;  
      }
   }    

   # Look for email; If blanked out, then do not change
   ($query->param('New Email Address')) and
       $self->{'Email Address'} = $query->param('New Email Address');

   # What about privileges?
   
   if (($self->{'Priv'} =~ /owner/) or ($self->{'Member Type'} eq 'student')) {
       $priv_str = $self->{'Priv'};
   } else {
       $priv_str = join(',',$query->param('Privileges'));
   }
   my $new_fname = "$self->{'Root Dir'}/admin/members/$self->{'Member Type'}s/$self->{'Disk Username'}.new";
   my $fname = "$self->{'Root Dir'}/admin/members/$self->{'Member Type'}s/$self->{'Disk Username'}";

   open(MEM_FILE, ">$new_fname") or 
     &ERROR::system_error("MEMBER","change_info_file","Open",$new_fname);
   print MEM_FILE "Password=$self->{'Password'}\n";
   print MEM_FILE "Email Address=$self->{'Email Address'}\n";
   print MEM_FILE "Priv=$priv_str\n" 
      if ($self->{'Member Type'} eq 'instructor');
   close(MEM_FILE) or
     &ERROR::system_error("MEMBER","change_info_file","Close",$new_fname);
   rename($new_fname, $fname);
   chmod(0600, $fname);
   my $fname = "$self->{'Root Dir'}/admin/elist";
   unlink $fname;
}

1;
