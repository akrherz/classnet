# NOTE: Derived from lib/FORECAST.pm.  Changes made here will be lost.
package FORECAST;

sub get_score {
   my ($class, $cls, $asn_name, $stud_name) = @_;
   my $escaped_stud_name = CGI::escape($stud_name);

   my $tp = 0;
   my $pr = 0;
   my $text = "<B>Forecasts</B>\n<UL>\n"; 
   # Set input record separator and read the file
   $/ = "\n";

   # get all graded forecasts
   my $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/graded";
   my @files = get_forecasts($path,$asn_name);

   foreach $fname (@files) {
       my $date = CN_UTILS::getTime("$path/$fname");
       open(ASN,"<$path/$fname");
       flock(ASN,$LOCK_EX);
       my $test_header = <ASN>;
       flock(ASN,$LOCK_UN);
       close(ASN);
       my %score = TEST::unpack_stud_test_header($test_header,$fname);
       (defined %score) or
            ERROR::system_error('FORECAST','get_score','unpack sheader',
                                "$fname:$test_header");
       $text .= "<LI><B>$fname:</B> $score{'PR'}/$score{'TP'}";
       my $seen = $scores{'SEEN'};
       if (defined $seen) {
          $text .= "<BR>First Seen on $seen";
       }
       my $subdate = $scores{'SUBDATE'};
       if (defined $subdate) {
          $text .= "<BR>Submitted on $subdate";
       }
       my $date = CN_UTILS::getTime($path);
       $text .= "<BR>Graded on $date<BR>";
       $pr += $score{'PR'}; $tp += $score{'TP'};
   }
   # get all ungraded forecasts
   $path = "$cls->{'Root Dir'}/students/$escaped_stud_name/ungraded";
   my @files = get_forecasts($path,$asn_name);
   foreach $fname (@files) {
       my $date = CN_UTILS::getTime("$path/$fname");
       open(ASN,"<$path/$fname");
       my $adata = <ASN>;
       close(ASN);
       $adata =~ m/<CN_ASSIGN.*\sPTS="?(\d+)\/(\d+)/i;
       $text .= "<LI><B>$fname:</B> ?/$2 ";
       if ($adata =~ /SUBMIT=0/) {
           $text .= "(seen on $date but not submitted)<BR>";
       } else {
           $text .= "(submitted on $date but not yet graded)<BR>";
       }
   }
   $text .= "</UL>\n";
   return ($text,$tp,$pr);
}

1;
