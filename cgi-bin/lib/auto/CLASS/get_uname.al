# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

sub get_uname {
   my ($self, $email) = @_;
   my $fname = "$self->{'Root Dir'}/admin/elist";
   if (!(-e $fname)) {
       open(EFILE,">$fname") or
           &ERROR::system_error("CLASS","get_uname","create $fname",$email);
       flock(EFILE, LOCK_EX);
       my @members = $self->get_mem_names('instructor');
       push(@members,$self->get_mem_names('student'));
       foreach $member (@members) {
           my $val = $self->get_email_addr($member); 
           print EFILE "$val=$member\n";
       }
       flock(EFILE,UNLOCK);
       close(EFILE);
   }
   open(ELIST,"<$fname") or
       &ERROR::system_error("CLASS","get_uname","open $fname",$email);
   my @list = <ELIST>;
   close ELIST;
   chomp(@list);
   foreach $line (@list) {
       my ($key,$uname)=split(/=/,$line);
       if ($key eq $email) {
           return $uname;
       }
   }
   return '';
}

1;
