# NOTE: Derived from lib/ASSIGNMENT.pm.  Changes made here will be lost.
package ASSIGNMENT;

#########################################

sub unpack_assign_header {
   my ($class,$header) = @_;
   my %assign_info = {};

   # Passing the wrong header?
   ($header =~ m/<\s*CN_ASSIGN\s*/i) or return undef;

   # Get rid of any line separators and chop >
   $/="";
   chomp $header;
   chop $header;
   
   # TYPE default
   $assign_info{'Assignment Type'} = 'TEST';

   # Parse out info
   (($header =~ m/\sTYPE="([^"]*)/i) or ($header =~m/\sTYPE=(\S*)/i)) and
       $assign_info{'Assignment Type'} = "\U$1\E";
   (($header =~ m/\sOPT="([^"]*)/i) or ($header =~ m/\sOPT=(\S*)/i)) and
       $assign_info{'OPT'} = $1;
   (($header =~ m/\sDUE="([^"]*)/i) or ($header =~m/\sDUE=(\S*)/i)) and
       $assign_info{'DUE'} = $1;
   $assign_info{'TP'} = (($header =~ m/\sTP="([^"]*)/i) or 
                         ($header =~ m/\sTP=(\S*)/i))? $1:0;
   (($header =~ m/\sPASSWORD="([^"]*)/i) or ($header =~m/\sPASSWORD=(\S*)/i)) and
       $assign_info{'PASSWORD'} = $1;
   # Add any defaults
   $assign_info{'VIEW'} = ($assign_info{'OPT'} =~ m/NOVIEW/i) ? 0 : 1;

   return %assign_info;
}

1;
