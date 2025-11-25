# NOTE: Derived from lib/TEST.pm.  Changes made here will be lost.
package TEST;

#########################################

sub unpack_question_header {
   my ($class, $header) = @_;
   # Handle both class method and function calls
   if (ref($class) || $class !~ /</) {
       # Called as method, $header is second arg
   } else {
       # Called as function, $class is actually $header
       $header = $class;
   }
   my %q_info;

   # Passing the wrong header?
   ($header =~ m/<\s*CN_Q\s*/i) or return undef;

   # Get rid of any line separators and chop >
   $/="";
   chomp $header;
   chop $header;

   # Put in Question Type default
   $q_info{'Question Type'} = 'CHOICE';

   # Parse out info;
   (($header =~ m/\sTYPE="([^"]*)/i) or ($header =~ m/\sTYPE=(\S*)/i)) and
       $q_info{'Question Type'} = $1;
   (($header =~ m/\sJUDGE="([^"]*)/i) or ($header =~ m/\sJUDGE=(\S*)/i)) and
       $q_info{'JUDGE'} = $1;
   (($header =~ m/\sANS="([^"]*)/i) or ($header =~ m/\sANS=(\S*)/i)) and
       $q_info{'ANS'} = $1;
   ($header =~ m/\sROWS="?\s*(\d+)/i) and
       $q_info{'ROWS'} = $1;
   ($header =~ m/\sCOLS="?\s*(\d+)/i) and
       $q_info{'COLS'} = $1;
   ($q_info{'Question Type'} =~ /BLANK|MULTIPLE/) and
       $q_info{'N'} = (($header =~ m/\sN="?(\d+)/i) ? $1:1);

   # If this is a numeric answer, get rid of any commas in the answer
   # Note: can't do this here because mutliple answers are separated by commas
#   ($q_info{'JUDGE'} =~ /NUM/i) and $q_info{'ANS'} =~ s/,//g;

   # CHECK proper types and add any defaults
   if ($q_info{'Question Type'} =~ /ESSAY/i) {
       $q_info{'ROWS'} or $q_info{'ROWS'} = 1;
       $q_info{'COLS'} or $q_info{'COLS'} = 10;
   }
   elsif ($q_info{'Question Type'} =~ /BLANK/i) {
       $q_info{'COLS'} or $q_info{'COLS'} = 10;
       $q_info{'ROWS'} = 1;
       $q_info{'JUDGE'} or $q_info{'JUDGE'} = 'EXACT';
   }
   elsif ($q_info{'Question Type'} =~ /LIST/i) {
       $q_info{'ROWS'} or $q_info{'ROWS'} = 1;
   }
   elsif (!($q_info{'Question Type'} =~ /CHOICE|OPTION|MULTIPLE|LIKERT/i)) {
       return undef;
   }

   return %q_info;

}

1;
