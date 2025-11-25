# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub unpack_stud_test_header {
   my ($class, $header) = @_;
   # Handle both class method and function calls
   if (ref($class) || $class !~ /</) {
       # Called as method, $header is second arg
   } else {
       # Called as function, $class is actually $header
       $header = $class;
   }
   my %t_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_ASSIGN\s*/i) or return undef;

   # Get rid of end of line and >
   chomp $header;
   chop $header;

   # Parse out pts_received/total_pts
   if ($header =~ m/\sPTS="?\s*(\d+)\s*\/\s*(\d+)/i)  {
       $t_info{'TP'} = $2;
       $t_info{'PR'} = $1;
   }
   else {
       return undef;
   }

   # Get submit
   ($header =~ m/SUBMIT="?(\d)/i) and
       $t_info{'SUBMIT'} = $1;

   # Get seen
   ($header =~ m/SEEN="([^"]*)/i) and
       $t_info{'SEEN'} = $1;

   # Get submit date
   ($header =~ m/SUBDATE="([^"]*)/i) and
       $t_info{'SUBDATE'} = $1;

   return %t_info;
}

1;
