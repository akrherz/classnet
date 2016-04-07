# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub set_reg_options {
   my ($self, $enroll,$month,$showcomm) = @_;
   # Set options in admin/reg_options;
   my $fname = "$self->{'Root Dir'}/admin/reg_options";
   open(REG_OPT, ">$fname") or 
       ERROR::system_error("INSTRUCTOR","set_reg_options","Open",$fname);
   flock(REG_OPT, $LOCK_EX);
   print REG_OPT "Verify Enrollment=$enroll\n";
   print REG_OPT "Expiration Month=$month\n";
   print REG_OPT "ShowComm=$showcomm\n";
   flock(REG_OPT, $LOCK_EX);
   close(REG_OPT) or
       ERROR::system_error("CLASS","set_reg_options","Close",$fname);
   chmod(0600, $fname);
}

1;
