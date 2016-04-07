# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub unpack_block_header {
   my ($header) = @_;
   my %grade_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_BLOCK\s*/i) or return undef;

   # Get rid of end of line and >
   chomp $header;
   chop $header;

   # Set any defaults
   $grade_info{'TP'} = 1;
   $grade_info{'PP'} = 0;

   # Get block name if any
   (($header =~ m/\sNAME="([^"]*)/i) or ($header =~ m/\sTYPE=(\S*)/i)) and
       $grade_info{'Name'} = $1;

   # Parse out the total and/or partial pts
   if ($header =~ m/\sPTS="?([+|-]?[.|\d]+)\/([+|-]*[.|\d]+)/ ) {
       $grade_info{'TP'} = $2;
       $grade_info{'PP'} = $1;
   }
   elsif ($header =~ m/\sPTS="?([+|-]?[.|\d]+)/)  {
       $grade_info{'TP'} = $1;
       $grade_info{'PP'} = 0;
   }

   # Get rid of any commas
   $grade_info{'TP'} =~ s/,//g;
   $grade_info{'PP'} =~ s/,//g;

   return %grade_info;
}

1;
