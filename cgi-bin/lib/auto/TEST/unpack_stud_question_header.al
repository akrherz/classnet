# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub unpack_stud_question_header {
   my ($header) = @_;
   my %q_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_Q\s*/i) or return undef;

   # Get rid of end of line and >
   chomp $header;
   chop $header;

   # Get the stored name
   if (($header =~ m/NAME="([^"]*)/i) or ($header =~ m/NAME=(\S*)/i)) {
       $q_info{'NAME'} = $1;
   }
   else {
       return undef;
   }

   # Any Pts received?
   if ($header =~ m/PR="?([+|-]?[.|\d]+)/ ) {
       $q_info{'PR'} = $1;
   }
   else {
       $q_info{'PR'} = 0;
   }

   # Parse out partial_pts/total_pts
   if ($header =~ m/PTS="?([+|-]?[.|\d]+)\/([+|-]?[.|\d]+)/ ) {
       $q_info{'TP'} = $2;
       $q_info{'PP'} = $1;
   }
   else {
       return undef;
   }
   return %q_info;
}

1;
