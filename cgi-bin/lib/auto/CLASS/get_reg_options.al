# NOTE: Derived from lib/CLASS.pm.  Changes made here will be lost.
package CLASS;

#########################################

sub get_reg_options {
   my $self = shift;

   # Read options from reg_options file if it exists
   my $reg_opt_file = "$self->{'Root Dir'}/admin/reg_options";
   if (-e $reg_opt_file) {
       open(REG_OPT, "<$reg_opt_file") or 
       	   ERROR::system_error("CLASS","get_reg_options","Open",$reg_opt_file);
       flock(REG_OPT, $LOCK_EX);
       while (<REG_OPT>) {
       	   chop;
       	   my ($option, $value) = split(/=/);
       	   $self->{$option} = $value;
       }
       flock(REG_OPT, $LOCK_UN);
       close(REG_OPT);
   }
}

1;
