# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub unpack_assign_header {
   my ($class,$header) = @_;
   my %assign_info;

   %assign_info = ASSIGNMENT->unpack_assign_header($header);
   (defined %assign_info) or return undef;

   # Add any defaults
   $assign_info{'VERS'} = ($assign_info{'OPT'} =~ /VERS=(\d+)/) ? $1 : 0;
   $assign_info{'FILL'} = ($assign_info{'OPT'} =~ /NOFILL/) ?  0 : 1;
   $assign_info{'MULT'} = ($assign_info{'OPT'} =~ /MULT/) ?  1 : 0;

   return %assign_info;
}

1;
